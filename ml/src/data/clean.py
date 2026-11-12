
import pandas as pd


# Columns that need date conversion
DATETIME_COLUMNS = {
    "invoices": ["invoice_date"],
    "vendors": ["relationship_start_date"],
    "purchase_orders": ["creation_date", "expiration_date"],
    "employee_authorization_history": ["effective_to"],
    "vendor_name_history": ["effective_to"],
    "vendor_bank_accounts": ["effective_to"],
}


# Columns that need nullable integer conversion
INTEGER_COLUMNS = {
    "employee_authorization_history": [
        "changed_by_employee_id",
        "authorized_by_employee_id",
    ],
    "vendor_bank_accounts": [
        "changed_by_employee_id",
        "authorized_by_employee_id",
    ],
    "bank_account_history": ["authorized_by_employee_id"],
    "payment_terms_history": ["authorized_by_employee_id"],
}


# Columns to inspect for categorical consistency
CATEGORICAL_COLUMNS = {
    "employee_authorization_history": ["auth_role", "auth_status"],
    "vendors": ["vendor_status"],
    "employees": ["role", "department", "employee_status"],
    "vendor_bank_accounts": ["auth_status"],
    "bank_accounts": ["account_status"],
    "bank_account_history": ["auth_status"],
    "payment_terms_history": ["auth_status"],
    "purchase_orders": ["status"],
    "invoice_status_history": ["previous_status", "new_status"],
    "invoices": ["status"],
    "invoice_submission_history": ["submission_status"],
    "invoice_approval_history": ["approval_status"],
    "invoice_risk_assessments": ["risk_level", "assessment_status"],
    "invoice_review_decisions": ["follow_up_status"],
}


# Currency columns to inspect separately
CURRENCY_COLUMNS = {
    "employees": ["approval_currency"],
    "expense_categories": ["budget_currency"],
    "purchase_orders": ["currency"],
    "invoices": ["currency"],
}


def clean_data(table_name, df, all_tables):

    # Get original DataFrame dimensions
    rows, cols = df.shape

    # 1. Create a copy of the original DataFrame
    df_clean = df.copy()

    # 2. Handle missing values
    df_missing = df_clean.isnull().sum()
    df_missing = df_missing[df_missing > 0]

    print(f"\nMissing values in {table_name}:")
    print(df_missing)

    # 3. Handle duplicate records
    df_duplicated = df_clean.duplicated().sum()

    print(f"\nExact duplicate records in {table_name}:")
    print(df_duplicated)

    if df_duplicated > 0:
        print("Exact duplicate rows found. Needs investigation.")

    df_duplicated_rows = df_clean[
        df_clean.duplicated(keep=False)
    ]

    print(f"\nDuplicate rows in {table_name}:")
    print(df_duplicated_rows)

    # Check repeated business identifiers in invoices
    if table_name == "invoices":
        duplicates = df_clean[
            df_clean.duplicated(
                subset=["vendor_invoice_number"],
                keep=False,
            )
        ]

        print("\nDuplicate vendor invoice numbers:")
        print(duplicates)

    # 4. Correct data types

    for column in DATETIME_COLUMNS.get(table_name, []):

        if column in df_clean.columns:

            original_values = df_clean[column]
            converted_values = pd.to_datetime(
                original_values,
                errors="coerce",
            )

            invalid_dates = (
                original_values.notna()
                & converted_values.isna()
            )

            if invalid_dates.any():
                print(
                    f"\nWarning: {invalid_dates.sum()} "
                    f"invalid dates in {table_name}.{column}"
                )

            df_clean[column] = converted_values

    for column in INTEGER_COLUMNS.get(table_name, []):

        if column in df_clean.columns:
            df_clean[column] = df_clean[column].astype("Int64")

    print(f"\nData types after conversion in {table_name}:")
    print(df_clean.dtypes)

    # 5. Standardize values
    # Inspect categorical values first.
    # Do not modify values until inconsistencies are confirmed.

    for column in CATEGORICAL_COLUMNS.get(table_name, []):

        if column in df_clean.columns:
            print(f"\nUnique values in {table_name}.{column}:")
            print(df_clean[column].unique())

    # Inspect currency representations separately
    for column in CURRENCY_COLUMNS.get(table_name, []):

        if column in df_clean.columns:
            print(f"\nCurrency values in {table_name}.{column}:")
            print(df_clean[column].unique())

    
   