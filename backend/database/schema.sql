-- =====================================================
-- FRAUD GUARD LIVE
-- PostgreSQL Database Schema (v1.1)
-- =====================================================
-- Conventions: money = NUMERIC(18,2) + ISO currency; timestamps = TIMESTAMPTZ (UTC);
-- effective ranges: inclusive effective_from, exclusive effective_to, NULL = current.
--
-- TENANT ISOLATION: companies is the tenant table. Every tenant-owned table carries
-- company_id and references parents through COMPOSITE foreign keys
-- (company_id, <parent_id>), so a row can never point at a record of another company.
-- Optional references (e.g. changed_by_employee_id) are skipped when NULL (MATCH SIMPLE).

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- for overlap exclusion constraint

-- 1. COMPANIES
CREATE TABLE companies (
    company_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. EMPLOYEES
CREATE TABLE employees (
    employee_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    employee_name VARCHAR(200) NOT NULL,
    role VARCHAR(80) NOT NULL,
    department VARCHAR(100),
    employee_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    approval_limit NUMERIC(18,2),
    approval_currency CHAR(3),

    CONSTRAINT fk_employee_company FOREIGN KEY (company_id) REFERENCES companies(company_id),
    CONSTRAINT uq_employee_company UNIQUE (company_id, employee_id),
    CONSTRAINT chk_employee_status CHECK (employee_status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT chk_employee_approval_limit CHECK (approval_limit IS NULL OR approval_limit >= 0),
    CONSTRAINT chk_employee_limit_currency CHECK (approval_limit IS NULL OR approval_currency IS NOT NULL)
);

-- 3. EMPLOYEE AUTHORIZATION HISTORY
CREATE TABLE employee_authorization_history (
    authorization_history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    authorization_role VARCHAR(80) NOT NULL,
    approval_limit NUMERIC(18,2),
    approval_currency CHAR(3),
    effective_from TIMESTAMPTZ NOT NULL,
    effective_to TIMESTAMPTZ,
    changed_by_employee_id BIGINT,
    authorized_by_employee_id BIGINT,
    authorization_status VARCHAR(20) NOT NULL,

    CONSTRAINT fk_authorization_employee
        FOREIGN KEY (company_id, employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT fk_authorization_changed_by
        FOREIGN KEY (company_id, changed_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT fk_authorization_authorized_by
        FOREIGN KEY (company_id, authorized_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT chk_authorization_status CHECK (authorization_status IN ('PENDING', 'APPROVED', 'REVOKED')),
    CONSTRAINT chk_authorization_limit CHECK (approval_limit IS NULL OR approval_limit >= 0),
    CONSTRAINT chk_authorization_limit_currency CHECK (approval_limit IS NULL OR approval_currency IS NOT NULL),
    CONSTRAINT chk_authorization_no_self_authorize
        CHECK (authorized_by_employee_id IS NULL OR authorized_by_employee_id <> employee_id),
    CONSTRAINT chk_authorization_dates CHECK (effective_to IS NULL OR effective_to > effective_from)
);

-- 4. VENDORS
CREATE TABLE vendors (
    vendor_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    vendor_name VARCHAR(200) NOT NULL,
    registration_id VARCHAR(100),
    relationship_start_date DATE NOT NULL,
    vendor_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_vendor_company FOREIGN KEY (company_id) REFERENCES companies(company_id),
    CONSTRAINT uq_vendor_company UNIQUE (company_id, vendor_id),
    CONSTRAINT chk_vendor_status CHECK (vendor_status IN ('ACTIVE', 'INACTIVE', 'BLOCKED'))
);

-- 5. VENDOR NAME HISTORY (append-only)
CREATE TABLE vendor_name_history (
    vendor_name_history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    vendor_name VARCHAR(200) NOT NULL,
    effective_from TIMESTAMPTZ NOT NULL,
    effective_to TIMESTAMPTZ,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_employee_id BIGINT,
    change_reason TEXT,

    CONSTRAINT fk_vendor_name_history_vendor
        FOREIGN KEY (company_id, vendor_id) REFERENCES vendors(company_id, vendor_id),
    CONSTRAINT fk_vendor_name_history_employee
        FOREIGN KEY (company_id, changed_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT chk_vendor_name_dates CHECK (effective_to IS NULL OR effective_to > effective_from)
);

-- 6. EXPENSE CATEGORIES
CREATE TABLE expense_categories (
    category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    category_name VARCHAR(120) NOT NULL,
    monthly_budget NUMERIC(18,2),
    budget_currency CHAR(3),

    CONSTRAINT fk_category_company FOREIGN KEY (company_id) REFERENCES companies(company_id),
    CONSTRAINT uq_category_company UNIQUE (company_id, category_id),
    CONSTRAINT uq_company_category UNIQUE (company_id, category_name),
    CONSTRAINT chk_category_budget CHECK (monthly_budget IS NULL OR monthly_budget >= 0),
    CONSTRAINT chk_category_budget_currency CHECK (monthly_budget IS NULL OR budget_currency IS NOT NULL)
);

-- 7. BANK ACCOUNTS (no raw account numbers: token / keyed hash + masked suffix only)
-- NOTE: intentionally global (not tenant-owned). See notes at end of reply/README.
CREATE TABLE bank_accounts (
    bank_account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bank_name VARCHAR(150),
    account_reference_token VARCHAR(255) NOT NULL UNIQUE,
    account_last4 CHAR(4),
    account_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_bank_account_status CHECK (account_status IN ('ACTIVE', 'INACTIVE'))
);

-- 8. VENDOR BANK ACCOUNTS (many-to-many, effective-dated)
CREATE TABLE vendor_bank_accounts (
    vendor_bank_account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    bank_account_id BIGINT NOT NULL,
    effective_from TIMESTAMPTZ NOT NULL,
    effective_to TIMESTAMPTZ,
    authorization_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    changed_by_employee_id BIGINT,
    authorized_by_employee_id BIGINT,
    change_reason TEXT,

    CONSTRAINT fk_vendor_bank_vendor
        FOREIGN KEY (company_id, vendor_id) REFERENCES vendors(company_id, vendor_id),
    CONSTRAINT fk_vendor_bank_account FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(bank_account_id),
    CONSTRAINT fk_vendor_bank_changed_by
        FOREIGN KEY (company_id, changed_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT fk_vendor_bank_authorized_by
        FOREIGN KEY (company_id, authorized_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT chk_vendor_bank_authorization CHECK (authorization_status IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT chk_vendor_bank_dates CHECK (effective_to IS NULL OR effective_to > effective_from),
    CONSTRAINT ex_vendor_bank_no_overlap EXCLUDE USING gist (
        vendor_id WITH =,
        bank_account_id WITH =,
        tstzrange(effective_from, effective_to, '[)') WITH &&
    ) WHERE (authorization_status <> 'REJECTED')
);

-- 9. BANK ACCOUNT HISTORY (append-only)
CREATE TABLE bank_account_history (
    bank_account_history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    old_bank_account_id BIGINT,
    new_bank_account_id BIGINT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_employee_id BIGINT,
    authorized_by_employee_id BIGINT,
    authorization_status VARCHAR(20) NOT NULL,
    change_reason TEXT,

    CONSTRAINT fk_bank_history_vendor
        FOREIGN KEY (company_id, vendor_id) REFERENCES vendors(company_id, vendor_id),
    CONSTRAINT fk_bank_history_old_account FOREIGN KEY (old_bank_account_id) REFERENCES bank_accounts(bank_account_id),
    CONSTRAINT fk_bank_history_new_account FOREIGN KEY (new_bank_account_id) REFERENCES bank_accounts(bank_account_id),
    CONSTRAINT fk_bank_history_changed_by
        FOREIGN KEY (company_id, changed_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT fk_bank_history_authorized_by
        FOREIGN KEY (company_id, authorized_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT chk_bank_history_authorization CHECK (authorization_status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

-- 10. PAYMENT TERMS HISTORY (append-only)
CREATE TABLE payment_terms_history (
    payment_terms_history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    previous_payment_terms VARCHAR(100),
    new_payment_terms VARCHAR(100) NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_employee_id BIGINT,
    authorized_by_employee_id BIGINT,
    authorization_status VARCHAR(20) NOT NULL,
    change_reason TEXT,

    CONSTRAINT fk_payment_terms_vendor
        FOREIGN KEY (company_id, vendor_id) REFERENCES vendors(company_id, vendor_id),
    CONSTRAINT fk_payment_terms_changed_by
        FOREIGN KEY (company_id, changed_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT fk_payment_terms_authorized_by
        FOREIGN KEY (company_id, authorized_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT chk_payment_terms_authorization CHECK (authorization_status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

-- 11. PURCHASE ORDERS
CREATE TABLE purchase_orders (
    purchase_order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    po_number VARCHAR(120) NOT NULL,
    authorized_amount NUMERIC(18,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    creation_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    expiration_date DATE,

    CONSTRAINT fk_purchase_order_vendor
        FOREIGN KEY (company_id, vendor_id) REFERENCES vendors(company_id, vendor_id),
    CONSTRAINT uq_purchase_order_company UNIQUE (company_id, purchase_order_id),
    CONSTRAINT uq_purchase_order_vendor_number UNIQUE (vendor_id, po_number),
    CONSTRAINT chk_purchase_order_amount CHECK (authorized_amount >= 0),
    CONSTRAINT chk_purchase_order_status CHECK (status IN (
        'DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'ACTIVE', 'CLOSED', 'CANCELLED', 'EXPIRED'
    )),
    CONSTRAINT chk_purchase_order_dates CHECK (expiration_date IS NULL OR expiration_date >= creation_date)
);

-- 12. PURCHASE ORDER HISTORY (append-only)
CREATE TABLE purchase_order_history (
    purchase_order_history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    purchase_order_id BIGINT NOT NULL,
    previous_authorized_amount NUMERIC(18,2),
    new_authorized_amount NUMERIC(18,2),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_employee_id BIGINT,
    change_reason TEXT,

    CONSTRAINT fk_po_history_order
        FOREIGN KEY (company_id, purchase_order_id) REFERENCES purchase_orders(company_id, purchase_order_id),
    CONSTRAINT fk_po_history_employee
        FOREIGN KEY (company_id, changed_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT chk_po_history_amounts CHECK (
        (new_authorized_amount IS NULL OR new_authorized_amount >= 0)
        AND (previous_authorized_amount IS NULL OR previous_authorized_amount >= 0)
    )
);

-- 13. INVOICES
-- vendor_invoice_number is intentionally NOT unique: possible duplicates are retained and flagged.
-- A PO from a different vendor is NOT blocked (that is a detection signal), but it must be same-company.
CREATE TABLE invoices (
    invoice_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    vendor_invoice_number VARCHAR(120) NOT NULL,
    vendor_name_snapshot VARCHAR(200) NOT NULL,
    invoice_amount NUMERIC(18,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    invoice_date DATE NOT NULL,
    submission_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    purchase_order_id BIGINT,
    category_id BIGINT,
    cost_code VARCHAR(80),
    payment_terms_snapshot VARCHAR(100),
    bank_account_id BIGINT,
    bank_account_reference_snapshot VARCHAR(255),
    submitted_by_employee_id BIGINT,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_invoice_vendor
        FOREIGN KEY (company_id, vendor_id) REFERENCES vendors(company_id, vendor_id),
    CONSTRAINT fk_invoice_purchase_order
        FOREIGN KEY (company_id, purchase_order_id) REFERENCES purchase_orders(company_id, purchase_order_id),
    CONSTRAINT fk_invoice_category
        FOREIGN KEY (company_id, category_id) REFERENCES expense_categories(company_id, category_id),
    CONSTRAINT fk_invoice_bank_account FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(bank_account_id),
    CONSTRAINT fk_invoice_submitter
        FOREIGN KEY (company_id, submitted_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT uq_invoice_company UNIQUE (company_id, invoice_id),
    CONSTRAINT chk_invoice_amount CHECK (invoice_amount >= 0),
    CONSTRAINT chk_invoice_status CHECK (status IN (
        'PENDING', 'UNDER_REVIEW', 'APPROVED', 'ON_HOLD', 'PAID', 'REJECTED', 'CANCELLED'
    ))
);

-- 14. INVOICE SUBMISSION HISTORY
CREATE TABLE invoice_submission_history (
    submission_history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    invoice_id BIGINT NOT NULL,
    submission_number INTEGER NOT NULL,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    submitted_by_employee_id BIGINT,
    submission_status VARCHAR(20) NOT NULL,
    rejection_reason TEXT,

    CONSTRAINT fk_submission_invoice
        FOREIGN KEY (company_id, invoice_id) REFERENCES invoices(company_id, invoice_id),
    CONSTRAINT fk_submission_employee
        FOREIGN KEY (company_id, submitted_by_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT uq_invoice_submission_number UNIQUE (invoice_id, submission_number),
    CONSTRAINT chk_submission_number CHECK (submission_number > 0),
    CONSTRAINT chk_submission_status CHECK (submission_status IN ('SUBMITTED', 'REJECTED', 'RESUBMITTED'))
);

-- 15. INVOICE STATUS HISTORY (append-only)
CREATE TABLE invoice_status_history (
    invoice_status_history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    invoice_id BIGINT NOT NULL,
    previous_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by_employee_id BIGINT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,

    CONSTRAINT fk_status_history_invoice
        FOREIGN KEY (company_id, invoice_id) REFERENCES invoices(company_id, invoice_id),
    CONSTRAINT fk_status_history_employee
        FOREIGN KEY (company_id, changed_by_employee_id) REFERENCES employees(company_id, employee_id)
);

-- 16. INVOICE APPROVAL HISTORY
CREATE TABLE invoice_approval_history (
    approval_history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    invoice_id BIGINT NOT NULL,
    approver_id BIGINT NOT NULL,
    approval_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    approved_at TIMESTAMPTZ,
    comments TEXT,

    CONSTRAINT fk_approval_invoice
        FOREIGN KEY (company_id, invoice_id) REFERENCES invoices(company_id, invoice_id),
    CONSTRAINT fk_approval_employee
        FOREIGN KEY (company_id, approver_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT chk_approval_status CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

-- 17. INVOICE RISK ASSESSMENTS (tenant-scoped through invoice_id)
CREATE TABLE invoice_risk_assessments (
    risk_assessment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    assessment_version INTEGER NOT NULL,
    risk_score NUMERIC(5,2) NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    model_version VARCHAR(80),          -- NULL for rule-only assessments
    ruleset_version VARCHAR(80),
    assessment_status VARCHAR(30) NOT NULL DEFAULT 'COMPLETED',
    explanation TEXT,
    assessed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_assessment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    CONSTRAINT uq_invoice_assessment_version UNIQUE (invoice_id, assessment_version),
    CONSTRAINT uq_assessment_invoice_pair UNIQUE (risk_assessment_id, invoice_id),  -- target for review FK
    CONSTRAINT chk_assessment_version CHECK (assessment_version > 0),
    CONSTRAINT chk_risk_score CHECK (risk_score >= 0 AND risk_score <= 100),
    CONSTRAINT chk_risk_level CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_assessment_status CHECK (assessment_status IN ('COMPLETED', 'FAILED', 'SUPERSEDED'))
);

-- 18. INVOICE DETECTION RESULTS (zero or many findings per assessment)
CREATE TABLE invoice_detection_results (
    detection_result_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    risk_assessment_id BIGINT NOT NULL,
    detection_type VARCHAR(100) NOT NULL,   -- machine identifier, e.g. DUPLICATE_PATTERN
    detection_name VARCHAR(150) NOT NULL,   -- human-readable finding name
    detection_source VARCHAR(20) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    finding_score NUMERIC(5,2),
    evidence JSONB NOT NULL,                -- no secrets or raw bank data
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_detection_assessment FOREIGN KEY (risk_assessment_id) REFERENCES invoice_risk_assessments(risk_assessment_id),
    CONSTRAINT chk_detection_source CHECK (detection_source IN ('RULE', 'ML', 'HYBRID')),
    CONSTRAINT chk_detection_severity CHECK (severity IN ('INFO', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_finding_score CHECK (finding_score IS NULL OR (finding_score >= 0 AND finding_score <= 100))
);

-- 19. INVOICE REVIEW DECISIONS
-- The (risk_assessment_id, invoice_id) FK guarantees the assessment belongs to the same invoice.
CREATE TABLE invoice_review_decisions (
    review_decision_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL,
    invoice_id BIGINT NOT NULL,
    risk_assessment_id BIGINT,
    reviewer_employee_id BIGINT NOT NULL,
    decision VARCHAR(20) NOT NULL,
    decision_reason TEXT NOT NULL,
    decided_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    follow_up_status VARCHAR(30),

    CONSTRAINT fk_review_invoice
        FOREIGN KEY (company_id, invoice_id) REFERENCES invoices(company_id, invoice_id),
    CONSTRAINT fk_review_assessment
        FOREIGN KEY (risk_assessment_id, invoice_id) REFERENCES invoice_risk_assessments(risk_assessment_id, invoice_id),
    CONSTRAINT fk_review_employee
        FOREIGN KEY (company_id, reviewer_employee_id) REFERENCES employees(company_id, employee_id),
    CONSTRAINT chk_review_decision CHECK (decision IN ('APPROVE', 'REJECT', 'ESCALATE', 'REQUEST_INFO')),
    CONSTRAINT chk_review_follow_up CHECK (follow_up_status IS NULL OR follow_up_status IN (
        'OPEN', 'IN_PROGRESS', 'AWAITING_INFO', 'RESOLVED', 'CLOSED'
    ))
);

-- =====================================================
-- APPEND-ONLY ENFORCEMENT FOR AUDIT/HISTORY TABLES
-- =====================================================

CREATE OR REPLACE FUNCTION prevent_history_mutation() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION '% is append-only; insert a correction event instead', TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t TEXT;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'vendor_name_history', 'bank_account_history', 'payment_terms_history',
        'purchase_order_history', 'invoice_status_history'
    ] LOOP
        EXECUTE format(
            'CREATE TRIGGER trg_%I_append_only BEFORE UPDATE OR DELETE ON %I
             FOR EACH ROW EXECUTE FUNCTION prevent_history_mutation()', t, t);
    END LOOP;
END $$;

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_employees_company ON employees(company_id);
CREATE INDEX idx_employee_auth_history_employee ON employee_authorization_history(company_id, employee_id, effective_from, effective_to);
CREATE INDEX idx_vendors_company ON vendors(company_id);
CREATE INDEX idx_expense_categories_company ON expense_categories(company_id);
CREATE INDEX idx_vendor_name_history_vendor ON vendor_name_history(company_id, vendor_id);
CREATE INDEX idx_vendor_bank_accounts_vendor ON vendor_bank_accounts(company_id, vendor_id);
CREATE INDEX idx_vendor_bank_accounts_bank ON vendor_bank_accounts(bank_account_id, effective_from, effective_to);
CREATE INDEX idx_bank_account_history_vendor ON bank_account_history(company_id, vendor_id, changed_at);
CREATE INDEX idx_payment_terms_history_vendor ON payment_terms_history(company_id, vendor_id, changed_at);
CREATE INDEX idx_purchase_orders_vendor ON purchase_orders(company_id, vendor_id);
CREATE INDEX idx_po_history_order ON purchase_order_history(company_id, purchase_order_id, changed_at);
CREATE INDEX idx_invoices_company ON invoices(company_id);
CREATE INDEX idx_invoices_vendor ON invoices(company_id, vendor_id);
CREATE INDEX idx_invoices_status ON invoices(company_id, status);
CREATE INDEX idx_invoices_invoice_date ON invoices(invoice_date);
CREATE INDEX idx_invoices_vendor_number ON invoices(vendor_id, vendor_invoice_number);
CREATE INDEX idx_invoices_submission_timestamp ON invoices(submission_timestamp);
CREATE INDEX idx_submission_history_invoice ON invoice_submission_history(company_id, invoice_id);
CREATE INDEX idx_status_history_invoice ON invoice_status_history(company_id, invoice_id);
CREATE INDEX idx_approval_history_invoice ON invoice_approval_history(company_id, invoice_id);
CREATE INDEX idx_risk_assessments_invoice ON invoice_risk_assessments(invoice_id, assessed_at);
CREATE INDEX idx_detection_results_assessment ON invoice_detection_results(risk_assessment_id);
CREATE INDEX idx_review_decisions_invoice ON invoice_review_decisions(company_id, invoice_id);

-- =====================================================
-- END OF SCHEMA
-- =====================================================