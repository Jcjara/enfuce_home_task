with source as (

    select *
    from {{ source('raw', 'accounts') }}

)

select
    cast(account_id as varchar) as account_id,
    cast(start_date as date) as account_start_date,
    cast(end_date as date) as account_end_date,
    upper(trim(account_status)) as account_status
from source