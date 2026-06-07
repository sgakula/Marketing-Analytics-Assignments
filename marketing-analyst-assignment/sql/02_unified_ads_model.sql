-- ============================================================
-- Step 2: Unified cross-channel ads model
-- Creates a single table combining Facebook, Google, and TikTok
-- with normalized fields and platform-specific columns nullable
-- ============================================================

CREATE OR REPLACE TABLE `improvado-498319.marketing_analytics.unified_ads` AS

WITH facebook AS (
  SELECT
    date,
    'Facebook'                              AS platform,
    campaign_id,
    campaign_name,
    ad_set_id                               AS ad_group_id,
    ad_set_name                             AS ad_group_name,
    impressions,
    clicks,
    spend                                   AS cost,
    conversions,
    video_views,
    -- Calculated core metrics
    SAFE_DIVIDE(clicks, impressions)        AS ctr,
    SAFE_DIVIDE(spend, clicks)              AS avg_cpc,
    SAFE_DIVIDE(spend, impressions) * 1000  AS cpm,
    SAFE_DIVIDE(spend, conversions)         AS cpa,
    -- Facebook-specific
    reach,
    frequency,
    engagement_rate,
    -- Google-specific (null for Facebook)
    CAST(NULL AS FLOAT64)                   AS conversion_value,
    CAST(NULL AS INT64)                     AS quality_score,
    CAST(NULL AS FLOAT64)                   AS search_impression_share,
    -- TikTok-specific (null for Facebook)
    CAST(NULL AS INT64)                     AS video_watch_25,
    CAST(NULL AS INT64)                     AS video_watch_50,
    CAST(NULL AS INT64)                     AS video_watch_75,
    CAST(NULL AS INT64)                     AS video_watch_100,
    CAST(NULL AS INT64)                     AS likes,
    CAST(NULL AS INT64)                     AS shares,
    CAST(NULL AS INT64)                     AS comments
  FROM `improvado-498319.marketing_analytics.facebook_ads`
),

google AS (
  SELECT
    date,
    'Google'                                AS platform,
    campaign_id,
    campaign_name,
    ad_group_id,
    ad_group_name,
    impressions,
    clicks,
    cost,
    conversions,
    CAST(NULL AS INT64)                     AS video_views,
    -- Calculated core metrics (use source fields where available)
    ctr,
    avg_cpc,
    SAFE_DIVIDE(cost, impressions) * 1000   AS cpm,
    SAFE_DIVIDE(cost, conversions)          AS cpa,
    -- Facebook-specific (null for Google)
    CAST(NULL AS INT64)                     AS reach,
    CAST(NULL AS FLOAT64)                   AS frequency,
    CAST(NULL AS FLOAT64)                   AS engagement_rate,
    -- Google-specific
    conversion_value,
    quality_score,
    search_impression_share,
    -- TikTok-specific (null for Google)
    CAST(NULL AS INT64)                     AS video_watch_25,
    CAST(NULL AS INT64)                     AS video_watch_50,
    CAST(NULL AS INT64)                     AS video_watch_75,
    CAST(NULL AS INT64)                     AS video_watch_100,
    CAST(NULL AS INT64)                     AS likes,
    CAST(NULL AS INT64)                     AS shares,
    CAST(NULL AS INT64)                     AS comments
  FROM `improvado-498319.marketing_analytics.google_ads`
),

tiktok AS (
  SELECT
    date,
    'TikTok'                                AS platform,
    campaign_id,
    campaign_name,
    adgroup_id                              AS ad_group_id,
    adgroup_name                            AS ad_group_name,
    impressions,
    clicks,
    cost,
    conversions,
    video_views,
    -- Calculated core metrics
    SAFE_DIVIDE(clicks, impressions)        AS ctr,
    SAFE_DIVIDE(cost, clicks)               AS avg_cpc,
    SAFE_DIVIDE(cost, impressions) * 1000   AS cpm,
    SAFE_DIVIDE(cost, conversions)          AS cpa,
    -- Facebook-specific (null for TikTok)
    CAST(NULL AS INT64)                     AS reach,
    CAST(NULL AS FLOAT64)                   AS frequency,
    CAST(NULL AS FLOAT64)                   AS engagement_rate,
    -- Google-specific (null for TikTok)
    CAST(NULL AS FLOAT64)                   AS conversion_value,
    CAST(NULL AS INT64)                     AS quality_score,
    CAST(NULL AS FLOAT64)                   AS search_impression_share,
    -- TikTok-specific
    video_watch_25,
    video_watch_50,
    video_watch_75,
    video_watch_100,
    likes,
    shares,
    comments
  FROM `improvado-498319.marketing_analytics.tiktok_ads`
)

SELECT * FROM facebook
UNION ALL
SELECT * FROM google
UNION ALL
SELECT * FROM tiktok;


-- ============================================================
-- Verification queries — run these after creating the table
-- ============================================================

-- Row counts by platform
SELECT platform, COUNT(*) AS row_count, SUM(cost) AS total_spend
FROM `improvado-498319.marketing_analytics.unified_ads`
GROUP BY platform
ORDER BY total_spend DESC;

-- Overall KPIs
SELECT
  ROUND(SUM(cost), 2)                         AS total_spend,
  SUM(impressions)                             AS total_impressions,
  SUM(clicks)                                  AS total_clicks,
  SUM(conversions)                             AS total_conversions,
  ROUND(SAFE_DIVIDE(SUM(clicks), SUM(impressions)) * 100, 2)    AS overall_ctr_pct,
  ROUND(SAFE_DIVIDE(SUM(cost), SUM(conversions)), 2)            AS overall_cpa,
  ROUND(SAFE_DIVIDE(SUM(cost), SUM(impressions)) * 1000, 2)     AS overall_cpm
FROM `improvado-498319.marketing_analytics.unified_ads`;
