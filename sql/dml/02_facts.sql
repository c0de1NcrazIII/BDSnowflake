-- Заполнение таблицы фактов
INSERT INTO fact_sales (
    source_row_id,
    source_sale_id,
    date_sk,
    customer_sk,
    seller_sk,
    product_sk,
    store_sk,
    supplier_sk,
    sale_quantity,
    sale_total_price
)
SELECT
    m.row_id,
    NULLIF(m.id, '')::INTEGER,
    d.date_sk,
    cu.customer_sk,
    se.seller_sk,
    pr.product_sk,
    st.store_sk,
    su.supplier_sk,
    NULLIF(m.sale_quantity, '')::INTEGER,
    NULLIF(m.sale_total_price, '')::NUMERIC(12, 2)
FROM mock_data m
JOIN dim_date d ON d.full_date = TO_DATE(m.sale_date, 'MM/DD/YYYY')
JOIN dim_customer cu ON cu.email = m.customer_email
JOIN dim_seller se ON se.email = m.seller_email
JOIN dim_product_category pc
    ON pc.product_category = TRIM(m.product_category)
   AND pc.pet_category IS NOT DISTINCT FROM NULLIF(TRIM(m.pet_category), '')
JOIN dim_product pr
    ON pr.source_product_id = NULLIF(m.sale_product_id, '')::INTEGER
   AND pr.product_name = m.product_name
   AND pr.category_sk = pc.category_sk
   AND pr.list_price = NULLIF(m.product_price, '')::NUMERIC(12, 2)
   AND pr.brand IS NOT DISTINCT FROM m.product_brand
   AND pr.material IS NOT DISTINCT FROM m.product_material
   AND pr.color IS NOT DISTINCT FROM m.product_color
   AND pr.size_label IS NOT DISTINCT FROM m.product_size
JOIN dim_store st ON st.email = m.store_email
JOIN dim_supplier su ON su.email = m.supplier_email;
