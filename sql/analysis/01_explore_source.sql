-- Анализ исходных данных (выполнять после загрузки mock_data)

SELECT COUNT(*) AS total_rows FROM mock_data;

SELECT COUNT(DISTINCT customer_email) AS unique_customers FROM mock_data;
SELECT COUNT(DISTINCT seller_email) AS unique_sellers FROM mock_data;
SELECT COUNT(DISTINCT store_email) AS unique_stores FROM mock_data;
SELECT COUNT(DISTINCT supplier_email) AS unique_suppliers FROM mock_data;
SELECT COUNT(DISTINCT sale_product_id) AS unique_product_ids FROM mock_data;

SELECT customer_country, COUNT(*) AS cnt
FROM mock_data
GROUP BY customer_country
ORDER BY cnt DESC
LIMIT 10;

SELECT product_category, COUNT(*) AS cnt, SUM(NULLIF(sale_total_price, '')::NUMERIC) AS revenue
FROM mock_data
GROUP BY product_category
ORDER BY revenue DESC;
