-- Final unified ads mart — this is the table powering the dashboard.
-- Adds all derived KPIs on top of the unioned intermediate model.

with base as (
    select * from {{ ref('int_ads_unioned') }}
)

select
    -- Dimensions
    date,
    platform,
    campaign_id,
    campaign_name,
    ad_group_id,
    ad_group_name,

    -- Core volume metrics
    impressions,
    clicks,
    cost,
    conversions,
    video_views,

    -- Derived efficiency metrics
    safe_divide(clicks, impressions)        as ctr,
    safe_divide(cost, clicks)               as avg_cpc,
    safe_divide(cost, impressions) * 1000   as cpm,
    safe_divide(cost, conversions)          as cpa,

    -- Facebook-specific
    reach,
    frequency,
    engagement_rate,

    -- Google-specific
    conversion_value,
    safe_divide(conversion_value, cost)     as roas,
    quality_score,
    search_impression_share,

    -- TikTok video funnel
    video_watch_25,
    video_watch_50,
    video_watch_75,
    video_watch_100,
    safe_divide(video_watch_100, video_views) as video_completion_rate,

    -- TikTok social engagement
    likes,
    shares,
    comments,
    safe_divide(
        coalesce(likes, 0) + coalesce(shares, 0) + coalesce(comments, 0),
        nullif(impressions, 0)
    )                                       as social_engagement_rate

from base
