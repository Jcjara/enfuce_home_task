with card_months as (

    select
        c.card_id,
        c.customer_id,
        c.account_id,
        m.month_start_date,
        m.month_end_date,
        c.card_status,
        c.card_start_date,
        c.card_end_date,
        c.card_status in (
            'CARD OK',
            'CARD NO RENEWAL',
            'CARD BLOCKED'
        ) as is_card_active
    from {{ ref('stg_cards') }} c
    inner join {{ ref('int_month_spine') }} m
        on c.card_start_date <= m.month_end_date
       and c.card_end_date >= m.month_start_date

    qualify row_number() over (
        partition by c.card_id, m.month_start_date
        order by c.card_start_date desc
    ) = 1

),

account_months as (

    select
        a.account_id,
        m.month_start_date,
        a.account_status,
        a.account_start_date,
        a.account_end_date,
        a.account_status = 'ACCOUNT CLOSED' as is_account_closed
    from {{ ref('stg_accounts') }} a
    inner join {{ ref('int_month_spine') }} m
        on a.account_start_date <= m.month_end_date
        and a.account_end_date >= m.month_start_date

    qualify row_number() over (
        partition by a.account_id, m.month_start_date
        order by a.account_start_date desc
    ) = 1


),

final as (

    select
        concat(cm.card_id, '-', cm.month_start_date) as card_month_key,
        cm.card_id,
        cm.customer_id,
        cm.account_id,
        cm.month_start_date,
        cm.month_end_date,
        cm.card_status,
        am.account_status,
        cm.is_card_active,
        coalesce(am.is_account_closed, false) as is_account_closed,
        cm.is_card_active and not coalesce(am.is_account_closed, false) as is_billable_card,
        cm.card_start_date,
        cm.card_end_date,
        am.account_start_date,
        am.account_end_date
    from card_months cm
    left join account_months am
        on cm.account_id = am.account_id
        and cm.month_start_date = am.month_start_date

)

select *
from final