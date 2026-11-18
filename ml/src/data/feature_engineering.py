
import pandas as pd


def create_invoice_features(cleaned_tables):
    """
    Build ML features from cleaned source tables.

    Args:
        cleaned_tables: Dictionary containing the cleaned DataFrames.

    Returns:
        Processed invoice DataFrame.
    """
    # 1. Get the source tables we need

    invoices = cleaned_tables["invoices"]
    vendors = cleaned_tables["vendors"]
    employees = cleaned_tables["employees"]
    purchase_orders = cleaned_tables["purchase_orders"]
    expense_categories = cleaned_tables["expense_categories"]
    vendor_bank_accounts = cleaned_tables["vendor_bank_accounts"]
    bank_accounts = cleaned_tables["bank_accounts"]
    employee_authorization_history = cleaned_tables["employee_authorization_history"]
    invoice_approval_history = cleaned_tables["invoice_approval_history"]
    


    # 2. Start with submissions as our base DataFrame (since we detect frauds at every submission)

    submission_events = cleaned_tables["invoice_submission_history"].copy()

    invoices_copy = submission_events.merge(
        invoices,
        on=["company_id", "invoice_id"],
        how="left",
        suffixes=("_submission", "_invoice")
    )

    # 3. Join relevant tables

    invoices_copy = invoices_copy.merge(
        vendors,
        on=["company_id", "vendor_id"],
        how="left"
    )

    print("After vendors:", invoices_copy.columns.tolist())

    invoices_copy = invoices_copy.merge(
            purchase_orders,
            on=["company_id", "purchase_order_id", "vendor_id"],
            how="left"
    )

    invoices_copy = invoices_copy.merge(
            expense_categories,
            on=["company_id", "category_id"],
            how="left"
    )

    invoices_copy = invoices_copy.merge(
        employees,
        left_on=["company_id", "submitted_by_employee_id_submission"],
        right_on=["company_id", "employee_id"],
        how="left"
    )

    invoices_copy = invoices_copy.merge(
        employee_authorization_history,
        left_on=["company_id", "submitted_by_employee_id_submission"],
        right_on=["company_id", "employee_id"],
        how="left"
    )

    invoices_copy = invoices_copy.merge(
            invoice_approval_history,
            on=["company_id", "invoice_id" ],
            how="left"
    )

    invoices_copy = invoices_copy.merge(
        employee_authorization_history,
        left_on=["company_id", "approver_id"],
        right_on=["company_id", "employee_id"],
        how="left",
        suffixes=("_submitter", "_approver")
    )


   

    print("vendor_id exists:", "vendor_id" in invoices_copy.columns)
    print("Available vendor columns:", [c for c in invoices_copy.columns if "vendor" in c])

    print("Columns before vendor bank account merge:")
    print(invoices_copy.columns.tolist())

    invoices_copy = invoices_copy.merge(
        vendor_bank_accounts,
        on=["company_id", "vendor_id", "bank_account_id"],
        how="left"
    )

    # Normalize employee authorization dates
    date_columns = [
        "effective_from_submitter",
        "effective_to_submitter",
        "effective_from_approver",
        "effective_to_approver",
        "effective_from",
        "effective_to",
        "approved_at"
    ]

    for column in date_columns:
        invoices_copy[column] = pd.to_datetime(
            invoices_copy[column], utc=True
        ).dt.tz_localize(None)
    

    # 4. Create new features

    # FEATURE 1: Vendor Age
    invoices_copy["submission_timestamp"] = (
    invoices_copy["submission_timestamp"].dt.tz_localize(None)
    )
    invoices_copy["relationship_start_date"] = pd.to_datetime(
        invoices_copy["relationship_start_date"]
    )
    vendor_age = invoices_copy["submission_timestamp"] - invoices_copy["relationship_start_date"]  

    invoices_copy["vendor_age"] = vendor_age.dt.days

    # FEATURE 2: Invoice amount exceeding PO's authorized amount

    invoices_copy["exceeds_po_amount"] = invoices_copy["invoice_amount"] > invoices_copy["authorized_amount"]

    # FEATURE 3: Invoice amount exceeding expense category's budget monthly

    invoices_copy = invoices_copy.sort_values("submission_timestamp")
    invoices_copy["invoice_month"] = invoices_copy["submission_timestamp"].dt.to_period("M")

    grouped_invoice_amounts = (
        invoices_copy.groupby(["company_id", "category_id", "invoice_month"])
    )

    invoices_copy["running_total_by_category"] = grouped_invoice_amounts["invoice_amount"].cumsum()

    invoices_copy["exceeds_monthly_category_budget"] = (
        invoices_copy["running_total_by_category"] > invoices_copy["monthly_budget"]
    )


    


    # FEATURE 4: Employee active status at time of submission

    invoices_copy["employee_authorized_at_submission"] = (
        (invoices_copy["effective_from_submitter"] <= invoices_copy["submission_timestamp"])
        & (
            invoices_copy["effective_to_submitter"].isna()
            | (invoices_copy["effective_to_submitter"] >= invoices_copy["submission_timestamp"])
        )
        & (invoices_copy["authorization_status_submitter"] == "ACTIVE")
    )

    # FEATURE 5: Approval limit exceeded

    invoices_copy["approval_limit_exceeded"] = (
        invoices_copy["invoice_amount"] > invoices_copy["approval_limit"]
    )

    # FEATURE 6: Vendor Bank Account Validity at Invoice Submission


    print(invoices_copy[["effective_from", "effective_to", "submission_timestamp"]].dtypes)

    invoices_copy["vendor_bank_validity_at_submission"] = (
        (invoices_copy["effective_from"] <= invoices_copy["submission_timestamp"])
        & (
            invoices_copy["effective_to"].isna()
            | (invoices_copy["effective_to"] >= invoices_copy["submission_timestamp"])
        )
    )

    print("Reached Feature 6")

    # FEATURE 7: Multiple submissions for the same invoice

    invoice_submission_history_copy = cleaned_tables["invoice_submission_history"].copy()

    submission_summary = (
    invoice_submission_history_copy
        .groupby(["company_id", "invoice_id"])
        .agg(
            total_submission_attempts=("submission_history_id", "count"),
            resubmission_count=(
                "submission_status",
                lambda status: (status == "RESUBMITTED").sum()
            )
        )
        .reset_index()
    )

    invoices_copy = invoices_copy.merge(
        submission_summary,
        on=["company_id", "invoice_id"],
        how="left"
    )

    print("Reached Feature 7:", "total_submission_attempts" in invoices_copy.columns)

    # FEATURE 8: Approver Authorization at Time of Approval

    invoices_copy["approver_authorized_at_approval"] = (
        (invoices_copy["effective_from_approver"] <= invoices_copy["approved_at"])
        & (
            invoices_copy["effective_to_approver"].isna()
            | (invoices_copy["effective_to_approver"] >= invoices_copy["approved_at"])
        )
        & (invoices_copy["authorization_status_approver"] == "ACTIVE")
    )

    # FEATURE 9: Vendor Average Invoice Amount

    invoices_copy = invoices_copy.sort_values("submission_timestamp")

    invoices_copy["vendor_average_invoice_amount"] = (
        invoices_copy.groupby(["company_id", "vendor_id"])["invoice_amount"]
        .transform(lambda amounts: amounts.expanding().mean().shift(1))
    )

    # FEATURE 10: Vendor Amount Deviation

    invoices_copy["vendor_amount_deviation"] = (
    (invoices_copy["invoice_amount"] - invoices_copy["vendor_average_invoice_amount"])
        / invoices_copy["vendor_average_invoice_amount"]
    ) * 100


    # FEATURE 11: Vendor Invoice Frequency Per Month

    vendor_invoice_frequency = (
        invoices_copy
        .groupby(["company_id", "vendor_id", "invoice_month"])
        .agg(
            vendor_invoice_frequency=("invoice_id", "count")
        )
        .reset_index()
    )

    invoices_copy = invoices_copy.merge(
        vendor_invoice_frequency,
        on=["company_id", "vendor_id", "invoice_month"],
        how="left"
    )


    # FEATURE 12: Bank Account Change Recency

    invoices_copy["bank_account_change_recency"] = (
        invoices_copy["submission_timestamp"] - invoices_copy["effective_from"]
    ).dt.days

    # FEATURE 13: Shared Bank Account Count

    shared_bank_account_count = (
            invoices_copy
            .groupby(["company_id", "bank_account_id"])
            .agg(
                shared_bank_account_count=("vendor_id", "nunique")
            )
            .reset_index()
    )

    invoices_copy = invoices_copy.merge(
            shared_bank_account_count,
            on=["company_id", "bank_account_id"],
            how="left"
        )
    

    # FEATURE 14 : Purchase Order Amount Deviation


    invoices_copy["po_amount_deviation"] = (
    (invoices_copy["invoice_amount"] - invoices_copy["authorized_amount"])
        / invoices_copy["authorized_amount"]
    ) * 100

    # 5. Select and organize the final columns



    # 6. Return the processed DataFrame
    print("Final columns:", invoices_copy.columns.tolist()[-15:])

    return invoices_copy

