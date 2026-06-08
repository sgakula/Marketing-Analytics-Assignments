# Senior Marketing Analyst — Technical Assignment

## Overview
This project unifies raw advertising data from three platforms (Facebook, Google, TikTok) into a single cross-channel analytics model, with a live dashboard for performance insights.

## Stack
- **BigQuery** — cloud database (Google Cloud free tier)
- **Looker Studio** — live interactive dashboard

## Live Dashboard
**[Cross-Channel Ads Performance → January 2024](https://datastudio.google.com/reporting/c97cad28-b1f8-4de7-9859-a7cb0441b32e)**

## Repository Structure
```
marketing-analyst-assignment/
├── 01_facebook_ads.csv          # Source data: Facebook Ads
├── 02_google_ads.csv            # Source data: Google Ads
├── 03_tiktok_ads.csv            # Source data: TikTok Ads
├── upload_to_bigquery.py        # Script to load CSVs into BigQuery
├── requirements.txt             # Python dependencies
└── sql/
    ├── 01_source_tables.sql     # BigQuery DDL for source tables
    └── 02_unified_ads_model.sql # Unified cross-channel table
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

### 3. Create the unified table
Run `sql/02_unified_ads_model.sql` in the BigQuery console.
