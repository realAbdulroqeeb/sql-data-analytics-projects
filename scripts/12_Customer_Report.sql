/*
=============================================================================== 
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/
CREATE VIEW report_customer AS
WITH base_query AS (
/*------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
-------------------------------------------------------------------------------- */

	SELECT 
		s.order_number,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT( c.first_name,' ',c.last_name) AS names,
		DATEDIFF(YEAR,c.birthdate,GETDATE()) AS ages
	FROM
		fact_sales s
	LEFT JOIN 
		customers c ON s.customer_key = c.customer_key
	WHERE
		s.order_date IS NOT NULL
)
, customer_aggregate AS (
/*------------------------------------------------------------------------------
2) Customer Agggregtions: Summarizes key metrics at the customer level
-------------------------------------------------------------------------------- */
SELECT
	customer_key,
	customer_number,
	names,
	ages,
	COUNT(DISTINCT( order_number)) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT(product_key)) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(YEAR,MIN(order_date),MAX(order_date)) AS lifespan
FROM 
	base_query
GROUP BY
	customer_key,
	customer_number,
	names,
	ages
)
SELECT
	customer_key,
	customer_number,
	names,
	ages,
	CASE WHEN ages < 20 THEN 'Under 20'
		 WHEN ages BETWEEN 20 AND 29 THEN '20-29'
		 WHEN ages BETWEEN 30 AND 39 THEN '30-39'
		 WHEN ages BETWEEN 40 AND 49 THEN '40-49'
	     ELSE '50 and Above'
	END AS age_group,
	last_order_date,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
			 ELSE 'New'
	END AS customer_segment,
-- Recency
	DATEDIFF(month,last_order_date,GETDATE()) AS recency,
-- Compute average order value(AVO)
	CASE WHEN total_orders = 0 THEN 0
	ELSE total_sales/ total_orders 
	END AS avg_order_value,
-- average monthly spend
	CASE WHEN lifespan = 0 THEN 0
		 ELSE total_sales/lifespan
	END AS avg_monthly_spend

FROM
	customer_aggregate
