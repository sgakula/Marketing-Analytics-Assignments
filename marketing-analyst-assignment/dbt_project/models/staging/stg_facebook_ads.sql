with source as (
    select * from {{ source('raw', 'facebook_ads') }}
),

renamed as (
    select
        date,
        'Facebook'                              as platform,
        campaign_id,
        campaign_name,
        ad_set_id                               as ad_group_id,
        ad_set_name                             as ad_group_name,
        impressions,
        clicks,
        spend                                   as cost,
        conversions,
        video_views,
        reach,
        frequency,
        engagement_rate

    from source
)

select * from renamed
