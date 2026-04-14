from google.cloud import bigquery
from scipy import stats
import numpy as np
from scipy.stats import sem
from statsmodels.stats.power import TTestIndPower

client = bigquery.Client(project="project-ccbf6acf-9991-4d10-82d")

query = """
    SELECT p.payment_type, TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) AS delivery_time
    FROM `project-ccbf6acf-9991-4d10-82d.olist.olist_orders_dataset` o
    JOIN `project-ccbf6acf-9991-4d10-82d.olist.olist_order_payments_dataset` p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    AND p.payment_type IN ('boleto', 'debit_card')
    
"""

df = client.query(query).to_dataframe()

boleto = df[df['payment_type'] == 'boleto']['delivery_time'].dropna()
debit_card = df[df['payment_type'] == 'debit_card']['delivery_time'].dropna()

_, p_value = stats.shapiro(boleto.sample(1000, random_state=42))
_, p_value = stats.shapiro(debit_card.sample(1000, random_state=42))

stat, p_value = stats.mannwhitneyu(boleto, debit_card, alternative='two-sided')

def cohens_d(group1, group2):
    diff = group1.mean() - group2.mean()
    pooled_std = np.sqrt((group1.std()**2 + group2.std()**2) / 2)
    return diff / pooled_std

d = cohens_d(boleto, debit_card)

diff_means = boleto.mean() - debit_card.mean()
se = np.sqrt(sem(boleto)**2 + sem(debit_card)**2)
ci_lower = diff_means - 1.96 * se
ci_upper = diff_means + 1.96 * se

analysis = TTestIndPower()
power = analysis.solve_power(
    effect_size=abs(d),
    nobs1=len(boleto),
    ratio=len(debit_card)/len(boleto),
    alpha=0.05,
    alternative='two-sided'
)

print("EXPERIMENT 3: Payment Method vs Delivery Time")
print(f"Boleto mean: {boleto.mean():.2f} days | Debit Card mean: {debit_card.mean():.2f} days")
print(f"Mann-Whitney p-value: {p_value:.4f}")
print(f"Cohen's d: {abs(d):.4f} (small effect)")
print(f"95% CI: ({ci_lower:.4f}, {ci_upper:.4f})")
print(f"Power: {power:.4f}")

# Recommendation: Boleto takes ~2.7 days longer than debit card
# Effect is statistically significant but small (d=0.31)
# Payment method is a minor factor in delivery time - not a priority lever
