-- Slowest Categories by Delivery Time
SELECT t.string_field_1, AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_time
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_products_dataset` p ON p.product_id = i.product_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.product_category_name_translation` t ON p.product_category_name = t.string_field_0
WHERE o.order_status = 'delivered'
GROUP BY t.string_field_1
ORDER BY avg_delivery_time DESC
LIMIT 10

-- Fastest Categories by Delivery Time
SELECT t.string_field_1, AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_time
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_products_dataset` p ON p.product_id = i.product_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.product_category_name_translation` t ON p.product_category_name = t.string_field_0
WHERE o.order_status = 'delivered'
GROUP BY t.string_field_1
ORDER BY avg_delivery_time ASC
LIMIT 10