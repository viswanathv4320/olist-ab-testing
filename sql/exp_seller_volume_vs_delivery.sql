WITH seller_order_counts AS (
    SELECT COUNT(DISTINCT order_id) AS volume, seller_id
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset`
    GROUP BY seller_id
)

SELECT CASE 
            WHEN volume > 100 THEN 'High Volume'
            ELSE 'Low Volume'
        END AS volume_category, AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_time
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` oi ON o.order_id = oi.order_id
JOIN seller_order_counts s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY volume_category