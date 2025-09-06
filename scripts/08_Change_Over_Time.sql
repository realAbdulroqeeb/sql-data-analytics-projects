-- Analyze Sales Performance Over Time
SELECT
	YEAR(order_date) order_year,
	MONTH(order_date) order_month,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT(customer_key)) AS total_customers,
	SUM(quantity) AS total_quantity 
FROM 
	fact_sales
where 
	order_date IS NOT NULL
GROUP BY
	YEAR(order_date),
	MONTH(order_date)
ORDER BY 
	YEAR(order_date),
	MONTH(order_date)

SELECT
	DATETRUNC(month,order_date) order_date,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT(customer_key)) AS total_customers,
	SUM(quantity) AS total_quantity 
FROM 
	fact_sales
where 
	order_date IS NOT NULL
GROUP BY
	DATETRUNC(month,order_date)
ORDER BY 
	DATETRUNC(month,order_date)

SELECT
	DATETRUNC(year,order_date) order_date,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT(customer_key)) AS total_customers,
	SUM(quantity) AS total_quantity 
FROM 
	fact_sales
where 
	order_date IS NOT NULL
GROUP BY
	DATETRUNC(year,order_date)
ORDER BY 
	DATETRUNC(year,order_date)