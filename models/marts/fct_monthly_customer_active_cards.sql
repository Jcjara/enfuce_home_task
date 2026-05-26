select
    customer_id,
    month_start_date as invoice_month,
    concat(customer_id, '-', to_char(month_start_date, 'YYYY-MM-DD')) as customer_month_key,
    count(distinct case when is_card_active then card_id end) as active_cards_count,
    count(distinct case when is_billable_card then card_id end) as billable_active_cards_count,
    active_cards_count - billable_active_cards_count as excluded_due_to_closed_account_count
from {{ ref('int_billable_cards_monthly') }}
group by
    customer_id,
    invoice_month