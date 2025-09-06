/*
===============================================================================
Sales Report
===============================================================================
Purpose:
    - This report consolidates key Sales metrics and behaviors.
Highlights:
    Gathers essential fields such as order_id,customer name, product name, subcategory, cost etc.
===============================================================================
*/
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
-- Computate some transformations
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
