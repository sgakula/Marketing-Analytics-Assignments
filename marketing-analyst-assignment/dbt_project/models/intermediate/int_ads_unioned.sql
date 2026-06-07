-- Unions all three platforms into a common schema.
-- Platform-specific columns are null-coalesced where not applicable.

with facebook as (
    select
        date,
        platform,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        impressions,
        clicks,
        cost,
        conversions,
        video_views,
        -- Facebook-specific
        reach,
        frequency,
        engagement_rate,
        -- Google-specific
        cast(null as float64)   as conversion_value,
        cast(null as int64)     as quality_score,
        cast(null as float64)   as search_impression_share,
        -- TikTok-specific
        cast(null as int64)     as video_watch_25,
        cast(null as int64)     as video_watch_50,
        cast(null as int64)     as video_watch_75,
        cast(null as int64)     as video_watch_100,
        cast(null as int64)     as likes,
        cast(null as int64)     as shares,
        cast(null as int64)     as comments
    from {{ ref('stg_facebook_ads') }}
),

google as (
    select
        date,
        platform,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        impressions,
        clicks,
        cost,
        conversions,
        cast(null as int64)     as video_views,
        -- Facebook-specific
        cast(null as int64)     as reach,
        cast(null as float64)   as frequency,
        cast(null as float64)   as engagement_rate,
        -- Google-specific
        conversion_value,
        quality_score,
        search_impression_share,
        -- TikTok-specific
        cast(null as int64)     as video_watch_25,
        cast(null as int64)     as video_watch_50,
        cast(null as int64)     as video_watch_75,
        cast(null as int64)     as video_watch_100,
        cast(null as int64)     as likes,
        cast(null as int64)     as shares,
        cast(null as int64)     as comments
    from {{ ref('stg_google_ads') }}
),

tiktok as (
    select
        date,
        platform,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        impressions,
        clicks,
        cost,
        conversions,
        video_views,
        -- Facebook-specific
        cast(null as int64)     as reach,
        cast(null as float64)   as frequency,
        cast(null as float64)   as engagement_rate,
        -- Google-specific
        cast(null as float64)   as conversion_value,
        cast(null as int64)     as quality_score,
        cast(null as float64)   as search_impression_share,
        -- TikTok-specific
        video_watch_25,
        video_watch_50,
        video_watch_75,
        video_watch_100,
        likes,
        shares,
        comments
    from {{ ref('stg_tiktok_ads') }}
)

select * from facebook
union all
select * from google
union all
select * from tiktok
