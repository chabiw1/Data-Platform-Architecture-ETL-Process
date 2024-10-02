# Ecommerch Data Platform Architecture  - ETL Process

This project outlines the data platform architecture for an e-commerce company, and provides a detailed overview of how we synchronize data between various databases through an automated ETL (Extract, Transform, Load) process.


![dw_architecture](https://github.com/user-attachments/assets/f8f39206-451a-487e-9d73-612bd00d42d2)



## Overview

i utilize a hybrid data platform architecture combining on-premises and cloud-based databases to support its e-commerce operations. The architecture facilitates the seamless movement of data from the transactional database to a staging warehouse for transformation before loading it into the production data warehouse. The final production data is used for generating business insights through IBM Cognos Analytics.

## Tools and Technologies

- **OLTP Database**: MySQL (on-premises) for transactional and catalog data.
- **Staging Data Warehouse**: PostgreSQL (on-premises) for intermediate data processing.
- **Production Data Warehouse**: DB2 (cloud-based) for long-term storage and business reporting.
- **Business Intelligence Dashboard**: IBM Cognos Analytics for reporting and dashboards.

## Data Flow and Process

1. **Customer Interactions**: 
   - Customers interact with SoftCart’s website using various devices (laptops, mobiles, tablets).
   - All sales transactions and catalog data are stored in the MySQL OLTP database.

2. **Data Extraction**:
   - The data is periodically extracted from the MySQL database to the PostgreSQL staging data warehouse for further processing.

3. **Transformation**:
   - In PostgreSQL, the extracted data undergoes transformation into two tables:
     - **DimDate**: A dimension table for date-related information.
     - **FactSales**: A fact table capturing sales transactions with calculated fields such as total sales price.

4. **Loading Data to Production**:
   - After transformation, the data is exported as CSV files and loaded into the DB2 production warehouse for analysis.

5. **Business Intelligence**:
   - The BI team connects to DB2 using IBM Cognos Analytics to generate dashboards and reports for key business metrics.

## Automation

- A **shell script (ETL.sh)** is used to automate the entire process of extracting, transforming, and exporting data.
- A **cron job** is set up to ensure this script runs at regular intervals, keeping the data synchronized between the OLTP, staging, and production warehouses.

## Steps to Set Up

1. **Prepare MySQL Server**:
   - Start the MySQL server and create a `sales` database.
   - Load historical and new data from CSV files (`sales_old_data.csv` and `sales_new_data.csv`) into the `sales_data` table.

2. **Set Up PostgreSQL Staging Warehouse**:
   - Initialize the PostgreSQL server and execute the setup script to create necessary tables.

3. **Automate the ETL Process**:
   - Use a shell script to automate data extraction from MySQL, transformation in PostgreSQL, and export to CSV files.

4. **Set Up Cron Job**:
   - Schedule the cron job to ensure the ETL process runs regularly.

5. **BI Dashboards**:
   - Use IBM Cognos Analytics to create operational dashboards and generate insights from the data in DB2.

## Repository Structure

```bash
.
├── README.md               # Project overview
├── ETL.sh                  # Shell script for the ETL process
├── setup_mysql.sh          # Script for setting up the MySQL server
├── setuppostgresqldb.sh    # Script for setting up the PostgreSQL staging warehouse
├── cronjob_config          # Example configuration for setting up a cron job
```


# Project Summary: Data Platform Architecture for SoftCart

This project outlines a data platform architecture for SoftCart, an e-commerce company, and provides the steps for setting up the ETL (Extract, Transform, Load) process to synchronize data between the company's transactional system (OLTP) and the data warehouse (DW).

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
- **Transform**: Data is loaded into PostgreSQL, and then transformation steps create the `DimDate` (dimension table) and `FactSales` (fact table).
- **Load**: Data is exported from PostgreSQL into CSV files (`DimDate.csv` and `FactSales.csv`), which can later be transferred to the DB2 production warehouse.

### 4. **Automation and Cron Job**:
- A cron job is used to automate the ETL process, ensuring that data is regularly synchronized between MySQL and PostgreSQL, and ultimately to DB2 for analysis.
- This allows the system to handle real-time and near-real-time data updates, supporting business decisions and reporting through Cognos Analytics.

## Files Overview:
- **setupmysqldb.sh**: Sets up MySQL and loads data.
- **setuppostgresqldb.sh**: Sets up PostgreSQL staging warehouse.
- **ETL.sh**: Handles the extraction, transformation, and loading of data from MySQL to PostgreSQL and exporting the results.

This system ensures that SoftCart's data remains synchronized, processed, and available for business intelligence reporting in a seamless and automated way.

