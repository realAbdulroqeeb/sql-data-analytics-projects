-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales FROM fact_sales

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity FROM fact_sales

-- Find the average selling price
SELECT AVG(price) AS total_sales FROM fact_sales

-- Find the total number of orders
SELECT COUNT(order_number) AS total_orders FROM fact_sales
SELECT COUNT(DISTINCT(order_number)) AS total_orders FROM fact_sales

-- Find the total number of products
SELECT COUNT(DISTINCT(product_key)) AS total_products FROM Products

--Find the total number of customers
SELECT COUNT(DISTINCT(customer_key)) AS total_customers FROM customers

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT(customer_key)) AS total_customers FROM fact_sales

-- Generate a report that shows all key metrics of the business
SELECT 'Total Sales' AS 'measure_name',SUM(sales_amount) AS total_sales FROM fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) AS total_quantity FROM fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) AS total_sales FROM fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT(order_number)) AS total_orders FROM fact_sales
UNION ALL
SELECT 'Total Nr. products', COUNT(DISTINCT(product_key)) AS total_products FROM Products
UNION ALL
SELECT 'Total Nr. Customers',COUNT(DISTINCT(customer_key)) AS total_customers FROM customers



