SELECT AVG(r.review_score) AS avg_review_score,
       CASE WHEN TIMESTAMP_DIFF(i.shipping_limit_date, o.order_delivered_carrier_date, DAY) < 0 THEN 'Late' 
            ELSE 'Early' END AS shipping_speed
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_reviews_dataset` r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY shipping_speed