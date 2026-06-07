# Senior Marketing Analyst - Technical Assignment

## Overview
This project unifies raw advertising data from three platforms (Facebook, Google, TikTok) into a single cross-channel analytics model, with a live dashboard for performance insights.

## Stack
- **BigQuery** — cloud database (Google Cloud free tier)
- **dbt** — data transformation and unified model
- **Looker Studio** — live interactive dashboard

## Repository Structure
```
marketing-analyst-assignment/
├── 01_facebook_ads.csv          # Source data: Facebook Ads
├── 02_google_ads.csv            # Source data: Google Ads
├── 03_tiktok_ads.csv            # Source data: TikTok Ads
├── upload_to_bigquery.py        # Script to load CSVs into BigQuery
├── requirements.txt             # Python dependencies
├── sql/
│   ├── 01_source_tables.sql     # BigQuery DDL for source tables
│   └── 02_unified_ads_model.sql # Unified cross-channel table (standalone SQL)
└── dbt_project/
    └── models/
        ├── staging/             # Normalize raw schemas per platform
        ├── intermediate/        # Union all three platforms
        └── marts/               # Final table with derived KPIs (CTR, CPA, CPM, ROAS)
```

## Data Model

The unified model normalizes three platforms into a single schema:

| Field | Description |
|---|---|
| `platform` | Facebook / Google / TikTok |
| `cost` | Normalized from `spend` (FB) and `cost` (Google/TikTok) |
| `ctr` | Click-through rate (clicks / impressions) |
| `cpa` | Cost per acquisition (cost / conversions) |
| `cpm` | Cost per 1,000 impressions |
| `roas` | Return on ad spend — Google only |
| `video_completion_rate` | 100% watch rate — TikTok only |

Platform-specific columns (reach, frequency, quality_score, video_watch_%, likes/shares/comments) are preserved with `NULL` for platforms where not applicable.

## Setup

### 1. Install dependencies
```bash
pip install -r requirements.txt
```

### 2. Upload source tables to BigQuery
```bash
gcloud auth application-default login
python upload_to_bigquery.py --project YOUR_PROJECT_ID
```

### 3. Run dbt to build the unified model
```bash
cd dbt_project
dbt debug    # verify connection
dbt run      # staging → intermediate → mart
dbt test     # data quality checks
```

Or run the standalone SQL directly in the BigQuery console: `sql/02_unified_ads_model.sql`

## Dashboard

**[Live Dashboard →](https://lookerstudio.google.com)**

Built in Looker Studio on top of the `unified_ads` BigQuery table. Includes:
- KPI scorecards: Total Spend, Impressions, Clicks, Conversions, CTR, CPA
- Spend by Platform (bar chart)
- Impressions over time by platform (time series)
- Conversions by Platform (donut chart)
- Campaign performance table
- Avg CPA by Platform (bar chart)
- Spend vs. Conversions by Campaign (bubble chart — bubble size = impressions)
