WITH freight_ratios AS (
    SELECT i.order_id, i.freight_value / i.price AS freight_ratio
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i
),
freight_thresholds AS (
    SELECT order_id, freight_ratio,
        PERCENTILE_CONT(freight_ratio, 0.25) OVER() AS p25,
        PERCENTILE_CONT(freight_ratio, 0.75) OVER() AS p75
    FROM freight_ratios
)

SELECT
    CASE 
        WHEN ft.freight_ratio <= ft.p25 THEN 'Low'
        WHEN ft.freight_ratio <= ft.p75 THEN 'Medium'
        ELSE 'High'
    END AS freight_ratio_category,
    AVG(r.review_score) AS avg_review_score
FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_reviews_dataset` r ON o.order_id = r.order_id
JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
JOIN freight_thresholds ft ON i.order_id = ft.order_id
WHERE o.order_status = 'delivered'
GROUP BY freight_ratio_category
ORDER BY avg_review_score DESC;