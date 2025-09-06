/*Segment products into cost ranges 
and count how many products fall into each segment */

SELECT
	cost_range,
	COUNT(product_key) AS total_products
FROM (
SELECT
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		 ELSE 'Above 1000'
	END AS cost_range
FROM
	products
) t
GROUP BY
	cost_range
ORDER BY
	total_products DESC;

/*Group customers into three segments based on their spending behaviour
- VIP: Atleast 12 months of history and spending more than 5,000
- Regular:Atleast 12 months of history but spending 5000 or less
- New: lifespan less than 12 months */

SELECT 
  customer_segment,
  COUNT(customer_key) AS total_customers
FROM( 
	SELECT
		customer_key,
		CONCAT(first_name,' ',last_name) AS full_name,
		lifespan,
		sales_amount,
		CASE WHEN lifespan >= 12 AND sales_amount > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND sales_amount <= 5000 THEN 'Regular'
			 ELSE 'New'
		END AS customer_segment
	FROM(
	SELECT
		c.customer_key,
		c.first_name,
		c.last_name,
		MIN(s.order_date) AS first_order,
		MAX(order_date) AS last_order,
		DATEDIFF(month,MIN(s.order_date),MAX(order_date)) AS lifespan,
		SUM(s.sales_amount) AS sales_amount
	FROM
		fact_sales s
	LEFT JOIN
		customers c ON s.customer_key = c.customer_key
	GROUP BY
		c.customer_key,
		c.first_name,
		c.last_name
)t )t
GROUP BY
	customer_segment
ORDER BY
	total_customers DESC