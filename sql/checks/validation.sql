-- Проверки после загрузки

SELECT 'mock_data rows' AS check_name, COUNT(*)::TEXT AS value FROM mock_data
UNION ALL
SELECT 'fact_sales rows', COUNT(*)::TEXT FROM fact_sales
UNION ALL
SELECT 'dim_customer', COUNT(*)::TEXT FROM dim_customer
UNION ALL
SELECT 'dim_product', COUNT(*)::TEXT FROM dim_product
UNION ALL
SELECT 'dim_store', COUNT(*)::TEXT FROM dim_store
UNION ALL
SELECT 'dim_supplier', COUNT(*)::TEXT FROM dim_supplier
UNION ALL
SELECT 'dim_country', COUNT(*)::TEXT FROM dim_country
UNION ALL
SELECT 'dim_city', COUNT(*)::TEXT FROM dim_city;

-- Сверка суммы продаж: staging vs факты
SELECT
    'revenue_match' AS check_name,
    CASE
        WHEN ABS(s.staging_total - f.fact_total) < 0.01 THEN 'OK'
        ELSE 'FAIL'
    END AS value
FROM (
    SELECT SUM(NULLIF(sale_total_price, '')::NUMERIC) AS staging_total
    FROM mock_data
) s,
(
    SELECT SUM(sale_total_price) AS fact_total
    FROM fact_sales
) f;

-- Пример аналитического запроса по снежинке
SELECT
    co.country_name,
    pc.product_category,
    SUM(fs.sale_total_price) AS revenue,
    SUM(fs.sale_quantity) AS units_sold
FROM fact_sales fs
JOIN dim_customer cu ON cu.customer_sk = fs.customer_sk
JOIN dim_country co ON co.country_sk = cu.country_sk
JOIN dim_product pr ON pr.product_sk = fs.product_sk
JOIN dim_product_category pc ON pc.category_sk = pr.category_sk
GROUP BY co.country_name, pc.product_category
ORDER BY revenue DESC
LIMIT 10;
