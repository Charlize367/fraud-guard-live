
## Additional Inspection Findings

### Duplicate Records

- No exact duplicate rows were found in any of the 19 tables.
- `invoices.vendor_invoice_number` contains 29 unique values across 30 invoices.
- `APX-DUP-77` appears twice. Preserve both records and flag the repeated invoice number for investigation.
- Preserve potential invoice splitting, shared bank accounts, purchase order/vendor mismatches, and recent bank changes as potential fraud indicators.

### Data Type Corrections

Review and convert the following columns after validating their values:

- `vendors.relationship_start_date` → datetime
- `purchase_orders.creation_date` → datetime
- `purchase_orders.expiration_date` → datetime
- `invoices.invoice_date` → datetime
- `employee_authorization_history.effective_to` → nullable datetime
- `vendor_name_history.effective_to` → nullable datetime
- `vendor_bank_accounts.effective_to` → nullable datetime

For nullable employee ID columns, consider Pandas nullable `Int64`:

- `employee_authorization_history.changed_by_employee_id`
- `employee_authorization_history.authorized_by_employee_id`
- `vendor_bank_accounts.changed_by_employee_id`
- `vendor_bank_accounts.authorized_by_employee_id`
- `bank_account_history.authorized_by_employee_id`
- `payment_terms_history.authorized_by_employee_id`

### ML Data Preservation and Leakage Prevention

- Preserve `invoice_risk_assessments`, `invoice_detection_results`, and `invoice_review_decisions` as audit/reference data.
- Do not automatically use existing risk scores, detection results, or review decisions as model input features.
- Do not treat synthetic review decisions as ground-truth fraud labels.
- Preserve JSONB/dictionary structures in `invoice_detection_results.evidence`.
- Preserve suspicious invoice patterns rather than deleting them.

### General Inspection Results

- All 19 tables loaded successfully.
- No exact duplicate rows were detected.
- Most tables have no missing values.
- No automatic filling or deletion of missing values is approved by this inspection alone.
- Relational integrity, date consistency, status validity, and suspicious business-rule violations still need validation.
