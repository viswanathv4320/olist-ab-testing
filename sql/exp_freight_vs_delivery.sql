WITH freight_percentiles AS (
    SELECT order_id, freight_value,
        PERCENTILE_CONT(freight_value, 0.25) OVER() AS p25,
        PERCENTILE_CONT(freight_value, 0.50) OVER() AS p50,
        PERCENTILE_CONT(freight_value, 0.75) OVER() AS p75
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset`
)

SELECT CASE
        WHEN freight_value <= p25 THEN 'Low'
        WHEN freight_value > p25 AND freight_value <= p75 THEN 'Medium'
        WHEN freight_value > p75 THEN 'High'
    END AS freight_category,
    AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_time
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
JOIN freight_percentiles p ON i.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY freight_category