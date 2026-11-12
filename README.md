# Fraud Guard Live

> Detect suspicious invoices. Identify financial risks. Strengthen payment integrity.

## Overview

Fraud Guard Live is a machine learning-powered invoice fraud detection system designed to identify suspicious transactions, assess invoice risk, and support more informed financial decisions.

The project combines data engineering, machine learning, and a full-stack application to analyze invoice records, vendor behavior, payment patterns, and historical changes that may indicate potential fraud.

## Problem

Organizations process large volumes of invoices and payments, making it difficult to consistently identify suspicious activities through manual reviews alone.

Potential warning signs such as unusual invoice amounts, duplicate submissions, vendor bank account changes, and abnormal approval patterns can be difficult to detect without systematic analysis.

Fraud Guard Live aims to address this challenge by using data-driven analysis and machine learning to identify potentially fraudulent invoices and prioritize them for human review.

## Objectives

- Develop an end-to-end invoice fraud detection system.
- Identify suspicious invoice patterns and unusual financial activities.
- Analyze vendor behavior, payment history, and invoice characteristics.
- Apply machine learning techniques to assess invoice risk.
- Provide interpretable risk indicators to support human decision-making.
- Maintain traceability through invoice risk assessments and review records.

## Key Features

*Planned and developing capabilities:*

- **Invoice Risk Assessment** — Evaluate invoices using transaction details and historical patterns.
- **Anomaly Detection** — Identify unusual invoice amounts, vendor activity, and payment behavior.
- **Vendor Behavior Analysis** — Examine vendor history, bank account changes, and recurring transaction patterns.
- **Purchase Order Verification** — Analyze invoice relationships with purchase orders.
- **Risk Scoring** — Generate risk scores to help prioritize suspicious invoices.
- **Review and Decision Tracking** — Record investigation outcomes and human review decisions.
- **Full-Stack Application** — Provide an interface for interacting with invoice records and risk assessments.

## Machine Learning

Fraud Guard Live explores machine learning techniques for identifying suspicious invoice activity.

Areas of focus include:

- **Data Preprocessing** — Clean, validate, and prepare financial datasets.
- **Feature Engineering** — Derive meaningful indicators from invoice, vendor, payment, and historical records.
- **Anomaly Detection** — Identify transactions that deviate from expected patterns.
- **Classification** — Explore models for distinguishing potentially fraudulent and legitimate invoices when reliable labels are available.
- **Model Evaluation** — Assess model performance using appropriate metrics.
- **Explainability** — Understand which features contribute to an invoice's risk assessment.

The project emphasizes historical and time-aware features to avoid using information that would not have been available at the time of invoice assessment.

## Technology Stack

- **Backend:** Java, Spring Boot
- **Frontend:** React, JavaScript
- **Database:** PostgreSQL
- **Machine Learning:** Python, Pandas, NumPy, Scikit-learn
- **Data Processing:** SQLAlchemy
- **Version Control:** Git, GitHub

## Project Structure

```text
FraudGuardLive/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   ├── core/
│   │   └── services/
│   └── database/
├── data/
│   ├── raw/
│   ├── external/
│   ├── processed/
│   └── features/
├── ml/
│   ├── src/
│   │   ├── data/
│   │   ├── models/
│   │   ├── pipeline/
│   │   └── utils/
│   ├── notebooks/
│   ├── experiments/
│   └── models/
├── tests/
├── docs/
├── scripts/
├── requirements.txt
└── README.md
```

## Data Sources

The initial development dataset is based on a structured PostgreSQL database containing invoice and related business records.

The database includes:

- Companies and employees
- Vendors and vendor name history
- Vendor bank accounts and account history
- Purchase orders and purchase order history
- Invoices and invoice submission history
- Invoice status and approval history
- Payment terms history
- Invoice risk assessments
- Invoice detection results
- Invoice review decisions

These related records provide historical and contextual information for invoice analysis and feature engineering.

## Current Status

**Early Development — Data Engineering and ML Foundations**

Current development focuses on:

- PostgreSQL database design and seeded financial records.
- Python-based data extraction using SQLAlchemy and Pandas.
- Initial data inspection and quality analysis.
- Organizing the machine learning project architecture.
- Establishing the foundation for data cleaning, validation, and feature engineering.

Model training, evaluation, and production integration are subsequent development milestones.

## Future Improvements

- Complete the end-to-end data preparation pipeline.
- Develop and evaluate baseline fraud detection models.
- Explore advanced anomaly detection and classification techniques.
- Improve risk scoring and explainability.
- Integrate trained models with the backend application.
- Develop monitoring and model performance tracking.
- Expand testing using more realistic financial transaction datasets.