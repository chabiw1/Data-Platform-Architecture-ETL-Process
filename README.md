# E-commerce Data Platform Architecture - ETL Process

This project outlines the data platform architecture for an e-commerce company, and provides a detailed overview of how we synchronize data between various databases through an automated ETL (Extract, Transform, Load) process.

![dw_architecture](https://github.com/user-attachments/assets/f8f39206-451a-487e-9d73-612bd00d42d2)

🔑 ## Overview

I utilize a hybrid data platform architecture combining on-premises and cloud-based databases to support its e-commerce operations. The architecture facilitates the seamless movement of data from the transactional database to a staging warehouse for transformation before loading it into the production data warehouse. The final production data is used for generating business insights through IBM Cognos Analytics.

## Architecture Components:

### 1. **MySQL (OLTP Database)**:
- Stores real-time transactional data, including product catalog and sales information.
- The web server interacts directly with this database for real-time customer operations.

### 2. **PostgreSQL (Staging Data Warehouse)**:
- Acts as an intermediate staging area where data from MySQL is loaded for further processing and transformation before being moved to the production data warehouse.
- The staging warehouse helps clean and structure data into meaningful tables.

### 3. **DB2 (Production Data Warehouse)**:
- Stores cleaned and transformed data for business analytics.
- The final destination for structured data ready for analysis by the BI team.

### 4. **Cognos Analytics**:
- A business intelligence tool used to generate reports and dashboards based on data from DB2.

## Steps for Data Synchronization:

### 1. **Setting Up MySQL**:
- The script `setupmysqldb.sh` initializes the MySQL database, creates the `sales_data` table, and loads initial data from two CSV files (`sales_olddata.csv` and `sales_newdata.csv`).
- Data includes historical transactions and new entries.


### 2. **Setting Up PostgreSQL**:
- The script `setuppostgresqldb.sh` sets up PostgreSQL as the staging warehouse, creating tables such as `sales_data`, `DimDate`, and `FactSales`.
- These tables will store data temporarily before moving to the production environment.

### 3. **ETL Process**:
- The ETL process is automated using the `ETL.sh` script.
- **Extract**: Data is extracted from the MySQL database, focusing on transactions not older than 4 hours.
```
# Extract data from the sales_data table in MySQL and save to sales.csv
mysql -h mysql -P 3306 -u root --password=BcXbyVICQWRxVsYUAEmoL9Cn --database=sales \
--execute="SELECT rowid,product_id,customer_id,price,quantity,timestamp \
          FROM sales_data WHERE timestamp >= CURRENT_TIMESTAMP - INTERVAL 4 HOUR;" \
--batch --silent > /home/project/sales.csv

# Replace tabs with commas to format as CSV
tr '\t' ',' < /home/project/sales.csv > /home/project/temp_sales_commas.csv
mv /home/project/temp_sales_commas.csv /home/project/sales.csv
```
- **Transform**: Data is loaded into PostgreSQL, and then transformation steps create the `DimDate` (dimension table) and `FactSales` (fact table).
```
# Transform the sales_data table into DimDate
psql --username=postgres --host=postgres --dbname=sales_new -c \
"INSERT INTO DimDate (dateid, year, month, day)
SELECT DISTINCT
    EXTRACT(EPOCH FROM timestamp)::bigint AS dateid,
    EXTRACT(YEAR FROM timestamp) AS year,
    EXTRACT(MONTH FROM timestamp) AS month,
    EXTRACT(DAY FROM timestamp) AS day
FROM sales_data;"

# Transform the sales_data table into FactSales
psql --username=postgres --host=postgres --dbname=sales_new -c \
"INSERT INTO FactSales (rowid, product_id, customer_id, price, total_price)
SELECT 
    rowid, 
    product_id, 
    customer_id,
    price,
    price * quantity AS total_price
FROM sales_data;"
```
- **Load**: Data is exported from PostgreSQL into CSV files (`DimDate.csv` and `FactSales.csv`), which can later be transferred to the DB2 production warehouse.
```
# Load data into PostgreSQL sales_data table
psql --username=postgres --host=postgres --dbname=sales_new -c "\
\COPY sales_data(rowid, product_id, customer_id, price, quantity, timestamp)\
FROM '/home/project/sales.csv' DELIMITER ',' CSV HEADER;"

# Remove the sales.csv file after loading it into PostgreSQL
rm /home/project/sales.csv

# Export DimDate table to a CSV file
psql --username=postgres --host=postgres --dbname=sales_new -c \
"\COPY DimDate TO '/home/project/DimDate.csv' DELIMITER ',' CSV HEADER;"

# Export FactSales table to a CSV file
psql --username=postgres --host=postgres --dbname=sales_new -c \
"\COPY FactSales TO '/home/project/FactSales.csv' DELIMITER ',' CSV HEADER;"
```

### 4. **Automation and Cron Job**:
- A cron job is used to automate the ETL process, ensuring that data is regularly synchronized between MySQL and PostgreSQL, and ultimately to DB2 for analysis.
- This allows the system to handle real-time and near-real-time data updates, supporting business decisions and reporting through Cognos Analytics.

## Files Overview:
- **setupmysqldb.sh**: Sets up MySQL and loads data.
- **setuppostgresqldb.sh**: Sets up PostgreSQL staging warehouse.
- **ETL.sh**: Handles the extraction, transformation, and loading of data from MySQL to PostgreSQL and exporting the results.

This system ensures that SoftCart's data remains synchronized, processed, and available for business intelligence reporting in a seamless and automated way.

