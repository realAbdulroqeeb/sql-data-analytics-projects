-- Analyze the yearly performance of products by comparing each product's sales to both its average sales 
-- performance and the previous year's sales.
WITH yearly_product_sales AS (
SELECT
	YEAR(s.order_date) order_year,
	p.product_name,
	SUM(s.sales_amount) AS current_sales
FROM 
fact_sales s
LEFT JOIN 
	products p ON s.product_key = p.product_key
WHERE
	order_date IS NOT NULL
GROUP BY
	YEAR(s.order_date),
	p.product_name
)

SELECT 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'above avg'
		 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'below avg'
		 ELSE 'avg'
	END AS avg_change,
	-- year over year
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) py_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS diff_py,
	CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'Increasing'
		 WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'Decreasing'
		 ELSE 'No Change'
	END AS py_change
FROM 
	yearly_product_sales
