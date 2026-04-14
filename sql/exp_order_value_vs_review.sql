WITH order_totals AS (
    SELECT order_id, SUM(price) AS total_order_value
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset`
    GROUP BY order_id
),
order_value_percentiles AS (
    SELECT order_id, total_order_value,
        PERCENTILE_CONT(total_order_value, 0.25) OVER() AS p25,
        PERCENTILE_CONT(total_order_value, 0.75) OVER() AS p75
    FROM order_totals
)

SELECT CASE
        WHEN p.total_order_value <= p.p25 THEN 'Low'
        WHEN p.total_order_value <= p.p75 THEN 'Medium'
        ELSE 'High'
    END AS order_value_category,
    AVG(r.review_score) AS avg_review_score
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_reviews_dataset` r ON o.order_id = r.order_id
JOIN order_value_percentiles p ON i.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_value_category
ORDER BY avg_review_score DESC;