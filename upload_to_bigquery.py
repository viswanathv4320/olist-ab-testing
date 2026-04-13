from google.cloud import bigquery
from pathlib import Path
import pandas as pd

client = bigquery.Client()

project_id = "project-ccbf6acf-9991-4d10-82d"
dataset_id = "olist"

data_folder = Path("data")
for csv_file in data_folder.glob("*.csv"):
    table_id = f"{project_id}.{dataset_id}.{csv_file.stem}"

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        autodetect=True,
        skip_leading_rows=1,
    )


    if csv_file.stem == "olist_products_dataset":
        df = pd.read_csv(csv_file, on_bad_lines='skip')
        
        job_config = bigquery.LoadJobConfig(
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE
        )
        
        job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
        job.result()
        print(f"Uploaded {csv_file.stem}")
