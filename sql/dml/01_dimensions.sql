-- Заполнение измерений из staging (mock_data)

INSERT INTO dim_country (country_name)
SELECT DISTINCT TRIM(country_name)
FROM (
    SELECT customer_country AS country_name FROM mock_data
    UNION
    SELECT seller_country FROM mock_data
    UNION
    SELECT store_country FROM mock_data
    UNION
    SELECT supplier_country FROM mock_data
) AS countries
WHERE country_name IS NOT NULL AND TRIM(country_name) <> '';

INSERT INTO dim_city (city_name, state_name, country_sk)
SELECT DISTINCT
    TRIM(s.city_name),
    NULLIF(TRIM(s.state_name), ''),
    c.country_sk
FROM (
    SELECT store_city AS city_name, store_state AS state_name, store_country AS country_name
    FROM mock_data
    UNION
    SELECT supplier_city, NULL, supplier_country
    FROM mock_data
) AS s
JOIN dim_country c ON c.country_name = TRIM(s.country_name)
WHERE s.city_name IS NOT NULL AND TRIM(s.city_name) <> '';

INSERT INTO dim_product_category (product_category, pet_category)
SELECT DISTINCT
    TRIM(product_category),
    NULLIF(TRIM(pet_category), '')
FROM mock_data
WHERE product_category IS NOT NULL AND TRIM(product_category) <> '';

INSERT INTO dim_date (full_date, year_num, month_num, day_num, quarter_num)
SELECT DISTINCT
    d.full_date,
    EXTRACT(YEAR FROM d.full_date)::SMALLINT,
    EXTRACT(MONTH FROM d.full_date)::SMALLINT,
    EXTRACT(DAY FROM d.full_date)::SMALLINT,
    EXTRACT(QUARTER FROM d.full_date)::SMALLINT
FROM (
    SELECT TO_DATE(sale_date, 'MM/DD/YYYY') AS full_date
    FROM mock_data
    WHERE sale_date IS NOT NULL AND TRIM(sale_date) <> ''
) AS d;

INSERT INTO dim_customer (
    source_customer_id,
    first_name,
    last_name,
    age,
    email,
    postal_code,
    pet_type,
    pet_name,
    pet_breed,
    country_sk
)
SELECT DISTINCT ON (m.customer_email)
    NULLIF(m.sale_customer_id, '')::INTEGER,
    m.customer_first_name,
    m.customer_last_name,
    NULLIF(NULLIF(TRIM(m.customer_age), ''), '')::INTEGER,
    m.customer_email,
    NULLIF(TRIM(m.customer_postal_code), ''),
    m.customer_pet_type,
    m.customer_pet_name,
    m.customer_pet_breed,
    c.country_sk
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = TRIM(m.customer_country)
ORDER BY m.customer_email, m.row_id;

INSERT INTO dim_seller (
    source_seller_id,
    first_name,
    last_name,
    email,
    postal_code,
    country_sk
)
SELECT DISTINCT ON (m.seller_email)
    NULLIF(m.sale_seller_id, '')::INTEGER,
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    NULLIF(TRIM(m.seller_postal_code), ''),
    c.country_sk
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = TRIM(m.seller_country)
ORDER BY m.seller_email, m.row_id;

INSERT INTO dim_product (
    source_product_id,
    product_name,
    category_sk,
    list_price,
    stock_quantity,
    weight,
    color,
    size_label,
    brand,
    material,
    description,
    rating,
    reviews_count,
    release_date,
    expiry_date
)
SELECT DISTINCT ON (
    m.sale_product_id,
    m.product_name,
    pc.category_sk,
    m.product_price,
    m.product_brand,
    m.product_material,
    m.product_color,
    m.product_size
)
    NULLIF(m.sale_product_id, '')::INTEGER,
    m.product_name,
    pc.category_sk,
    NULLIF(m.product_price, '')::NUMERIC(12, 2),
    NULLIF(m.product_quantity, '')::INTEGER,
    NULLIF(m.product_weight, '')::NUMERIC(12, 2),
    m.product_color,
    m.product_size,
    m.product_brand,
    m.product_material,
    m.product_description,
    NULLIF(m.product_rating, '')::NUMERIC(4, 2),
    NULLIF(m.product_reviews, '')::INTEGER,
    CASE
        WHEN m.product_release_date IS NOT NULL AND TRIM(m.product_release_date) <> ''
        THEN TO_DATE(m.product_release_date, 'MM/DD/YYYY')
    END,
    CASE
        WHEN m.product_expiry_date IS NOT NULL AND TRIM(m.product_expiry_date) <> ''
        THEN TO_DATE(m.product_expiry_date, 'MM/DD/YYYY')
    END
FROM mock_data m
JOIN dim_product_category pc
    ON pc.product_category = TRIM(m.product_category)
   AND pc.pet_category IS NOT DISTINCT FROM NULLIF(TRIM(m.pet_category), '')
ORDER BY
    m.sale_product_id,
    m.product_name,
    pc.category_sk,
    m.product_price,
    m.product_brand,
    m.product_material,
    m.product_color,
    m.product_size,
    m.row_id;

INSERT INTO dim_store (store_name, store_location, city_sk, phone, email)
SELECT DISTINCT ON (m.store_email)
    m.store_name,
    m.store_location,
    ci.city_sk,
    m.store_phone,
    m.store_email
FROM mock_data m
JOIN dim_country co ON co.country_name = TRIM(m.store_country)
JOIN dim_city ci
    ON ci.city_name = TRIM(m.store_city)
   AND ci.country_sk = co.country_sk
   AND ci.state_name IS NOT DISTINCT FROM NULLIF(TRIM(m.store_state), '')
ORDER BY m.store_email, m.row_id;

INSERT INTO dim_supplier (
    supplier_name,
    contact_name,
    email,
    phone,
    address,
    city_sk,
    country_sk
)
SELECT DISTINCT ON (m.supplier_email)
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    ci.city_sk,
    co.country_sk
FROM mock_data m
JOIN dim_country co ON co.country_name = TRIM(m.supplier_country)
LEFT JOIN dim_city ci
    ON ci.city_name = TRIM(m.supplier_city)
   AND ci.country_sk = co.country_sk
   AND ci.state_name IS NULL
ORDER BY m.supplier_email, m.row_id;
