with numbers as (

    select seq4() as month_offset
    from table(generator(rowcount => 1000))

),

month_spine as (

    select
        dateadd(month, month_offset, '2020-01-01'::date) as month_start_date
    from numbers

)

select
    month_start_date,
    last_day(month_start_date) as month_end_date
from month_spine
where month_start_date <= date_trunc('month', current_date())