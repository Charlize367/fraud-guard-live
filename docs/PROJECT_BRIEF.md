# Fraud Guard Live — Project Brief

**Project type:** Full-Stack Software Engineering / Applied Machine Learning  
**Status:** In Development  
**Initial focus:** Supplier Invoice Fraud Detection and Risk Intelligence

## 1. Project Overview

Fraud Guard Live is an intelligent invoice risk detection and investigation platform designed to help organizations identify suspicious supplier invoices before payment.

The platform combines rule-based fraud detection, machine learning, historical transaction analysis, and a human review workflow to identify unusual invoice activity and prioritize potentially fraudulent transactions.

Rather than automatically declaring invoices fraudulent, the system provides risk scores, supporting evidence, and explanations that help finance teams make informed decisions.

## 2. The Problem

Organizations process large volumes of supplier invoices. Among legitimate transactions, suspicious activity can include duplicate invoices, unusual payment amounts, altered supplier bank details, invoice splitting, and abnormal purchasing patterns.

Traditional manual review can be time-consuming and may fail to identify subtle patterns across vendors and transactions.

Fraud Guard Live aims to help organizations detect suspicious activity earlier, prioritize investigations, and make invoice review more efficient.

## 3. Target Users

- Accounts Payable (AP) employees
- Finance teams
- Fraud investigators
- Procurement and internal audit teams
- Finance managers and authorized approvers

## 4. Project Objectives

1. Accept and validate supplier invoice submissions.
2. Maintain historical records of vendors and transactions.
3. Detect known suspicious patterns through configurable business rules.
4. Identify unusual transaction behavior using machine learning.
5. Generate invoice risk scores with supporting evidence.
6. Prioritize suspicious invoices for human investigation.
7. Provide reviewers with invoice history and investigation tools.
8. Record reviewer decisions for model evaluation and future improvement.

## 5. Initial Scope: Invoice Fraud Detection

### Core capabilities

- Invoice submission and validation.
- Vendor and transaction history management.
- Duplicate invoice detection.
- Suspicious transaction rule engine.
- ML-based anomaly detection.
- Invoice risk scoring and risk categorization.
- Review queue and investigation dashboard.
- Evidence and explanation display.
- Human review decisions and audit history.
- Model evaluation and performance reporting.

### Initial suspicious patterns

- Duplicate invoices.
- Unusually large invoices relative to vendor history.
- Multiple invoices just below approval thresholds.
- Unusual vendor, approver, or cost-code combinations.
- Suspicious bank-detail changes followed by large transactions.

These patterns will be implemented only when the required data is available or appropriately simulated.

### Long-term possibilities

- Accounting platform integrations.
- More advanced vendor relationship analysis.
- Graph-based fraud detection.
- Continuous model monitoring.
- Automated investigation prioritization.
- Additional financial risk intelligence capabilities.

These are future extensions, not first-release requirements.

## 6. Machine Learning Scope

The project will apply machine learning techniques where they meaningfully support the fraud detection problem.

| Technique | Intended application |
|---|---|
| Linear regression | Estimate expected invoice amounts and establish trend baselines |
| Logistic regression | Supervised baseline for invoice risk classification |
| K-means | Discover groups of vendors or transactions with similar behavior |
| Anomaly detection | Identify transactions that differ from normal patterns |
| PCA | Explore and reduce high-dimensional transaction features |
| Neural networks | Compare nonlinear classification against simpler models |
| Collaborative filtering | Experiment with identifying unusual patterns in vendor, employee, and approver interactions |
| Content-based filtering | Compare invoices based on their characteristics and similarity to historical transactions |

Not every algorithm is required in the first release. Techniques will only be included when the data and problem formulation support them.

Rules-based detection will serve as an important baseline alongside ML models.

Collaborative filtering and content-based filtering are exploratory techniques. Their suitability will be evaluated before considering implementation.

## 7. Data Sources

Initial data strategy:

- Public government procurement and spending datasets, such as USAspending.
- Public financial transaction datasets where suitable.
- Synthetic invoice records for fields not available in public datasets.
- Controlled synthetic fraud scenarios for testing and evaluation.

Important limitation: public spending records generally do not expose private supplier bank details, internal approval histories, or confirmed fraud labels.

Synthetic fields and injected fraud scenarios must be clearly documented. Simulated fraud detection must not be presented as proof of real-world fraud detection.

## 8. Technical Architecture

| Component | Technology |
|---|---|
| Frontend | React |
| Main backend | Java + Spring Boot |
| ML service | Python |
| Data processing | NumPy, Pandas |
| ML frameworks | Scikit-learn, TensorFlow |
| Database | PostgreSQL |
| API communication | REST |
| Service deployment | Docker |

### System workflow

1. An employee submits an invoice or an external system sends one through an API.
2. Spring Boot validates and stores the invoice.
3. The rules engine checks for known suspicious patterns.
4. The Python ML service analyzes transaction behavior.
5. The decision engine combines available evidence and ML results.
6. The system assigns a risk score and category.
7. React displays the invoice and its supporting evidence.
8. Authorized reviewers investigate and record their decisions.
9. Decisions are retained for auditing and future model evaluation.

## 9. Evaluation and Success Criteria

The system will be evaluated using:

- Precision, recall, and F1-score.
- False-positive and false-negative rates.
- Detection performance against simple rule-based baselines.
- Performance on unseen transactions and vendors.
- Risk-score quality and interpretability.
- Processing latency.
- Percentage of invoices flagged for review.
- Ability to detect controlled synthetic fraud scenarios.

The evaluation must avoid data leakage and clearly distinguish synthetic test results from real-world performance.

## 10. First Release Boundaries

The first release will prioritize:

- One coherent invoice-processing workflow.
- A reproducible transaction dataset and preprocessing pipeline.
- A functioning rule-based detection layer.
- At least one meaningful ML detection model.
- Risk scoring and evidence generation.
- A working Spring Boot backend.
- A Python ML service integrated with the backend.
- A React investigation dashboard.
- PostgreSQL persistence.
- Model evaluation and documented limitations.

Real accounting-system integrations, advanced neural networks, and autonomous payment decisions are outside the initial release.

## 11. Development Philosophy

Fraud Guard Live is intended to demonstrate genuine software engineering and applied machine learning ability.

Development principles:

- Understand the business problem before selecting algorithms.
- Understand the data before training models.
- Establish baselines before introducing complex models.
- Build and understand the models rather than blindly relying on generated predictions.
- Avoid data leakage.
- Evaluate models on unseen data.
- Keep ML experiments reproducible.
- Design maintainable APIs and clear service boundaries.
- Use AI-assisted development as a tool, not a substitute for technical understanding.
- Prioritize a complete, reliable system over an excessive number of features.

Human reviewers retain authority over invoice decisions. The system must not independently release payments or declare a transaction fraudulent without investigation.

## 12. Long-Term Vision

Fraud Guard Live aims to become an intelligent financial risk platform that helps organizations identify suspicious transactions, investigate financial irregularities, and strengthen their invoice review processes.

**Detect anomalies. Explain risk. Protect payments.**