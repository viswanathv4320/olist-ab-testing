WITH cancellation_rate AS (
    SELECT seller_id,
           COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) AS canceled_orders,
           COUNT(*) AS total_orders,
           SAFE_DIVIDE(COUNT(CASE WHEN order_status = 'canceled' THEN 1 END), COUNT(*)) AS cancellation_rate
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
    JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
    GROUP BY seller_id 
)

SELECT CASE
        WHEN cr.cancellation_rate <= 0.05 THEN 'Low Cancellation Rate'
        WHEN cr.cancellation_rate > 0.05 AND cr.cancellation_rate <= 0.15 THEN 'Medium Cancellation Rate'
        ELSE 'High Cancellation Rate'
    END AS cancellation_category,
    AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_time
FROM cancellation_rate cr
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON cr.seller_id = i.seller_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o ON i.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY cancellation_category
ORDER BY avg_delivery_time;