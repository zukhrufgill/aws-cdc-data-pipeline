import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# ============================================
# Configuration — update these values
# ============================================
SOURCE_BUCKET = "s3://your-bucket/public/orders/"
TARGET_BUCKET = "s3://your-bucket/clean-orders/"

# ============================================
# Step 1: Read raw CDC CSV files from S3
# ============================================
df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv(SOURCE_BUCKET)

print(f"Raw records read: {df.count()}")
df.printSchema()

# ============================================
# Step 2: Filter out DELETE operations
# ============================================
df_filtered = df.filter(df["#"] != "D")
print(f"Records after filtering deletes: {df_filtered.count()}")

# ============================================
# Step 3: Write clean Parquet files to S3
# ============================================
df_filtered.write \
    .mode("overwrite") \
    .parquet(TARGET_BUCKET)

print("Successfully wrote clean Parquet files to S3!")

job.commit()
