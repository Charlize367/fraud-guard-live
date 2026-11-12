BEGIN;

-- Prevent accidental duplicate seeding.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM companies)
       OR EXISTS (SELECT 1 FROM invoices) THEN
        RAISE EXCEPTION
        'Database is not empty. Seed cancelled.';
    END IF;
END $$;

-- =====================================================
-- 1. COMPANIES
-- =====================================================

INSERT INTO companies (company_name) VALUES
('Northstar Manufacturing Ltd.'),
('Harborview Retail Group');

-- =====================================================
-- 2. EMPLOYEES
-- =====================================================

INSERT INTO employees
(company_id, employee_name, role, department, approval_limit, approval_currency)
SELECT c.company_id, x.employee_name, x.role, x.department,
       x.approval_limit, 'USD'
FROM (VALUES
('Northstar Manufacturing Ltd.','Maya Chen','FINANCE_MANAGER','Finance',50000::numeric),
('Northstar Manufacturing Ltd.','Daniel Reyes','AP_MANAGER','Accounts Payable',15000::numeric),
('Northstar Manufacturing Ltd.','Olivia Brooks','PROCUREMENT_MANAGER','Procurement',30000::numeric),
('Northstar Manufacturing Ltd.','Ethan Cole','FINANCE_ANALYST','Finance',5000::numeric),
('Harborview Retail Group','Ava Patel','FINANCE_MANAGER','Finance',50000::numeric),
('Harborview Retail Group','Noah Williams','AP_MANAGER','Accounts Payable',15000::numeric),
('Harborview Retail Group','Sophia Garcia','PROCUREMENT_MANAGER','Procurement',30000::numeric),
('Harborview Retail Group','Liam Turner','FINANCE_ANALYST','Finance',5000::numeric)
) AS x(company_name,employee_name,role,department,approval_limit)
JOIN companies c ON c.company_name=x.company_name;

-- =====================================================
-- 3. EMPLOYEE AUTHORIZATION HISTORY
-- =====================================================

INSERT INTO employee_authorization_history
(company_id,employee_id,authorization_role,approval_limit,
 approval_currency,effective_from,changed_by_employee_id,
 authorized_by_employee_id,authorization_status)
SELECT e.company_id,e.employee_id,e.role,e.approval_limit,
       e.approval_currency,'2026-01-01 00:00:00+00',
       CASE WHEN e.role='FINANCE_MANAGER' THEN NULL ELSE m.employee_id END,
       CASE WHEN e.role='FINANCE_MANAGER' THEN NULL ELSE m.employee_id END,
       'APPROVED'
FROM employees e
LEFT JOIN employees m
  ON m.company_id=e.company_id
 AND m.role='FINANCE_MANAGER';

-- =====================================================
-- 4. VENDORS
-- =====================================================

INSERT INTO vendors
(company_id,vendor_name,registration_id,relationship_start_date)
SELECT c.company_id,x.vendor_name,x.registration_id,x.start_date::date
FROM (VALUES
('Northstar Manufacturing Ltd.','Apex Industrial Supply','NS-1001','2021-03-15'),
('Northstar Manufacturing Ltd.','BluePeak Logistics','NS-1002','2022-01-10'),
('Northstar Manufacturing Ltd.','Cedar Maintenance Co.','NS-1003','2020-07-01'),
('Northstar Manufacturing Ltd.','Delta Office Systems','NS-1004','2023-02-20'),
('Northstar Manufacturing Ltd.','Evergreen Components','NS-1005','2021-11-05'),
('Harborview Retail Group','Fairway Wholesale','HR-2001','2020-05-12'),
('Harborview Retail Group','Granite Store Services','HR-2002','2022-09-01'),
('Harborview Retail Group','Highline Media','HR-2003','2023-04-18'),
('Harborview Retail Group','Indigo Technology','HR-2004','2021-06-30'),
('Harborview Retail Group','Juniper Facilities','HR-2005','2022-12-01')
) AS x(company_name,vendor_name,registration_id,start_date)
JOIN companies c ON c.company_name=x.company_name;

-- =====================================================
-- 5. VENDOR NAME HISTORY
-- =====================================================

INSERT INTO vendor_name_history
(company_id,vendor_id,vendor_name,effective_from,
 changed_by_employee_id,change_reason)
SELECT v.company_id,v.vendor_id,v.vendor_name,
       '2025-01-01 00:00:00+00',e.employee_id,
       'Initial registered vendor name'
FROM vendors v
JOIN employees e
  ON e.company_id=v.company_id
 AND e.role='PROCUREMENT_MANAGER';

-- =====================================================
-- 6. EXPENSE CATEGORIES
-- =====================================================

INSERT INTO expense_categories
(company_id,category_name,monthly_budget,budget_currency)
SELECT c.company_id,x.category_name,x.budget,'USD'
FROM (VALUES
('Northstar Manufacturing Ltd.','Raw Materials',120000::numeric),
('Northstar Manufacturing Ltd.','Logistics',40000::numeric),
('Northstar Manufacturing Ltd.','Maintenance',25000::numeric),
('Northstar Manufacturing Ltd.','IT Services',30000::numeric),
('Northstar Manufacturing Ltd.','Office Supplies',8000::numeric),
('Harborview Retail Group','Inventory',150000::numeric),
('Harborview Retail Group','Store Operations',45000::numeric),
('Harborview Retail Group','Marketing',35000::numeric),
('Harborview Retail Group','Technology',30000::numeric),
('Harborview Retail Group','Facilities',25000::numeric)
) AS x(company_name,category_name,budget)
JOIN companies c ON c.company_name=x.company_name;

-- =====================================================
-- 7. BANK ACCOUNTS
-- These are fake tokens, not real account numbers.
-- =====================================================

INSERT INTO bank_accounts
(bank_name,account_reference_token,account_last4)
VALUES
('First National Bank','tok_demo_apex_001','4101'),
('Metro Commercial Bank','tok_demo_bluepeak_002','5202'),
('Union Trust','tok_demo_cedar_003','6303'),
('First National Bank','tok_demo_delta_004','7404'),
('Metro Commercial Bank','tok_demo_evergreen_005','8505'),
('Union Trust','tok_demo_fairway_006','9606'),
('First National Bank','tok_demo_granite_007','1707'),
('Metro Commercial Bank','tok_demo_highline_008','2808'),
('Union Trust','tok_demo_indigo_009','3909'),
('First National Bank','tok_demo_juniper_010','4010');

-- =====================================================
-- 8. VENDOR BANK ACCOUNTS
-- =====================================================

INSERT INTO vendor_bank_accounts
(company_id,vendor_id,bank_account_id,effective_from,
 authorization_status,changed_by_employee_id,
 authorized_by_employee_id,change_reason)
SELECT c.company_id,v.vendor_id,b.bank_account_id,
       '2025-01-01 00:00:00+00','APPROVED',
       changer.employee_id,approver.employee_id,
       'Initial verified bank account'
FROM (VALUES
('Northstar Manufacturing Ltd.','Apex Industrial Supply','tok_demo_apex_001'),
('Northstar Manufacturing Ltd.','BluePeak Logistics','tok_demo_bluepeak_002'),
('Northstar Manufacturing Ltd.','Cedar Maintenance Co.','tok_demo_cedar_003'),
('Northstar Manufacturing Ltd.','Delta Office Systems','tok_demo_delta_004'),
('Northstar Manufacturing Ltd.','Evergreen Components','tok_demo_evergreen_005'),
('Harborview Retail Group','Fairway Wholesale','tok_demo_fairway_006'),
('Harborview Retail Group','Granite Store Services','tok_demo_granite_007'),
('Harborview Retail Group','Highline Media','tok_demo_highline_008'),
('Harborview Retail Group','Indigo Technology','tok_demo_indigo_009'),
('Harborview Retail Group','Juniper Facilities','tok_demo_juniper_010')
) x(company_name,vendor_name,token)
JOIN companies c ON c.company_name=x.company_name
JOIN vendors v ON v.company_id=c.company_id AND v.vendor_name=x.vendor_name
JOIN bank_accounts b ON b.account_reference_token=x.token
JOIN employees changer ON changer.company_id=c.company_id AND changer.role='AP_MANAGER'
JOIN employees approver ON approver.company_id=c.company_id AND approver.role='FINANCE_MANAGER';

-- Shared account scenario: Granite shares Apex's bank account.
INSERT INTO vendor_bank_accounts
(company_id,vendor_id,bank_account_id,effective_from,
 authorization_status,change_reason)
SELECT c.company_id,v.vendor_id,b.bank_account_id,
       '2026-01-01 00:00:00+00','APPROVED',
       'Synthetic shared bank account scenario'
FROM companies c
JOIN vendors v ON v.company_id=c.company_id
 AND v.vendor_name='Granite Store Services'
JOIN bank_accounts b
 ON b.account_reference_token='tok_demo_apex_001';

-- =====================================================
-- 9. PURCHASE ORDERS
-- =====================================================

INSERT INTO purchase_orders
(company_id,vendor_id,po_number,authorized_amount,currency,
 creation_date,status,expiration_date)
SELECT c.company_id,v.vendor_id,x.po_number,x.amount,
       'USD',x.created::date,'ACTIVE','2027-12-31'
FROM (VALUES
('Northstar Manufacturing Ltd.','Apex Industrial Supply','NS-PO-1001',25000::numeric,'2026-01-10'),
('Northstar Manufacturing Ltd.','BluePeak Logistics','NS-PO-1002',18000::numeric,'2026-02-01'),
('Northstar Manufacturing Ltd.','Cedar Maintenance Co.','NS-PO-1003',12000::numeric,'2026-02-15'),
('Northstar Manufacturing Ltd.','Delta Office Systems','NS-PO-1004',9000::numeric,'2026-03-01'),
('Northstar Manufacturing Ltd.','Evergreen Components','NS-PO-1005',30000::numeric,'2026-03-15'),
('Harborview Retail Group','Fairway Wholesale','HR-PO-2001',40000::numeric,'2026-01-12'),
('Harborview Retail Group','Granite Store Services','HR-PO-2002',14000::numeric,'2026-02-10'),
('Harborview Retail Group','Highline Media','HR-PO-2003',16000::numeric,'2026-02-20'),
('Harborview Retail Group','Indigo Technology','HR-PO-2004',22000::numeric,'2026-03-05'),
('Harborview Retail Group','Juniper Facilities','HR-PO-2005',11000::numeric,'2026-03-20')
) x(company_name,vendor_name,po_number,amount,created)
JOIN companies c ON c.company_name=x.company_name
JOIN vendors v ON v.company_id=c.company_id AND v.vendor_name=x.vendor_name;

-- =====================================================
-- 10. INVOICES
-- =====================================================

CREATE TEMP TABLE seed_invoice_data (
    invoice_number VARCHAR(120),
    company_name VARCHAR(255),
    vendor_name VARCHAR(200),
    amount NUMERIC(18,2),
    invoice_date DATE,
    po_number VARCHAR(120),
    category_name VARCHAR(120),
    bank_token VARCHAR(255),
    submitter_name VARCHAR(200),
    payment_terms VARCHAR(100),
    invoice_status VARCHAR(30)
) ON COMMIT DROP;

INSERT INTO seed_invoice_data VALUES
('APX-26001','Northstar Manufacturing Ltd.','Apex Industrial Supply',8200,'2026-08-01','NS-PO-1001','Raw Materials','tok_demo_apex_001','Ethan Cole','Net 30','PAID'),
('APX-26002','Northstar Manufacturing Ltd.','Apex Industrial Supply',7900,'2026-08-10','NS-PO-1001','Raw Materials','tok_demo_apex_001','Ethan Cole','Net 30','APPROVED'),
('APX-26003','Northstar Manufacturing Ltd.','Apex Industrial Supply',7800,'2026-08-18','NS-PO-1001','Raw Materials','tok_demo_apex_001','Ethan Cole','Net 30','APPROVED'),
('BPL-26001','Northstar Manufacturing Ltd.','BluePeak Logistics',4200,'2026-08-03','NS-PO-1002','Logistics','tok_demo_bluepeak_002','Daniel Reyes','Net 30','PAID'),
('BPL-26002','Northstar Manufacturing Ltd.','BluePeak Logistics',3900,'2026-08-14','NS-PO-1002','Logistics','tok_demo_bluepeak_002','Daniel Reyes','Net 30','APPROVED'),
('CED-26001','Northstar Manufacturing Ltd.','Cedar Maintenance Co.',2400,'2026-08-05','NS-PO-1003','Maintenance','tok_demo_cedar_003','Ethan Cole','Net 30','PAID'),
('CED-26002','Northstar Manufacturing Ltd.','Cedar Maintenance Co.',18500,'2026-09-01','NS-PO-1003','Maintenance','tok_demo_cedar_003','Daniel Reyes','Net 30','ON_HOLD'),
('DOS-26001','Northstar Manufacturing Ltd.','Delta Office Systems',1100,'2026-08-07','NS-PO-1004','Office Supplies','tok_demo_delta_004','Ethan Cole','Net 30','PAID'),
('DOS-26002','Northstar Manufacturing Ltd.','Delta Office Systems',1250,'2026-08-17','NS-PO-1004','Office Supplies','tok_demo_delta_004','Ethan Cole','Net 30','APPROVED'),
('EVG-26001','Northstar Manufacturing Ltd.','Evergreen Components',12500,'2026-08-09','NS-PO-1005','Raw Materials','tok_demo_evergreen_005','Daniel Reyes','Net 30','APPROVED'),
('EVG-26002','Northstar Manufacturing Ltd.','Evergreen Components',11800,'2026-08-20','NS-PO-1005','Raw Materials','tok_demo_evergreen_005','Ethan Cole','Net 30','APPROVED'),
('APX-DUP-77','Northstar Manufacturing Ltd.','Apex Industrial Supply',6400,'2026-09-03','NS-PO-1001','Raw Materials','tok_demo_apex_001','Ethan Cole','Net 30','UNDER_REVIEW'),
('APX-DUP-77','Northstar Manufacturing Ltd.','Apex Industrial Supply',6400,'2026-09-05','NS-PO-1001','Raw Materials','tok_demo_apex_001','Ethan Cole','Net 30','ON_HOLD'),
('BPL-SPLIT-01','Northstar Manufacturing Ltd.','BluePeak Logistics',4900,'2026-09-08','NS-PO-1002','Logistics','tok_demo_bluepeak_002','Ethan Cole','Net 30','UNDER_REVIEW'),
('BPL-SPLIT-02','Northstar Manufacturing Ltd.','BluePeak Logistics',4850,'2026-09-08','NS-PO-1002','Logistics','tok_demo_bluepeak_002','Ethan Cole','Net 30','UNDER_REVIEW'),
('CED-BANK-01','Northstar Manufacturing Ltd.','Cedar Maintenance Co.',7200,'2026-09-10','NS-PO-1003','Maintenance','tok_demo_apex_001','Daniel Reyes','Net 15','ON_HOLD'),
('DOS-PO-MISMATCH','Northstar Manufacturing Ltd.','Delta Office Systems',6800,'2026-09-12','NS-PO-1001','Office Supplies','tok_demo_delta_004','Ethan Cole','Net 30','UNDER_REVIEW'),
('EVG-26003','Northstar Manufacturing Ltd.','Evergreen Components',27500,'2026-09-15','NS-PO-1005','Raw Materials','tok_demo_evergreen_005','Daniel Reyes','Net 30','ON_HOLD'),
('APX-26004','Northstar Manufacturing Ltd.','Apex Industrial Supply',8100,'2026-09-18','NS-PO-1001','Raw Materials','tok_demo_apex_001','Ethan Cole','Net 30','APPROVED'),
('BPL-26003','Northstar Manufacturing Ltd.','BluePeak Logistics',4300,'2026-09-20','NS-PO-1002','Logistics','tok_demo_bluepeak_002','Daniel Reyes','Net 30','APPROVED'),
('FW-26001','Harborview Retail Group','Fairway Wholesale',14500,'2026-08-02','HR-PO-2001','Inventory','tok_demo_fairway_006','Liam Turner','Net 30','PAID'),
('FW-26002','Harborview Retail Group','Fairway Wholesale',13200,'2026-08-12','HR-PO-2001','Inventory','tok_demo_fairway_006','Noah Williams','Net 30','APPROVED'),
('GSS-26001','Harborview Retail Group','Granite Store Services',3100,'2026-08-04','HR-PO-2002','Store Operations','tok_demo_granite_007','Liam Turner','Net 30','PAID'),
('HLM-26001','Harborview Retail Group','Highline Media',5200,'2026-08-06','HR-PO-2003','Marketing','tok_demo_highline_008','Liam Turner','Net 30','APPROVED'),
('IND-26001','Harborview Retail Group','Indigo Technology',8900,'2026-08-08','HR-PO-2004','Technology','tok_demo_indigo_009','Noah Williams','Net 30','PAID'),
('JUN-26001','Harborview Retail Group','Juniper Facilities',2800,'2026-08-11','HR-PO-2005','Facilities','tok_demo_juniper_010','Liam Turner','Net 30','PAID'),
('GSS-SHARED-01','Harborview Retail Group','Granite Store Services',7600,'2026-09-02','HR-PO-2002','Store Operations','tok_demo_apex_001','Noah Williams','Net 30','UNDER_REVIEW'),
('HLM-26002','Harborview Retail Group','Highline Media',24500,'2026-09-07','HR-PO-2003','Marketing','tok_demo_highline_008','Noah Williams','Net 30','ON_HOLD'),
('IND-PO-MISMATCH','Harborview Retail Group','Indigo Technology',9700,'2026-09-14','HR-PO-2001','Technology','tok_demo_indigo_009','Liam Turner','Net 30','UNDER_REVIEW'),
('JUN-26002','Harborview Retail Group','Juniper Facilities',3400,'2026-09-19','HR-PO-2005','Facilities','tok_demo_juniper_010','Liam Turner','Net 30','APPROVED');

INSERT INTO invoices
(company_id,vendor_id,vendor_invoice_number,vendor_name_snapshot,
 invoice_amount,currency,invoice_date,submission_timestamp,
 purchase_order_id,category_id,cost_code,payment_terms_snapshot,
 bank_account_id,bank_account_reference_snapshot,submitted_by_employee_id,status)
SELECT c.company_id,v.vendor_id,s.invoice_number,v.vendor_name,
       s.amount,'USD',s.invoice_date,
       s.invoice_date::timestamp AT TIME ZONE 'UTC' + INTERVAL '1 day',
       po.purchase_order_id,cat.category_id,
       'DEMO-' || LEFT(cat.category_name,3),
       s.payment_terms,b.bank_account_id,b.account_reference_token,
       e.employee_id,s.invoice_status
FROM seed_invoice_data s
JOIN companies c ON c.company_name=s.company_name
JOIN vendors v ON v.company_id=c.company_id AND v.vendor_name=s.vendor_name
LEFT JOIN purchase_orders po ON po.company_id=c.company_id AND po.po_number=s.po_number
LEFT JOIN expense_categories cat ON cat.company_id=c.company_id AND cat.category_name=s.category_name
LEFT JOIN bank_accounts b ON b.account_reference_token=s.bank_token
LEFT JOIN employees e ON e.company_id=c.company_id AND e.employee_name=s.submitter_name;

-- =====================================================
-- 11. BANK ACCOUNT HISTORY
-- =====================================================

INSERT INTO bank_account_history
(company_id,vendor_id,old_bank_account_id,new_bank_account_id,
 changed_at,changed_by_employee_id,authorization_status,change_reason)
SELECT c.company_id,v.vendor_id,oldb.bank_account_id,newb.bank_account_id,
       '2026-09-09 14:00:00+00',e.employee_id,'PENDING',
       'Synthetic recent bank detail change awaiting authorization'
FROM companies c
JOIN vendors v ON v.company_id=c.company_id
 AND v.vendor_name='Cedar Maintenance Co.'
JOIN bank_accounts oldb ON oldb.account_reference_token='tok_demo_cedar_003'
JOIN bank_accounts newb ON newb.account_reference_token='tok_demo_apex_001'
JOIN employees e ON e.company_id=c.company_id AND e.role='AP_MANAGER';

-- =====================================================
-- 12. PAYMENT TERMS HISTORY
-- =====================================================

INSERT INTO payment_terms_history
(company_id,vendor_id,previous_payment_terms,new_payment_terms,
 changed_at,changed_by_employee_id,authorization_status,change_reason)
SELECT c.company_id,v.vendor_id,'Net 30','Net 15',
       '2026-09-09 14:05:00+00',e.employee_id,'PENDING',
       'Synthetic payment-term change'
FROM companies c
JOIN vendors v ON v.company_id=c.company_id
 AND v.vendor_name='Cedar Maintenance Co.'
JOIN employees e ON e.company_id=c.company_id AND e.role='AP_MANAGER';

-- =====================================================
-- 13. PURCHASE ORDER HISTORY
-- =====================================================

INSERT INTO purchase_order_history
(company_id,purchase_order_id,previous_authorized_amount,
 new_authorized_amount,changed_at,changed_by_employee_id,change_reason)
SELECT c.company_id,po.purchase_order_id,12000,20000,
       '2026-08-28 12:00:00+00',e.employee_id,
       'Synthetic purchase order amendment'
FROM companies c
JOIN purchase_orders po ON po.company_id=c.company_id
 AND po.po_number='NS-PO-1003'
JOIN employees e ON e.company_id=c.company_id
 AND e.role='PROCUREMENT_MANAGER';

-- =====================================================
-- 14. INVOICE SUBMISSION HISTORY
-- =====================================================

INSERT INTO invoice_submission_history
(company_id,invoice_id,submission_number,submitted_at,
 submitted_by_employee_id,submission_status)
SELECT company_id,invoice_id,1,submission_timestamp,
       submitted_by_employee_id,'SUBMITTED'
FROM invoices;

INSERT INTO invoice_submission_history
(company_id,invoice_id,submission_number,submitted_at,
 submitted_by_employee_id,submission_status,rejection_reason)
SELECT company_id,invoice_id,2,submission_timestamp + INTERVAL '1 day',
       submitted_by_employee_id,'RESUBMITTED',
       'Synthetic duplicate invoice resubmission'
FROM invoices
WHERE vendor_invoice_number='APX-DUP-77';

-- =====================================================
-- 15. INVOICE STATUS HISTORY
-- =====================================================

INSERT INTO invoice_status_history
(company_id,invoice_id,previous_status,new_status,
 changed_by_employee_id,reason)
SELECT company_id,invoice_id,NULL,status,
       submitted_by_employee_id,'Initial seeded invoice status'
FROM invoices;

-- =====================================================
-- 16. INVOICE APPROVAL HISTORY
-- =====================================================

INSERT INTO invoice_approval_history
(company_id,invoice_id,approver_id,approval_status,approved_at,comments)
SELECT i.company_id,i.invoice_id,e.employee_id,
       CASE WHEN i.status IN ('APPROVED','PAID') THEN 'APPROVED'
            WHEN i.status='REJECTED' THEN 'REJECTED'
            ELSE 'PENDING' END,
       CASE WHEN i.status IN ('APPROVED','PAID')
            THEN i.submission_timestamp + INTERVAL '2 days'
            ELSE NULL END,
       'Synthetic demonstration approval record'
FROM invoices i
JOIN employees e ON e.company_id=i.company_id
 AND e.role='FINANCE_MANAGER';

-- =====================================================
-- 17. INVOICE RISK ASSESSMENTS
-- =====================================================

INSERT INTO invoice_risk_assessments
(invoice_id,assessment_version,risk_score,risk_level,
 model_version,ruleset_version,assessment_status,explanation,assessed_at)
SELECT i.invoice_id,1,
       CASE
        WHEN i.vendor_invoice_number IN
        ('APX-DUP-77','BPL-SPLIT-01','BPL-SPLIT-02',
         'CED-BANK-01','DOS-PO-MISMATCH','GSS-SHARED-01',
         'IND-PO-MISMATCH') THEN 92
        WHEN i.invoice_amount>=20000 THEN 78
        WHEN i.status IN ('UNDER_REVIEW','ON_HOLD') THEN 65
        ELSE 12
       END,
       CASE
        WHEN i.vendor_invoice_number IN
        ('APX-DUP-77','BPL-SPLIT-01','BPL-SPLIT-02',
         'CED-BANK-01','DOS-PO-MISMATCH','GSS-SHARED-01',
         'IND-PO-MISMATCH') THEN 'CRITICAL'
        WHEN i.invoice_amount>=20000 THEN 'HIGH'
        WHEN i.status IN ('UNDER_REVIEW','ON_HOLD') THEN 'MEDIUM'
        ELSE 'LOW'
       END,
       'seed-demo-0.1','rules-demo-0.1','COMPLETED',
       'Synthetic illustrative risk assessment. Human review required.',
       i.submission_timestamp + INTERVAL '5 minutes'
FROM invoices i;

-- =====================================================
-- 18. INVOICE DETECTION RESULTS
-- =====================================================

-- Duplicate invoices
INSERT INTO invoice_detection_results
(risk_assessment_id,detection_type,detection_name,
 detection_source,severity,finding_score,evidence)
SELECT a.risk_assessment_id,'DUPLICATE_INVOICE',
       'Possible duplicate invoice number','RULE','CRITICAL',98,
       jsonb_build_object('invoice_number',i.vendor_invoice_number,
                          'vendor',v.vendor_name,
                          'note','Repeated invoice number')
FROM invoices i
JOIN vendors v ON v.vendor_id=i.vendor_id
JOIN invoice_risk_assessments a ON a.invoice_id=i.invoice_id
WHERE i.vendor_invoice_number='APX-DUP-77';

-- Unusually large invoices
INSERT INTO invoice_detection_results
(risk_assessment_id,detection_type,detection_name,
 detection_source,severity,finding_score,evidence)
SELECT a.risk_assessment_id,'UNUSUAL_AMOUNT',
       'Invoice amount unusually high','RULE','HIGH',82,
       jsonb_build_object('amount',i.invoice_amount,
                          'note','Amount exceeds demo review threshold')
FROM invoices i
JOIN invoice_risk_assessments a ON a.invoice_id=i.invoice_id
WHERE i.invoice_amount>=20000;

-- Possible invoice splitting
INSERT INTO invoice_detection_results
(risk_assessment_id,detection_type,detection_name,
 detection_source,severity,finding_score,evidence)
SELECT a.risk_assessment_id,'POSSIBLE_INVOICE_SPLITTING',
       'Multiple invoices near approval threshold','RULE','HIGH',86,
       jsonb_build_object('invoice_number',i.vendor_invoice_number,
                          'amount',i.invoice_amount)
FROM invoices i
JOIN invoice_risk_assessments a ON a.invoice_id=i.invoice_id
WHERE i.vendor_invoice_number IN ('BPL-SPLIT-01','BPL-SPLIT-02');

-- Recent bank account change
INSERT INTO invoice_detection_results
(risk_assessment_id,detection_type,detection_name,
 detection_source,severity,finding_score,evidence)
SELECT a.risk_assessment_id,'RECENT_BANK_CHANGE',
       'Invoice follows pending bank detail change',
       'RULE','CRITICAL',95,
       jsonb_build_object('note','Bank change pending authorization')
FROM invoices i
JOIN invoice_risk_assessments a ON a.invoice_id=i.invoice_id
WHERE i.vendor_invoice_number='CED-BANK-01';

-- Purchase order vendor mismatch
INSERT INTO invoice_detection_results
(risk_assessment_id,detection_type,detection_name,
 detection_source,severity,finding_score,evidence)
SELECT a.risk_assessment_id,'PO_VENDOR_MISMATCH',
       'Purchase order belongs to another vendor',
       'RULE','CRITICAL',96,
       jsonb_build_object('invoice_vendor',v.vendor_name,
                          'po_vendor',pv.vendor_name,
                          'po_number',po.po_number)
FROM invoices i
JOIN invoice_risk_assessments a ON a.invoice_id=i.invoice_id
JOIN vendors v ON v.vendor_id=i.vendor_id
JOIN purchase_orders po ON po.purchase_order_id=i.purchase_order_id
JOIN vendors pv ON pv.vendor_id=po.vendor_id
WHERE i.vendor_invoice_number IN
('DOS-PO-MISMATCH','IND-PO-MISMATCH')
AND i.vendor_id<>po.vendor_id;

-- Shared bank account
INSERT INTO invoice_detection_results
(risk_assessment_id,detection_type,detection_name,
 detection_source,severity,finding_score,evidence)
SELECT a.risk_assessment_id,'SHARED_BANK_ACCOUNT',
       'Bank account shared across vendors',
       'RULE','HIGH',90,
       jsonb_build_object('bank_token','tok_demo_apex_001',
                          'note','Account linked to multiple vendors')
FROM invoices i
JOIN invoice_risk_assessments a ON a.invoice_id=i.invoice_id
WHERE i.vendor_invoice_number='GSS-SHARED-01';

-- =====================================================
-- 19. INVOICE REVIEW DECISIONS
-- =====================================================

INSERT INTO invoice_review_decisions
(company_id,invoice_id,risk_assessment_id,reviewer_employee_id,
 decision,decision_reason,decided_at,follow_up_status)
SELECT i.company_id,i.invoice_id,a.risk_assessment_id,
       e.employee_id,
       CASE
        WHEN i.vendor_invoice_number IN ('APX-DUP-77','CED-BANK-01')
          THEN 'ESCALATE'
        ELSE 'REQUEST_INFO'
       END,
       'Synthetic review decision for workflow demonstration. Not a real fraud determination.',
       i.submission_timestamp + INTERVAL '1 hour',
       CASE
        WHEN i.vendor_invoice_number IN ('APX-DUP-77','CED-BANK-01')
          THEN 'IN_PROGRESS'
        ELSE 'AWAITING_INFO'
       END
FROM invoices i
JOIN invoice_risk_assessments a ON a.invoice_id=i.invoice_id
JOIN employees e ON e.company_id=i.company_id
 AND e.role='FINANCE_MANAGER'
WHERE i.vendor_invoice_number IN
('APX-DUP-77','BPL-SPLIT-01','BPL-SPLIT-02',
 'CED-BANK-01','DOS-PO-MISMATCH',
 'GSS-SHARED-01','IND-PO-MISMATCH');

COMMIT;