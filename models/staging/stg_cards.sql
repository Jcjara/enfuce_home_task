with source as (

    select *
    from {{ source('raw', 'cards') }}

)

select
    cast(card_id as varchar) as card_id,
    cast(account_id as varchar) as account_id,
    cast(customer as varchar) as customer_id,
    cast(start_date as date) as card_start_date,
    cast(end_date as date) as card_end_date,
    upper(trim(card_status)) as card_status
from source