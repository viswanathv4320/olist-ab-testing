SELECT p.payment_type, AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY))
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_payments_dataset` p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type