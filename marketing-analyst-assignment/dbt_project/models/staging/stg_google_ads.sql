with source as (
    select * from {{ source('raw', 'google_ads') }}
),

renamed as (
    select
        date,
        'Google'                                as platform,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        impressions,
        clicks,
        cost,
        conversions,
        conversion_value,
        ctr,
        avg_cpc,
        quality_score,
        search_impression_share

    from source
)

select * from renamed
