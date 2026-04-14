SELECT CASE WHEN s.seller_state = 'SP' THEN 'SP' ELSE 'Non-SP' END AS seller_region, 
    AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY))
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` t ON o.order_id = t.order_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_sellers_dataset` s ON t.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY seller_region