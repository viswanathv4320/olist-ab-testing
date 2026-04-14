SELECT 
    CASE 
        WHEN TIMESTAMP_DIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date, DAY) > 0 THEN 'Early' 
        WHEN TIMESTAMP_DIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date, DAY) < 0 THEN 'Late' 
        ELSE 'On-time' END AS delivery_accuracy, 
    AVG(r.review_score) AS avg_review_score
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_reviews_dataset` r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY delivery_accuracy