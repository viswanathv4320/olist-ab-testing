WITH order_seller_counts AS (
    SELECT order_id, COUNT(DISTINCT seller_id) AS seller_count
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset`
    GROUP BY order_id
)

SELECT s.seller_count,
    AVG(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS cancellation_rate
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN order_seller_counts s ON o.order_id = s.order_id
GROUP BY s.seller_count
ORDER BY s.seller_count;