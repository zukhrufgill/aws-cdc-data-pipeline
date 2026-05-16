-- ============================================
-- Athena External Table Definitions
-- ============================================

-- Create analytics database
CREATE DATABASE fintech_warehouse;

-- Raw CDC table (points to DMS output in S3)
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

-- Clean Parquet table (points to Glue output)
CREATE EXTERNAL TABLE fintech_warehouse.orders_clean (
    op STRING,
    id INT,
    customer_id DOUBLE,
    amount DOUBLE,
    status STRING,
    created_at STRING
)
STORED AS PARQUET
LOCATION 's3://your-bucket/clean-orders/';

-- ============================================
-- Sample Analytics Queries
-- ============================================

-- View all active orders
SELECT id, customer_id, amount, status
FROM fintech_warehouse.orders
WHERE op != 'D'
ORDER BY id;

-- Total revenue by status
SELECT
    status,
    COUNT(*) as order_count,
    SUM(amount) as total_revenue
FROM fintech_warehouse.orders
WHERE op != 'D'
GROUP BY status
ORDER BY total_revenue DESC;

-- Latest orders
SELECT *
FROM fintech_warehouse.orders
ORDER BY created_at DESC
LIMIT 10;
