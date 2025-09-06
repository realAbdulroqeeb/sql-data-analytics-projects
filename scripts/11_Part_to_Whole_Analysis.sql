-- Which categories contribute the most to the overall sales
WITH CTE AS (
SELECT
	p.category,
	SUM(s.sales_amount) AS total_sales
FROM 
	fact_sales s
LEFT JOIN
	products p ON s.product_key = p.product_key
GROUP BY
	p.category
) 
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND((CAST (total_sales AS FLOAT)/SUM(total_sales) OVER())* 100,2),'%')AS percentage_of_total
FROM 
	CTE
ORDER BY
	total_sales DESC
	