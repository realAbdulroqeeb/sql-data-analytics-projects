-- Find the date of the first and last order
-- How many years of sales are available
SELECT 
	MIN(order_date) first_order_date, 
	MAX(order_date) last_order_date,
	DATEDIFF(year,MIN(order_date),MAX(order_date)) order_range_years
FROM 
	fact_sales

-- How many months of sales are available
SELECT 
	MIN(order_date) first_order_date, 
	MAX(order_date) last_order_date,
	DATEDIFF(month,MIN(order_date),MAX(order_date)) order_range_years
FROM 
	fact_sales

SELECT
MIN(birthdate) AS oldest_birthdate,
DATEDIFF(YEAR,MIN(birthdate),GETDATE()) AS oldest_age,
MAX(birthdate) AS youngest_birhdate,
DATEDIFF(YEAR,MAX(birthdate),GETDATE()) AS youngest_age

FROM 
	customers
