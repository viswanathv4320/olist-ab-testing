WITH delivery_times AS (
    SELECT o.order_id,
           TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) AS delivery_time
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
    WHERE o.order_status = 'delivered'
)

SELECT CASE
        WHEN dt.delivery_time <= 7 THEN 'Fast'
        WHEN dt.delivery_time > 7 AND dt.delivery_time <= 15 THEN 'Average'
        ELSE 'Slow'
    END AS delivery_speed,
    AVG(r.review_score) AS avg_review_score
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_reviews_dataset` r ON o.order_id = r.order_id
JOIN delivery_times dt ON o.order_id = dt.order_id
WHERE o.order_status = 'delivered'
GROUP BY delivery_speed
ORDER BY avg_review_score DESC;