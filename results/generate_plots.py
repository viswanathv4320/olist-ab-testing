from google.cloud import bigquery
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

client = bigquery.Client(project="project-ccbf6acf-9991-4d10-82d")
output_dir = Path("results")
output_dir.mkdir(exist_ok=True)

# EXPERIMENT 1

def plot_exp1():
    query = """
        SELECT 
            CASE 
                WHEN TIMESTAMP_DIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date, DAY) > 0 THEN 'Early' 
                WHEN TIMESTAMP_DIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date, DAY) < 0 THEN 'Late' 
                ELSE 'On-time' END AS delivery_accuracy, 
            r.review_score
        FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
        JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_reviews_dataset` r ON o.order_id = r.order_id
        WHERE o.order_status = 'delivered'
    """
    
    df = client.query(query).to_dataframe()
    df = df[df['delivery_accuracy'].isin(['Early', 'Late'])]
    
    plt.figure(figsize=(8, 6))
    sns.boxplot(data=df, x='delivery_accuracy', y='review_score', 
            order=['Early', 'Late'], hue='delivery_accuracy', 
            palette='Set2', legend=False)
    plt.title('Delivery Accuracy vs Review Score')
    plt.xlabel('Delivery Group')
    plt.ylabel('Review Score')
    plt.savefig(output_dir / 'exp1_delivery_accuracy_vs_review.png', dpi=150, bbox_inches='tight')
    plt.close()

plot_exp1()
print("Exp 1 done")

# EXPERIMENT 2

def plot_exp2():
    query = """
        WITH seller_locations AS (
            SELECT s.seller_id, AVG(g.geolocation_lat) AS lat, AVG(g.geolocation_lng) AS lng
            FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_sellers_dataset` s
            JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_geolocation_dataset` g
                ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
            GROUP BY s.seller_id
        ),
        customer_locations AS (
            SELECT c.customer_id, AVG(g.geolocation_lat) AS lat, AVG(g.geolocation_lng) AS lng
            FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_customers_dataset` c
            JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_geolocation_dataset` g
                ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
            GROUP BY c.customer_id
        )

        SELECT
            CASE 
                WHEN ST_DISTANCE(
                    ST_GEOGPOINT(s.lng, s.lat),
                    ST_GEOGPOINT(c.lng, c.lat)
                ) / 1000 < 100 THEN 'Near (< 100 km)'
                WHEN ST_DISTANCE(
                    ST_GEOGPOINT(s.lng, s.lat),
                    ST_GEOGPOINT(c.lng, c.lat)
                ) / 1000 BETWEEN 100 AND 500 THEN 'Medium (100-500 km)'
                ELSE 'Far (> 500 km)'
            END AS distance_category,
            TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) AS delivery_time
        FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
        JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
        JOIN seller_locations s ON i.seller_id = s.seller_id
        JOIN customer_locations c ON o.customer_id = c.customer_id
        WHERE o.order_status = 'delivered'
    """

    df = client.query(query).to_dataframe()
    df = df[df['distance_category'].isin(['Near (< 100 km)', 'Far (> 500 km)'])]

    plt.figure(figsize=(8, 6))
    sns.boxplot(data=df, x='distance_category', y='delivery_time', 
            order=['Near (< 100 km)', 'Far (> 500 km)'], hue='distance_category', 
            palette='Set2', legend=False)
    plt.title('Distance vs Delivery Time')
    plt.xlabel('Distance Group')
    plt.ylabel('Delivery Time (days)')
    plt.savefig(output_dir / 'exp2_distance_vs_delivery_time.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Exp 2 plot saved.")  

plot_exp2()
print("Exp 1 done")

# EXPERIMENT 3

def plot_exp3():
    query = """
        SELECT p.payment_type, TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) AS delivery_time
        FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
        JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_payments_dataset` p ON o.order_id = p.order_id
        WHERE o.order_status = 'delivered'
        AND p.payment_type IN ('boleto', 'debit_card')
    """

    df = client.query(query).to_dataframe()
    df = df[df['payment_type'].isin(['boleto', 'debit_card'])]

    plt.figure(figsize=(8, 6))
    sns.boxplot(data=df, x='payment_type', y='delivery_time', 
            order=['boleto', 'debit_card'], hue='payment_type', 
            palette='Set2', legend=False)
    plt.title('Payment Method vs Delivery Time')
    plt.xlabel('Payment Method')
    plt.ylabel('Delivery Time (days)')
    plt.savefig(output_dir / 'exp3_payment_method_vs_delivery_time.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Exp 3 plot saved.")

plot_exp3()
print("Exp 3 done")

# EXPERIMENT 4

def plot_exp4():
    query = """
        SELECT r.review_score,
            CASE WHEN TIMESTAMP_DIFF(i.shipping_limit_date, o.order_delivered_carrier_date, DAY) < 0 THEN 'Late' 
                    ELSE 'Early' END AS shipping_speed
        FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
        JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_items_dataset` i ON o.order_id = i.order_id
        JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_reviews_dataset` r ON o.order_id = r.order_id
        WHERE o.order_status = 'delivered'
    """

    df = client.query(query).to_dataframe()
    df = df[df['shipping_speed'].isin(['Early', 'Late'])]

    plt.figure(figsize=(8, 6))
    sns.boxplot(data=df, x='shipping_speed', y='review_score', 
            order=['Early', 'Late'], hue='shipping_speed', 
            palette='Set2', legend=False)
    plt.title('Shipping Speed vs Review Score')
    plt.xlabel('Shipping Speed Group')
    plt.ylabel('Review Score')
    plt.savefig(output_dir / 'exp4_shipping_speed_vs_review.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Exp 4 plot saved.")

plot_exp4()
print("Exp 4 done")