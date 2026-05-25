with card_months as (

    select
        c.card_id,
        c.customer_id,
        c.account_id,
        m.invoice_month,
        m.invoice_month_end,
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
        on c.card_start_date <= m.invoice_month_end
       and c.card_end_date >= m.invoice_month

    qualify row_number() over (
        partition by c.card_id, m.invoice_month
        order by c.card_start_date desc
    ) = 1

),

account_months as (

    select
        a.account_id,
        m.invoice_month,
        a.account_status,
        a.account_start_date,
        a.account_end_date,
        a.account_status = 'ACCOUNT CLOSED' as is_account_closed
    from {{ ref('stg_accounts') }} a
    inner join {{ ref('int_month_spine') }} m
        on a.account_start_date <= m.invoice_month_end
        and coalesce(a.account_end_date, '9999-12-31'::date) >= m.invoice_month

    qualify row_number() over (
        partition by a.account_id, m.invoice_month
        order by a.account_start_date desc
    ) = 1


),

final as (

    select
        concat(cm.card_id, '-', cm.invoice_month) as card_month_key,
        cm.card_id,
        cm.customer_id,
        cm.account_id,
        cm.invoice_month,
        cm.invoice_month_end,
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
        and cm.invoice_month = am.invoice_month

)

select *
from final