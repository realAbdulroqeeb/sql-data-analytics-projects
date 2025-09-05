-- Which 5 products generate the highest revenue
SELECT TOP 5
	p.category,
	p.product_name,
	SUM(s.sales_amount) highest_revenue,
	ROW_NUMBER() OVER(ORDER BY SUM(s.sales_amount) DESC) ranking
FROM 
	fact_sales s
JOIN 
	products p ON s.product_key = p.product_key
GROUP BY
	p.category,
	p.product_name

-- Which are the worst performing products in terms of sales?
SELECT TOP 5
	p.category,
	p.product_name,
	SUM(s.sales_amount) highest_revenue
FROM 
	fact_sales s
JOIN 
	products p ON s.product_key = p.product_key
GROUP BY
	p.category,
	p.product_name
ORDER BY
	highest_revenue ASC

-- TOP 10 customers who have generated the highest revenue
SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(sales_amount) AS total_revenue
FROM
	fact_sales s
LEFT JOIN 
	customers c ON s.customer_key = c.customer_key
GROUP BY
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY
	total_revenue DESC

-- The 3 customers with fewer orders placed
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT(order_number)) AS total_orders
FROM
	fact_sales s
LEFT JOIN 
	customers c ON s.customer_key = c.customer_key
GROUP BY
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY
	total_orders ASC

