DROP VIEW IF EXISTS dm_v27_listing_quality;
CREATE VIEW dm_v27_listing_quality AS
WITH product_sales AS (
    SELECT product_id, MAX(category) AS category,
           MAX(photos_qty) AS photos_qty,
           MAX(description_len) AS description_len,
           SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS items_sold,
           SUM(CASE WHEN order_status = 'delivered' THEN price ELSE 0 END) AS revenue
    FROM core_item
    GROUP BY product_id
), product_reviews AS (
    SELECT product_id, AVG(review_score) AS avg_review
    FROM (
        SELECT DISTINCT product_id, order_id, review_score
        FROM core_item
        WHERE order_status = 'delivered' AND review_score IS NOT NULL
    )
    GROUP BY product_id
)
SELECT p.product_id, p.category, p.photos_qty,
       CASE WHEN p.photos_qty IS NULL THEN '0 нет данных'
            WHEN p.photos_qty = 0 THEN '0 без фото'
            WHEN p.photos_qty = 1 THEN '1 одно фото'
            WHEN p.photos_qty <= 3 THEN '2 2-3 фото'
            ELSE '3 4+ фото' END AS photos_group,
       p.description_len,
       CASE WHEN p.description_len IS NULL THEN '0 нет данных'
            WHEN p.description_len < 500 THEN '1 до 500 символов'
            WHEN p.description_len < 1000 THEN '2 500-999 символов'
            ELSE '3 от 1000 символов' END AS description_group,
       p.items_sold, p.revenue, r.avg_review
FROM product_sales p
LEFT JOIN product_reviews r ON r.product_id = p.product_id;
