--Calculate the totall sales per month 
-- and the running total of sales over time

SELECT 
	order_date,
	total_sales,
-- window function
	SUM(total_sales) OVER(ORDER BY order_date ASC) AS running_total_sales,
	AVG(avg_price) OVER(ORDER BY order_date ASC) moving_avg_price
FROM (
SELECT
	DATETRUNC(YEAR,order_date) order_date,
	SUM(sales_amount) total_sales,
	AVG(price) avg_price
FROM
	fact_sales
WHERE 
	order_date IS NOT NULL
GROUP BY
	DATETRUNC(YEAR,order_date)
) t