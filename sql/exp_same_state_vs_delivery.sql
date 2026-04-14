SELECT CASE
        WHEN c.customer_state = s.seller_state THEN 'Same State'
        ELSE 'Different State'
    END AS state_comparison,
    AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_time
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_customers_dataset` c ON o.customer_id = c.customer_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_sellers_dataset` s ON i.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY state_comparison
ORDER BY avg_delivery_time