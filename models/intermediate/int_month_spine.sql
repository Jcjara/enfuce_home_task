with date_bounds as (

    select
        date_trunc('month', min(start_date)) as min_month,

        least(
            date_trunc('month', max(coalesce(end_date, current_date()))),
            date_trunc('month', current_date())
        ) as max_month

    from (
        select
            card_start_date as start_date,
            card_end_date as end_date
        from {{ ref('stg_cards') }}

        union all

        select
            account_start_date as start_date,
            account_end_date as end_date
        from {{ ref('stg_accounts') }}
    )

),

numbers as (

    select
        seq4() as month_offset
    from table(generator(rowcount => 1000))

),

month_spine as (

    select
        dateadd(month, n.month_offset, d.min_month) as invoice_month
    from date_bounds d
    join numbers n
        on n.month_offset <= datediff(month, d.min_month, d.max_month)

)

select
    invoice_month,
    last_day(invoice_month) as invoice_month_end
from month_spine
order by invoice_month