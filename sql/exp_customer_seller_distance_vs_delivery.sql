WITH seller_locations AS (
    SELECT s.seller_id, AVG(g.geolocation_lat) AS lat, AVG(g.geolocation_lng) AS lng
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_sellers_dataset` s
    JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_geolocation_dataset` g
        ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
    GROUP BY s.seller_id
),
customer_locations AS (
    SELECT c.customer_id, AVG(g.geolocation_lat) AS lat, AVG(g.geolocation_lng) AS lng
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_customers_dataset` c
    JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_geolocation_dataset` g
        ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
    GROUP BY c.customer_id
)

SELECT
    CASE 
        WHEN ST_DISTANCE(
            ST_GEOGPOINT(s.lng, s.lat),
            ST_GEOGPOINT(c.lng, c.lat)
        ) / 1000 < 100 THEN 'Near (< 100 km)'
        WHEN ST_DISTANCE(
            ST_GEOGPOINT(s.lng, s.lat),
            ST_GEOGPOINT(c.lng, c.lat)
        ) / 1000 BETWEEN 100 AND 500 THEN 'Medium (100-500 km)'
        ELSE 'Far (> 500 km)'
    END AS distance_category,
    AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_time
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
JOIN seller_locations s ON i.seller_id = s.seller_id
JOIN customer_locations c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY distance_category
ORDER BY avg_delivery_time ASC;
