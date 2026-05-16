# 🏦 Real-Time CDC Data Pipeline — AWS Fintech Project

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Apache Parquet](https://img.shields.io/badge/Apache%20Parquet-50ABF1?style=for-the-badge&logo=apache&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

## 📌 Project Overview

Built a production-grade **Change Data Capture (CDC) pipeline** on AWS that continuously syncs a fintech company's PostgreSQL production database into an analytics data warehouse — without impacting the live application.

Every INSERT, UPDATE, and DELETE in the source database is automatically captured and made queryable in the analytics layer within minutes.

---

## 🏗️ Architecture

```
Amazon RDS          AWS DMS           Amazon S3          AWS Glue         Amazon Athena
(PostgreSQL)  →  (CDC Capture)  →  (Raw CSV Store)  →  (ETL/Transform) →  (SQL Queries)
  Source DB      Real-time sync     Staging layer      Parquet output     Data Warehouse
```

---

## 🛠️ Tech Stack

| Service | Purpose |
|--------|---------|
| **Amazon RDS (PostgreSQL 18)** | Source OLTP production database |
| **AWS DMS** | Change Data Capture — streams row-level changes to S3 |
| **Amazon S3** | Staging layer for raw CDC CSV files |
| **AWS Glue** | ETL job — transforms CSV to optimised Parquet format |
| **Amazon Athena** | Serverless SQL query engine on the data warehouse |
| **AWS IAM** | Role-based access control across all services |

---

## 🔄 How It Works

1. **Source DB** — PostgreSQL on Amazon RDS with logical replication enabled (`rds.logical_replication = 1`)
2. **CDC Capture** — AWS DMS monitors the PostgreSQL WAL (Write-Ahead Log) and captures every row change in real time
3. **Staging** — DMS writes change events as CSV files to S3 in the format: `s3://bucket/public/orders/`
4. **Transform** — AWS Glue ETL job reads raw CSVs, cleans the data, and writes optimised Parquet files back to S3
5. **Query** — Amazon Athena queries the Parquet files directly from S3 using standard SQL — no data loading required

---

## 📂 Repository Structure

```
├── sql/
│   ├── create_tables.sql          # RDS source table definitions
│   └── athena_create_tables.sql   # Athena external table definitions
├── glue/
│   └── cdc_cleaner.py             # Glue ETL job script
├── iam/
│   └── dms_s3_role_policy.json    # IAM role policy for DMS → S3
├── architecture/
│   └── pipeline_diagram.png       # Architecture diagram
└── README.md
```

---

## 🚀 Setup Guide

### Prerequisites
- AWS Account
- AWS CLI configured
- PostgreSQL client (psql)

### Phase 1 — RDS Setup
```sql
-- Create source table
CREATE TABLE public.orders (
    id SERIAL PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2),
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert test data
INSERT INTO public.orders (customer_id, amount, status)
VALUES (101, 250.00, 'placed');
```

### Phase 2 — Enable CDC
1. Create a custom RDS Parameter Group with `rds.logical_replication = 1`
2. Attach to RDS instance and reboot

### Phase 3 — DMS Configuration
1. Create Replication Instance (`dms.t3.micro`)
2. Create Source Endpoint (PostgreSQL, SSL: require)
3. Create Target Endpoint (Amazon S3)
4. Create Replication Task (CDC mode — Replicate data changes only)

### Phase 4 — Athena Setup
```sql
-- Create database
CREATE DATABASE fintech_warehouse;

-- Create external table over raw S3 data
CREATE EXTERNAL TABLE fintech_warehouse.orders (
    op STRING,
    id INT,
    customer_id INT,
    amount DOUBLE,
    status STRING,
    created_at STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION 's3://your-bucket/public/orders/'
TBLPROPERTIES ('skip.header.line.count'='1');
```

### Phase 5 — Glue ETL
```python
# Read raw CDC CSVs from S3
df = spark.read.option("header", "true").csv("s3://your-bucket/public/orders/")

# Write clean Parquet
df.write.mode("overwrite").parquet("s3://your-bucket/clean-orders/")
```

---

## 📊 Sample Query

```sql
-- Query clean orders from the data warehouse
SELECT
    id,
    customer_id,
    amount,
    status,
    created_at
FROM fintech_warehouse.orders
WHERE status != 'cancelled'
ORDER BY created_at DESC;
```

---

## 💡 Key Concepts Demonstrated

- **OLTP → OLAP** separation: Production database untouched while analytics runs separately
- **CDC vs Batch ETL**: Row-level change streaming instead of full table scans
- **Data Lake architecture**: Raw → Transformed → Queryable layers in S3
- **Serverless analytics**: Athena queries data in place — no warehouse provisioning
- **IAM security**: Least-privilege roles for each AWS service

---

## 💰 Estimated AWS Cost (Learning/Dev)

| Service | Cost |
|---------|------|
| RDS db.t4g.micro | ~$0.016/hr (stop when not using) |
| DMS dms.t3.micro | ~$0.036/hr (delete after use) |
| S3 | < $0.01 for small data |
| Glue | $0.44/DPU-hour (minimal for small jobs) |
| Athena | $5 per TB scanned (near-zero for small data) |

> ⚠️ Remember to stop RDS and delete DMS replication instance when not in use.

---

## 📚 What I Learned

- Configuring PostgreSQL logical replication on AWS RDS
- Setting up AWS DMS for real-time CDC
- Troubleshooting SSL, network, and IAM permission issues in AWS
- Building ETL pipelines with AWS Glue Visual Editor and PySpark
- Creating serverless data warehouses with Amazon Athena
- Designing multi-layer data lake architectures (Raw → Clean → Queryable)

---

## 🔗 Connect

Built by [Your Name] — [LinkedIn](https://linkedin.com/in/yourprofile) | [GitHub](https://github.com/yourusername)
