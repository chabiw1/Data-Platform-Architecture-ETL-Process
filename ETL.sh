#!/bin/sh

# Load the data from the sales_data table in MySQL to a sales.csv file, selecting data not older than 4 hours from the current time.
mysql -h mysql -P 3306 -u root --password=BcXbyVICQWRxVsYUAEmoL9Cn --database=sales \
--execute="SELECT rowid, product_id, customer_id, price, quantity, timestamp FROM sales_data WHERE timestamp >= CURRENT_TIMESTAMP - INTERVAL 4 HOUR;" \
--batch --silent > /home/project/sales.csv

# Replace tabs with commas to format as CSV
tr '\t' ',' < /home/project/sales.csv > /home/project/temp_sales_commas.csv

# Move the temp file to the original CSV file
mv /home/project/temp_sales_commas.csv /home/project/sales.csv

# Set the PostgreSQL password environment variable
export PGPASSWORD=zpwNDa2ZwhV6eS508468DBwx

# Load the data into the sales_data table in PostgreSQL
psql --username=postgres --host=postgres --dbname=sales_new -c "\COPY sales_data(rowid, product_id, customer_id, price, quantity, timestamp) FROM '/home/project/sales.csv' DELIMITER ',' CSV HEADER;"

# Remove the sales.csv file after loading it into PostgreSQL
rm /home/project/sales.csv

# Load the DimDate table with data from sales_data
psql --username=postgres --host=postgres --dbname=sales_new -c \
"INSERT INTO DimDate (dateid, year, month, day)
SELECT DISTINCT
    EXTRACT(EPOCH FROM timestamp)::bigint AS dateid,
    EXTRACT(YEAR FROM timestamp) AS year,
    EXTRACT(MONTH FROM timestamp) AS month,
    EXTRACT(DAY FROM timestamp) AS day
FROM sales_data;"

# Load the FactSales table with data from sales_data
psql --username=postgres --host=postgres --dbname=sales_new -c \
"INSERT INTO FactSales (rowid, product_id, customer_id, price, total_price)
SELECT 
    rowid, 
    product_id, 
    customer_id,
    price,
    price * quantity AS total_price
FROM sales_data;"

# Export the DimDate table to a CSV file
psql --username=postgres --host=postgres --dbname=sales_new -c \
"\COPY DimDate TO '/home/project/DimDate.csv' DELIMITER ',' CSV HEADER;"

# Export the FactSales table to a CSV file
psql --username=postgres --host=postgres --dbname=sales_new -c \
"\COPY FactSales TO '/home/project/FactSales.csv' DELIMITER ',' CSV HEADER;"


