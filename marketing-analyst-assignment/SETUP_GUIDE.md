# Setup Guide

## Stack
- **BigQuery** — cloud database (free tier)
- **dbt** — data transformation & unified model
- **Looker Studio** — live dashboard

---

## Step 1: BigQuery — Upload Source Tables

### Option A: BigQuery UI (fastest)
1. Go to [console.cloud.google.com/bigquery](https://console.cloud.google.com/bigquery)
2. Create a dataset named `marketing_analytics` (region: US)
3. For each CSV file, click **+ Add > Local file**:
   - `01_facebook_ads.csv` → table name: `facebook_ads`
   - `02_google_ads.csv` → table name: `google_ads`
   - `03_tiktok_ads.csv` → table name: `tiktok_ads`
   - Schema: **Auto detect**, File format: CSV, Header rows: 1

### Option B: Python script
```bash
pip install google-cloud-bigquery pandas pyarrow
gcloud auth application-default login
python upload_to_bigquery.py --project YOUR_PROJECT_ID
```

---

## Step 2: dbt — Run the Unified Model

### Setup
```bash
pip install dbt-bigquery
cd dbt_project

# Create profiles.yml (one-time)
dbt init   # follow prompts for BigQuery OAuth
```

Your `~/.dbt/profiles.yml` should look like:
```yaml
marketing_analytics:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: YOUR_PROJECT_ID
      dataset: marketing_analytics
      threads: 4
      timeout_seconds: 300
      location: US
```

### Run
```bash
dbt deps
dbt run          # creates all staging → intermediate → mart models
dbt test         # runs data quality checks
dbt docs generate && dbt docs serve   # optional: view lineage DAG
```

This creates `marketing_analytics.marts_unified_ads` in BigQuery — the table that powers the dashboard.

---

## Step 3: Looker Studio — Build the Dashboard

1. Go to [lookerstudio.google.com](https://lookerstudio.google.com)
2. **Create → Report → Add data → BigQuery**
3. Select `YOUR_PROJECT > marketing_analytics > marts_unified_ads`

### Dashboard Layout (one page)

#### Row 1 — KPI Scorecards
| Total Spend | Total Impressions | Total Clicks | Total Conversions | Avg CTR | Avg CPA |
|---|---|---|---|---|---|

#### Row 2 — Platform Comparison (Bar charts)
- Spend by Platform
- Conversions by Platform
- CPA by Platform (lower = better)
- CTR by Platform

#### Row 3 — Daily Trend (Time series line chart)
- Metric selector: Impressions / Clicks / Conversions / Spend
- Breakdown by: Platform (3 colored lines)

#### Row 4 — Campaign Performance Table
Columns: Platform | Campaign | Impressions | Clicks | Cost | Conversions | CTR | CPC | CPA
Sort: Cost descending

#### Row 5 — Video & Engagement (Platform-specific)
- Video views trend: Facebook + TikTok
- TikTok video completion funnel (25% / 50% / 75% / 100% watch rates)
- TikTok social engagement: Likes, Shares, Comments

### Filters to add (top of page)
- Date range picker
- Platform filter (checkbox)
- Campaign name filter (dropdown)

---

## Deliverables Checklist
- [ ] Live dashboard link (Looker Studio > Share > Get link)
- [ ] Video walkthrough (Loom or screen recording — 3-5 min)
  - Walk through each section
  - Explain why you chose each widget
  - Call out 2-3 key insights from the data

## Submit at
https://docs.google.com/forms/d/e/1FAIpQLSe-3UpHq1l6TiDMONDecHRa53otacxTReYF7gNIoCmmkW4Xyw/viewform
