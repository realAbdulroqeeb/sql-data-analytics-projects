/*
*************************************************************
Create Database
*************************************************************
Script Purpose:
    This script creates a new database named 'Commerce_db' after checking if it already exists. 
    If the database exists, it is dropped and recreated.
*/

USE master;
GO

-- Drop and recreate the 'Commerce_db' database
DROP DATABASE IF EXISTS Commerce_db;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE Commerce_db;
GO

USE Commerce_db;
GO

DROP TABLE IF EXISTS customers;
CREATE TABLE customers(
	customer_key int PRIMARY KEY,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

DROP TABLE IF EXISTS products;
CREATE TABLE products(
	product_key int PRIMARY KEY ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

DROP TABLE IF EXISTS fact_sales;
CREATE TABLE fact_sales(
	order_number nvarchar(50),
	product_key int FOREIGN KEY REFERENCES products(product_key),
	customer_key int FOREIGN KEY REFERENCES customers(customer_key),
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO


BULK INSERT customers
FROM 'C:\Users\HP\Desktop\TDI\capstone\sql-data-analytics-project\datasets\csv-files\gold.dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO



BULK INSERT products
FROM 'C:\Users\HP\Desktop\TDI\capstone\sql-data-analytics-project\datasets\csv-files\gold.dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO


BULK INSERT fact_sales
FROM 'C:\Users\HP\Desktop\TDI\capstone\sql-data-analytics-project\datasets\csv-files\gold.fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

/**********************************************************************************************************
Data Integrity Checks
************************************************************************************************************/

-- Check for null
 SELECT 'customer_key' AS primary_keys,COUNT(*) AS count_null FROM customers WHERE customer_key IS NULL
 UNION ALL
 SELECT 'product_key',COUNT(*) FROM products WHERE product_key IS NULL
 ;
 GO

 -- Check for duplicates
SELECT customer_key, COUNT(*) AS count_duplicates FROM customers GROUP BY customer_key HAVING COUNT(*) > 1;
GO
SELECT product_key, COUNT(*) AS count_duplicates FROM products GROUP BY product_key HAVING COUNT(*) > 1;
GO

-- Foreign Key Integrity
SELECT COUNT(*) AS missingcustomer FROM fact_sales s JOIN customers c ON s.customer_key = c.customer_key WHERE c.customer_key IS NULL;
GO
SELECT COUNT(*) AS missingprduct FROM fact_sales s JOIN products p ON s.product_key = p.product_key WHERE p.product_key IS NULL;
GO

/**********************************************************************************************************
EXPLORATORY DATA ANALYSIS
************************************************************************************************************/
-- Explore all objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES;
GO

-- Explore all Columns in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'customers';
GO

/*
*************************************************************************************************
Sales Report
**************************************************************************************************
Purpose:
    - This report consolidates key Sales metrics and behaviors.
Highlights:
    Gathers essential fields such as order_id,customer name, product name, subcategory, cost etc.
**************************************************************************************************
*/
DROP VIEW IF EXISTS report_sales;
GO 

CREATE VIEW report_sales AS
WITH base_query AS (
-- Gather essential fields
	SELECT 
		f.order_number,
		f.order_date,
		f.price,
		f.quantity,
		f.sales_amount,
		p.product_name,
		p.category,
		p.subcategory,
		p.product_line,
		p.cost,
		c.country,
		c.first_name,
		c.last_name,
		c.marital_status,
		c.gender
	FROM 
		fact_sales f
	JOIN 
		customers c ON f.customer_key = c.customer_key
	JOIN
		products p ON f.product_key = p.product_key
)
, aggregate AS(
-- data tranformation
	SELECT 
		order_number,
		CONCAT(first_name,' ',last_name) AS customer_name,
		product_name,
		category,
		subcategory,
		cost,
		country,
		price,
		quantity,
		sales_amount,
		product_line,
		order_date,
		COUNT(DISTINCT(order_number)) AS total_orders,
		YEAR(order_date) AS order_year,
		DATENAME(DAY,order_date) AS order_days,
		DATENAME(MONTH,order_date) AS order_months
	FROM 
		base_query
	WHERE 
		order_date IS NOT NULL
	GROUP BY
		order_number,
		CONCAT(first_name,' ',last_name),
		product_name,
		category,
		subcategory,
		cost,
		country,
		price,
		quantity,
		sales_amount,
		product_line,
		order_date
)
SELECT 
-- Bring out the essential columns
	order_number,
	customer_name,
	product_name,
	category,
	subcategory,
	cost,
	country,
	price,
	quantity,
	sales_amount,
	price - cost AS profit,
	product_line,
	order_date,
	total_orders,
	order_year,
	order_days,
	SUBSTRING(order_months,1,3) AS order_months
FROM
	aggregate
WHERE 
	country IS NOT NULL
GO

/*************************************************************************************************
The Report Output
**************************************************************************************************/

SELECT * FROM report_sales;
GO

/* The specific business questions guiding this analysis include:
	1.	What is the sales performance across different product lines?
	2.	Which are the top 5 products by total sales?
	3.	How do monthly sales trends behave across the time period?
	4.	What does the category sales look like?
	5.	How are sales distributed by country?
	6.	Who are the top 10 customers by total sales? */

--1.What is the sales performance across different product lines?

WITH cte_pl_sales_amount AS(
SELECT DISTINCT 
	product_line,
	SUM(sales_amount) OVER(PARTITION BY product_line) sales_amount
FROM report_sales
) -- sales summation by product line
SELECT 
	product_line,
	CONCAT('$',FORMAT(sales_amount,'N')) sales_amount,
	CONCAT(ROUND(CAST(sales_amount AS FLOAT)/SUM(sales_amount) OVER() * 100,0),'%') percentage_contribution
FROM cte_pl_sales_amount -- Specifying the percentage contribution


--2.Which are the top 5 products by total sales?
SELECT TOP 5
	product_name,
	CONCAT('$',FORMAT(SUM(sales_amount),'N')) sales_amount
FROM report_sales
GROUP BY product_name
ORDER BY SUM(sales_amount) DESC --generating the top 5 sales amount by product

-- 3.How do monthly sales trends behave across the time period?
SELECT 
	FORMAT(order_date,'MMM-yyyy') month,
	CONCAT('$',FORMAT(SUM(sales_amount),'N')) sales_amount
FROM report_sales
GROUP BY 
FORMAT(order_date,'MMM-yyyy'),
YEAR(order_date)
ORDER BY YEAR(order_date) ASC -- The sum sales by month in each year

-- 4.What does the category sales look like?
WITH cte_category_sales_amount AS(
SELECT DISTINCT 
	category,
	SUM(sales_amount) OVER(PARTITION BY category) sales_amount
FROM report_sales
) -- sales summation by category
SELECT 
	category,
	CONCAT('$',FORMAT(sales_amount,'N')) sales_amount,
	CONCAT(ROUND(CAST(sales_amount AS FLOAT)/SUM(sales_amount) OVER() * 100,0),'%') percentage_contribution
FROM cte_category_sales_amount -- Specifying the percentage contribution

-- 5.How are sales distributed by country?
SELECT 
	country,
	CONCAT('$',FORMAT(SUM(sales_amount),'N')) sales_amount
FROM report_sales
GROUP BY country

-- 6.Who are the top 10 customers by total sales?
SELECT TOP 10 
	customer_name,
	CONCAT('$',FORMAT(SUM(sales_amount),'N')) sales_amount
FROM report_sales 
GROUP BY customer_name 
ORDER BY SUM(sales_amount) DESC


-- Key Performance Indicators
SELECT 'Count of Order' AS KPI,FORMAT(COUNT(DISTINCT(order_number)) ,'N')AS value FROM report_sales
UNION
SELECT 'Sum of Quantity',FORMAT(SUM(quantity),'N') FROM report_sales
UNION
SELECT 'Sum of Sales', CONCAT('$',FORMAT(SUM(sales_amount),'N')) FROM report_sales
UNION
SELECT 'Sum of Profits',CONCAT('$',FORMAT(SUM(profit),'N')) FROM report_sales



