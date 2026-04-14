WITH order_seller_counts AS (
    SELECT order_id, COUNT(DISTINCT seller_id) AS seller_count
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset`
    GROUP BY order_id
)

SELECT CASE
        WHEN order_seller_counts.seller_count = 1 THEN 'Single Seller'
        ELSE 'Multiple Sellers'
    END AS seller_count_category,
    AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_time  
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN order_seller_counts ON o.order_id = order_seller_counts.order_id
WHERE o.order_status = 'delivered'
GROUP BY seller_count_category;