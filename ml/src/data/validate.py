import pandas as pd


FOREIGN_KEYS = {
        "invoices": {
            "vendor_id": ("vendors", "vendor_id"),
            "purchase_order_id": ("purchase_orders", "purchase_order_id"),
        },
        "purchase_orders": {
            "vendor_id": ("vendors", "vendor_id"),
        },
        "employee_authorization_history": {
            "employee_id": ("employees", "employee_id"),
        },
    }

REQUIRED_COLUMNS = {
    "companies": [
        "company_id",
        "company_name",
        "created_at",
    ],
"employees": [
        "employee_id",
        "company_id",
        "employee_name",
        "role",
        "department",
        "employee_status",
        "approval_limit",
        "approval_currency",
    ],
    "employee_authorization_history": [
        "authorization_history_id",
        "company_id",
        "employee_id",
        "authorization_role",
        "approval_limit",
        "approval_currency",
        "effective_from",
        "effective_to",
        "changed_by_employee_id",
        "authorized_by_employee_id",
        "authorization_status",
    ],
    "vendors": [
        "vendor_id",
        "company_id",
        "vendor_name",
        "vendor_status",
        "relationship_start_date",
    ],
    "vendor_name_history": [
        "vendor_name_history_id",
        "vendor_id",
        "company_id",
        "vendor_name",
        "effective_from",
        "effective_to",
    ],
    "expense_categories": [
        "category_id",
        "company_id",
        "category_name",
        "budget_currency",
    ],
    "bank_accounts": [
    "bank_account_id",
    "account_status",
],

"vendor_bank_accounts": [
    "vendor_bank_account_id",
    "company_id",
    "vendor_id",
    "bank_account_id",
    "authorization_status",
    "effective_to",
],

"bank_account_history": [
    "bank_account_history_id",
    "old_bank_account_id",
    "new_bank_account_id",
    "company_id",
    "authorization_status",
    "authorized_by_employee_id",
],
    "payment_terms_history": [
        "payment_terms_history_id",
        "company_id",
        "vendor_id",
        "authorization_status",
        "authorized_by_employee_id",
    ],
    "purchase_orders": [
        "purchase_order_id",
        "company_id",
        "vendor_id",
        "creation_date",
        "expiration_date",
        "currency",
        "status",
    ],
    "purchase_order_history": [
        "purchase_order_history_id",
        "company_id",
        "purchase_order_id",
        "previous_authorized_amount",
        "new_authorized_amount",
        "changed_at",
        "changed_by_employee_id",
        "change_reason",
    ],
    "invoices": [
        "invoice_id",
        "company_id",
        "vendor_id",
        "vendor_invoice_number",
        "vendor_name_snapshot",
        "invoice_amount",
        "currency",
        "invoice_date",
        "submission_timestamp",
        "purchase_order_id",
        "category_id",
        "cost_code",
        "payment_terms_snapshot",
        "bank_account_reference_snapshot",
        "submitted_by_employee_id",
        "status",
        "created_at",
        "updated_at",
    ],
    "invoice_submission_history": [
        "submission_history_id",
        "company_id",
        "invoice_id",
        "submission_number",
        "submitted_at",
        "submitted_by_employee_id",
        "submission_status",
        "rejection_reason",
    ],
    "invoice_status_history": [
        "invoice_status_history_id",
        "company_id",
        "invoice_id",
        "previous_status",
        "new_status",
    ],
    "invoice_approval_history": [
        "approval_history_id",
        "company_id",
        "invoice_id",
        "approver_id",
        "approval_status",
        "approved_at",
        "comments",
    ],
    "invoice_risk_assessments": [
        "risk_assessment_id",
        "invoice_id",
        "assessment_version",
        "risk_score",
        "risk_level",
        "model_version",
        "ruleset_version",
        "assessment_status",
        "explanation",
        "assessed_at",
    ],
    "invoice_detection_results": [
        "detection_result_id",
        "risk_assessment_id",
        "detection_type",
        "detection_name",
        "detection_source",
        "severity",
        "finding_score",
        "evidence",
        "created_at",
    ],
    "invoice_review_decisions": [
        "review_decision_id",
        "company_id",
        "invoice_id",
        "risk_assessment_id",
        "reviewer_employee_id",
        "decision",
        "decision_reason",
        "decided_at",
        "follow_up_status",
    ],
}


REQUIRED_FIELDS = {
    "companies": [
        "company_id",
        "company_name",
    ],

    "employees": [
        "employee_id",
        "company_id",
        "employee_name",
        "role",
        "department",
        "employee_status",
    ],

    "employee_authorization_history": [
        "authorization_history_id",
        "company_id",
        "employee_id",
        "authorization_role",
        "approval_limit",
        "approval_currency",
        "effective_from",
        "authorization_status",
    ],

    "vendors": [
        "vendor_id",
        "company_id",
        "vendor_name",
        "registration_id",
        "vendor_status",
        "relationship_start_date",
    ],

    "vendor_name_history": [
        "vendor_name_history_id",
        "company_id",
        "vendor_id",
        "vendor_name",
        "effective_from",
        "recorded_at",
        "changed_by_employee_id",
        "change_reason",
    ],

    "expense_categories": [
        "category_id",
        "company_id",
        "category_name",
        "monthly_budget",
        "budget_currency",
    ],

    "bank_accounts": [
    "bank_account_id",
    "bank_name",
    "account_reference_token",
    "account_last4",
    "account_status",
],
"vendor_bank_accounts": [
    "vendor_bank_account_id",
    "company_id",
    "vendor_id",
    "bank_account_id",
    "effective_from",
    "authorization_status",
    "change_reason",
],

    "bank_account_history": [
        "bank_account_history_id",
        "company_id",
        "vendor_id",
        "old_bank_account_id",
        "new_bank_account_id",
        "changed_at",
        "changed_by_employee_id",
        "authorization_status",
        "change_reason",
    ],

    "payment_terms_history": [
        "payment_terms_history_id",
        "company_id",
        "vendor_id",
        "previous_payment_terms",
        "new_payment_terms",
        "changed_at",
        "changed_by_employee_id",
        "authorization_status",
        "change_reason",
    ],

    "purchase_orders": [
        "purchase_order_id",
        "company_id",
        "vendor_id",
        "po_number",
        "authorized_amount",
        "currency",
        "creation_date",
        "status",
    ],

    "purchase_order_history": [
        "purchase_order_history_id",
        "company_id",
        "purchase_order_id",
        "previous_authorized_amount",
        "new_authorized_amount",
        "changed_at",
        "changed_by_employee_id",
        "change_reason",
    ],

    "invoices": [
        "invoice_id",
        "company_id",
        "vendor_id",
        "vendor_invoice_number",
        "vendor_name_snapshot",
        "invoice_amount",
        "currency",
        "invoice_date",
        "submission_timestamp",
        "purchase_order_id",
        "category_id",
        "submitted_by_employee_id",
        "status",
    ],

    "invoice_submission_history": [
        "submission_history_id",
        "company_id",
        "invoice_id",
        "submission_number",
        "submitted_at",
        "submitted_by_employee_id",
        "submission_status",
    ],

    "invoice_status_history": [
        "invoice_status_history_id",
        "company_id",
        "invoice_id",
        "new_status",
        "changed_by_employee_id",
        "changed_at",
        "reason",
    ],

    "invoice_approval_history": [
        "approval_history_id",
        "company_id",
        "invoice_id",
        "approver_id",
        "approval_status",
    ],

    "invoice_risk_assessments": [
        "risk_assessment_id",
        "invoice_id",
        "assessment_version",
        "risk_score",
        "risk_level",
        "model_version",
        "ruleset_version",
        "assessment_status",
        "assessed_at",
    ],

    "invoice_detection_results": [
        "detection_result_id",
        "risk_assessment_id",
        "detection_type",
        "detection_name",
        "detection_source",
        "severity",
        "finding_score",
        "evidence",
        "created_at",
    ],

    "invoice_review_decisions": [
        "review_decision_id",
        "company_id",
        "invoice_id",
        "risk_assessment_id",
        "reviewer_employee_id",
        "decision",
        "decision_reason",
        "decided_at",
        "follow_up_status",
    ],
}


EXPECTED_DATA_TYPES = {

    "companies": {
        "company_id": "integer",
        "company_name": "string",
        "created_at": "datetime",
    },

    "employees": {
        "employee_id": "integer",
        "company_id": "integer",
        "employee_name": "string",
        "role": "string",
        "department": "string",
        "employee_status": "string",
        "approval_limit": "numeric",
        "approval_currency": "string",
    },

    "employee_authorization_history": {
        "authorization_history_id": "integer",
        "company_id": "integer",
        "employee_id": "integer",
        "authorization_role": "string",
        "approval_limit": "numeric",
        "approval_currency": "string",
        "effective_from": "datetime",
        "effective_to": "datetime",
        "changed_by_employee_id": "integer",
        "authorized_by_employee_id": "integer",
        "authorization_status": "string",
    },

    "vendors": {
        "vendor_id": "integer",
        "company_id": "integer",
        "vendor_name": "string",
        "registration_id": "string",
        "relationship_start_date": "datetime",
        "vendor_status": "string",
        "created_at": "datetime",
        "updated_at": "datetime",
    },

    "vendor_name_history": {
        "vendor_name_history_id": "integer",
        "company_id": "integer",
        "vendor_id": "integer",
        "vendor_name": "string",
        "effective_from": "datetime",
        "effective_to": "datetime",
        "recorded_at": "datetime",
        "changed_by_employee_id": "integer",
        "change_reason": "string",
    },

    "expense_categories": {
        "category_id": "integer",
        "company_id": "integer",
        "category_name": "string",
        "monthly_budget": "numeric",
        "budget_currency": "string",
    },

    "bank_accounts": {
    "bank_account_id": "integer",
    "bank_name": "string",
    "account_reference_token": "string",
    "account_last4": "string",
    "account_status": "string",
},

"vendor_bank_accounts": {
    "vendor_bank_account_id": "integer",
    "company_id": "integer",
    "vendor_id": "integer",
    "bank_account_id": "integer",
    "effective_from": "datetime",
    "effective_to": "datetime",
    "authorization_status": "string",
},

"vendor_bank_accounts": {
    "vendor_bank_account_id": "integer",
    "company_id": "integer",
    "vendor_id": "integer",
    "bank_account_id": "integer",
    "effective_from": "datetime",
    "effective_to": "datetime",
    "authorization_status": "string",
},

    "payment_terms_history": {
        "payment_terms_history_id": "integer",
        "company_id": "integer",
        "vendor_id": "integer",
        "previous_payment_terms": "string",
        "new_payment_terms": "string",
        "changed_at": "datetime",
        "changed_by_employee_id": "integer",
        "authorized_by_employee_id": "integer",
        "authorization_status": "string",
        "change_reason": "string",
    },

    "purchase_orders": {
        "purchase_order_id": "integer",
        "company_id": "integer",
        "vendor_id": "integer",
        "po_number": "string",
        "authorized_amount": "numeric",
        "currency": "string",
        "creation_date": "datetime",
        "status": "string",
        "expiration_date": "datetime",
    },

    "purchase_order_history": {
        "purchase_order_history_id": "integer",
        "company_id": "integer",
        "purchase_order_id": "integer",
        "previous_authorized_amount": "numeric",
        "new_authorized_amount": "numeric",
        "changed_at": "datetime",
        "changed_by_employee_id": "integer",
        "change_reason": "string",
    },

    "invoices": {
        "invoice_id": "integer",
        "company_id": "integer",
        "vendor_id": "integer",
        "vendor_invoice_number": "string",
        "vendor_name_snapshot": "string",
        "invoice_amount": "numeric",
        "currency": "string",
        "invoice_date": "datetime",
        "submission_timestamp": "datetime",
        "purchase_order_id": "integer",
        "category_id": "integer",
        "cost_code": "string",
        "payment_terms_snapshot": "string",
        "bank_account_reference_snapshot": "string",
        "submitted_by_employee_id": "integer",
        "status": "string",
        "created_at": "datetime",
        "updated_at": "datetime",
    },

    "invoice_submission_history": {
        "submission_history_id": "integer",
        "company_id": "integer",
        "invoice_id": "integer",
        "submission_number": "integer",
        "submitted_at": "datetime",
        "submitted_by_employee_id": "integer",
        "submission_status": "string",
        "rejection_reason": "string",
    },

    "invoice_status_history": {
        "invoice_status_history_id": "integer",
        "company_id": "integer",
        "invoice_id": "integer",
        "previous_status": "string",
        "new_status": "string",
        "changed_by_employee_id": "integer",
        "changed_at": "datetime",
        "reason": "string",
    },

    "invoice_approval_history": {
        "approval_history_id": "integer",
        "company_id": "integer",
        "invoice_id": "integer",
        "approver_id": "integer",
        "approval_status": "string",
        "approved_at": "datetime",
        "comments": "string",
    },

    "invoice_risk_assessments": {
        "risk_assessment_id": "integer",
        "invoice_id": "integer",
        "assessment_version": "integer",
        "risk_score": "numeric",
        "risk_level": "string",
        "model_version": "string",
        "ruleset_version": "string",
        "assessment_status": "string",
        "explanation": "string",
        "assessed_at": "datetime",
    },

    "invoice_detection_results": {
        "detection_result_id": "integer",
        "risk_assessment_id": "integer",
        "detection_type": "string",
        "detection_name": "string",
        "detection_source": "string",
        "severity": "string",
        "finding_score": "numeric",
        "created_at": "datetime",
    },

    "invoice_review_decisions": {
        "review_decision_id": "integer",
        "company_id": "integer",
        "invoice_id": "integer",
        "risk_assessment_id": "integer",
        "reviewer_employee_id": "integer",
        "decision": "string",
        "decision_reason": "string",
        "decided_at": "datetime",
        "follow_up_status": "string",
    },
}

PRIMARY_KEYS = {
    "companies": "company_id",

    "employees": "employee_id",

    "employee_authorization_history": "authorization_history_id",

    "vendors": "vendor_id",

    "vendor_name_history": "vendor_name_history_id",

    "expense_categories": "category_id",

    "bank_accounts": "bank_account_id",

    "vendor_bank_accounts": "vendor_bank_account_id",

    "bank_account_history": "bank_account_history_id",

    "payment_terms_history": "payment_terms_history_id",

    "purchase_orders": "purchase_order_id",

    "purchase_order_history": "purchase_order_history_id",

    "invoices": "invoice_id",

    "invoice_submission_history": "submission_history_id",

    "invoice_status_history": "invoice_status_history_id",

    "invoice_approval_history": "approval_history_id",

    "invoice_risk_assessments": "risk_assessment_id",

    "invoice_detection_results": "detection_result_id",

    "invoice_review_decisions": "review_decision_id",
}

VALID_STATUSES = {
    "invoices": [
        "PENDING",
        "CONFIRMED",
        "SCHEDULED",
        "PREPARING",
        "READY",
        "ASSIGNED",
        "OUT_FOR_DELIVERY",
        "DELIVERED",
        "CANCELLED",
    ],
}

def matches_expected_type(series, expected_type):

    if expected_type == "integer":
        return pd.api.types.is_integer_dtype(series)

    elif expected_type == "numeric":
        return pd.api.types.is_numeric_dtype(series)

    elif expected_type == "string":
        non_null_values = series.dropna()

        return non_null_values.map(
            lambda value: isinstance(value, str)
        ).all()

    elif expected_type == "datetime":
        return pd.api.types.is_datetime64_any_dtype(series)

    elif expected_type == "json":
        return pd.api.types.is_object_dtype(series)

    return False

def validate_data(table_name, df, all_tables):

    # 0. Handle invalid values

    validation_issues = []

    # Check required relationships
    
    for column, (reference_table, reference_column) in FOREIGN_KEYS.get(
        table_name, {}
    ).items():

        if column in df.columns and reference_table in all_tables:

            valid_ids = all_tables[reference_table][reference_column]

            invalid_records = df[
                df[column].notna()
                & ~df[column].isin(valid_ids)
            ]

            if not invalid_records.empty:

                validation_issues.append({
                    "table": table_name,
                    "column": column,
                    "issue": "Invalid foreign key",
                    "record_ids": invalid_records.index.tolist(),
                    "count": len(invalid_records),
                })

    # Preserve records; only report issues
    if validation_issues:
        print(f"\nValidation issues in {table_name}:")
        print(validation_issues)

    # 1. Check required columns exist

    required_columns = REQUIRED_COLUMNS.get(table_name, [])

    for col in required_columns:
        if col not in df.columns:
            print(f"Missing required column: {col}")
            validation_issues.append({
                "table": table_name,
                "column": col,
                "issue": "Missing column",
    })

        
    # 2. Check required fields are not missing

    required_fields = REQUIRED_FIELDS.get(table_name, [])
    
    for col in required_fields:
        if col not in df.columns:
            continue
        if df[col].isnull().any():
            missing_records = df[df[col].isnull()]
            print(f"Missing fields in: {col}")
            validation_issues.append({
                    "table": table_name,
                    "column": col,
                    "issue": "Missing fields",
                    "count" : len(missing_records)
    })

    # 3. Check expected data types

    expected_data_types = EXPECTED_DATA_TYPES.get(table_name, {})

    for col, expected_type in expected_data_types.items():

        if col not in df.columns:
            continue

        if not matches_expected_type(df[col], expected_type):
            print(f"Incorrect data type in: {col}")

            validation_issues.append({
                "table": table_name,
                "column": col,
                "issue": "Unexpected data type",
            })

    # 4. Check primary identifiers

    primary_key = PRIMARY_KEYS.get(table_name)

    if primary_key and primary_key in df.columns:

        # Check missing primary keys
        missing_ids = df[df[primary_key].isnull()]

        if not missing_ids.empty:
            validation_issues.append({
                "table": table_name,
                "column": primary_key,
                "issue": "Missing primary key",
                "count": len(missing_ids),
            })

        # Check duplicate primary keys
        duplicate_ids = df[df[primary_key].duplicated(keep=False)]

        if not duplicate_ids.empty:
            validation_issues.append({
                "table": table_name,
                "column": primary_key,
                "issue": "Duplicate primary key",
                "record_ids": duplicate_ids[primary_key].tolist(),
                "count": len(duplicate_ids),
            })

   # 5. Check business rules

    # Check invoice amounts
    if table_name == "invoices" and "invoice_amount" in df.columns:

        invalid_amounts = df[
            df["invoice_amount"].notna()
            & (df["invoice_amount"] <= 0)
        ]

        if not invalid_amounts.empty:
            validation_issues.append({
                "table": table_name,
                "column": "invoice_amount",
                "issue": "Invalid invoice amount",
                "record_ids": invalid_amounts["invoice_id"].tolist(),
                "count": len(invalid_amounts),
            })


    # Check valid statuses
    for column in ["status", "approval_status", "authorization_status"]:

        if column in df.columns and column in VALID_STATUSES.get(table_name, {}):

            invalid_statuses = df[
                df[column].notna()
                & ~df[column].isin(VALID_STATUSES[table_name])
            ]

            if not invalid_statuses.empty:
                validation_issues.append({
                    "table": table_name,
                    "column": column,
                    "issue": "Invalid status",
                    "record_ids": invalid_statuses[primary_key].tolist(),
                    "count": len(invalid_statuses),
                })


    # Check purchase order dates
    if table_name == "purchase_orders":

        if "creation_date" in df.columns and "expiration_date" in df.columns:

            invalid_dates = df[
                df["creation_date"].notna()
                & df["expiration_date"].notna()
                & (df["expiration_date"] < df["creation_date"])
            ]

            if not invalid_dates.empty:
                validation_issues.append({
                    "table": table_name,
                    "column": "expiration_date",
                    "issue": "Expiration date before creation date",
                    "record_ids": invalid_dates["purchase_order_id"].tolist(),
                    "count": len(invalid_dates),
                })

        
    # 6. Report validation results

   

    if validation_issues:
        print(f"\nValidation issues found in {table_name}:")

        for issue in validation_issues:
            print(issue)

    else:
        print(f"\n{table_name}: No validation issues found.")

    # 7. Return validation result

    return validation_issues