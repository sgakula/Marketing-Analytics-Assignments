"""
Upload the three ad platform CSVs to BigQuery.

Prerequisites:
    pip install google-cloud-bigquery pandas pyarrow
    gcloud auth application-default login   (or set GOOGLE_APPLICATION_CREDENTIALS)

Usage:
    python upload_to_bigquery.py --project YOUR_PROJECT_ID
"""

import argparse
from pathlib import Path

import pandas as pd
from google.cloud import bigquery

DATASET_ID = "marketing_analytics"
SCRIPT_DIR = Path(__file__).parent

TABLE_CONFIGS = [
    {
        "file": "01_facebook_ads.csv",
        "table": "facebook_ads",
        "schema": [
            bigquery.SchemaField("date", "DATE"),
            bigquery.SchemaField("campaign_id", "STRING"),
            bigquery.SchemaField("campaign_name", "STRING"),
            bigquery.SchemaField("ad_set_id", "STRING"),
            bigquery.SchemaField("ad_set_name", "STRING"),
            bigquery.SchemaField("impressions", "INTEGER"),
            bigquery.SchemaField("clicks", "INTEGER"),
            bigquery.SchemaField("spend", "FLOAT"),
            bigquery.SchemaField("conversions", "INTEGER"),
            bigquery.SchemaField("video_views", "INTEGER"),
            bigquery.SchemaField("engagement_rate", "FLOAT"),
            bigquery.SchemaField("reach", "INTEGER"),
            bigquery.SchemaField("frequency", "FLOAT"),
        ],
    },
    {
        "file": "02_google_ads.csv",
        "table": "google_ads",
        "schema": [
            bigquery.SchemaField("date", "DATE"),
            bigquery.SchemaField("campaign_id", "STRING"),
            bigquery.SchemaField("campaign_name", "STRING"),
            bigquery.SchemaField("ad_group_id", "STRING"),
            bigquery.SchemaField("ad_group_name", "STRING"),
            bigquery.SchemaField("impressions", "INTEGER"),
            bigquery.SchemaField("clicks", "INTEGER"),
            bigquery.SchemaField("cost", "FLOAT"),
            bigquery.SchemaField("conversions", "INTEGER"),
            bigquery.SchemaField("conversion_value", "FLOAT"),
            bigquery.SchemaField("ctr", "FLOAT"),
            bigquery.SchemaField("avg_cpc", "FLOAT"),
            bigquery.SchemaField("quality_score", "INTEGER"),
            bigquery.SchemaField("search_impression_share", "FLOAT"),
        ],
    },
    {
        "file": "03_tiktok_ads.csv",
        "table": "tiktok_ads",
        "schema": [
            bigquery.SchemaField("date", "DATE"),
            bigquery.SchemaField("campaign_id", "STRING"),
            bigquery.SchemaField("campaign_name", "STRING"),
            bigquery.SchemaField("adgroup_id", "STRING"),
            bigquery.SchemaField("adgroup_name", "STRING"),
            bigquery.SchemaField("impressions", "INTEGER"),
            bigquery.SchemaField("clicks", "INTEGER"),
            bigquery.SchemaField("cost", "FLOAT"),
            bigquery.SchemaField("conversions", "INTEGER"),
            bigquery.SchemaField("video_views", "INTEGER"),
            bigquery.SchemaField("video_watch_25", "INTEGER"),
            bigquery.SchemaField("video_watch_50", "INTEGER"),
            bigquery.SchemaField("video_watch_75", "INTEGER"),
            bigquery.SchemaField("video_watch_100", "INTEGER"),
            bigquery.SchemaField("likes", "INTEGER"),
            bigquery.SchemaField("shares", "INTEGER"),
            bigquery.SchemaField("comments", "INTEGER"),
        ],
    },
]


def ensure_dataset(client: bigquery.Client, project: str) -> None:
    dataset_ref = bigquery.Dataset(f"{project}.{DATASET_ID}")
    dataset_ref.location = "US"
    client.create_dataset(dataset_ref, exists_ok=True)
    print(f"Dataset `{project}.{DATASET_ID}` ready.")


def upload_table(client: bigquery.Client, project: str, config: dict) -> None:
    csv_path = SCRIPT_DIR / config["file"]
    df = pd.read_csv(csv_path, parse_dates=["date"])
    df["date"] = df["date"].dt.date
    table_id = f"{project}.{DATASET_ID}.{config['table']}"

    job_config = bigquery.LoadJobConfig(
        schema=config["schema"],
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )

    job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
    job.result()
    print(f"Loaded {len(df):,} rows into `{table_id}`")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", required=True, help="GCP project ID")
    args = parser.parse_args()

    client = bigquery.Client(project=args.project)
    ensure_dataset(client, args.project)

    for config in TABLE_CONFIGS:
        upload_table(client, args.project, config)

    print("\nAll tables uploaded. Now run sql/02_unified_ads_model.sql in BigQuery.")


if __name__ == "__main__":
    main()
