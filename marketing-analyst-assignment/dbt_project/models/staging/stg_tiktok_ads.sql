with source as (
    select * from {{ source('raw', 'tiktok_ads') }}
),

renamed as (
    select
        date,
        'TikTok'                                as platform,
        campaign_id,
        campaign_name,
        adgroup_id                              as ad_group_id,
        adgroup_name                            as ad_group_name,
        impressions,
        clicks,
        cost,
        conversions,
        video_views,
        video_watch_25,
        video_watch_50,
        video_watch_75,
        video_watch_100,
        likes,
        shares,
        comments

    from source
)

select * from renamed
