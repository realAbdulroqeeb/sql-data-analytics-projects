/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
/* =============================================================================
 1) Create Report: report_products
=============================================================================== */
CREATE VIEW report_products AS
WITH base_query AS (
	SELECT
		s.product_key,
		s.order_number,
		s.customer_key,
		s.sales_amount,
		s.quantity,
		s.order_date,
		p.product_id,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM
		fact_sales s
	JOIN 
		products p ON s.product_key = p.product_key
)
/*=============================================================================
2) Aggregate Key Measures
==============================================================================*/
,aggregate_report AS (
	SELECT 
		product_id,
		product_name,
		category,
		subcategory,
		cost,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT(customer_key)) AS total_customers,
		COUNT(DISTINCT(order_number)) AS total_orders,
		MIN(order_date) AS first_order,
		MAX(order_date) AS last_order,
		DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
	FROM 
		base_query
	GROUP BY
		product_id,
		product_name,
		category,
		subcategory,
		cost
)
SELECT 
	product_id,
	product_name,
	category,
	subcategory,
	cost,
	total_sales,
	total_quantity,
	total_customers,
	first_order,
	last_order,
	lifespan,
	CASE WHEN total_sales >= 915637 THEN 'High-Performace'
		 WHEN total_sales BETWEEN 457819 AND 915636 THEN 'Mid-Range'
		 ELSE 'Low-Performance'
	END AS product_segment,
-- Recency
	DATEDIFF(month,last_order,GETDATE()) AS recency,
-- average order revenue (AOR)
	CASE WHEN total_orders = 0 THEN 0
	     ELSE total_sales/ total_orders 
	END AS average_order_revenue,
-- average monthly revenue
	CASE WHEN lifespan = 0 THEN 0
	     ELSE total_sales/lifespan 
	END AS average_monthly_revenue
FROM
	aggregate_report



