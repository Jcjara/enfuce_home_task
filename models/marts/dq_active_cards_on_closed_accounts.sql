select
    card_month_key,
    card_id,
    customer_id,
    account_id,
    invoice_month,
    invoice_month_end,
    card_status,
    account_status,
    card_start_date,
    card_end_date,
    account_start_date,
    account_end_date
from {{ ref('int_billable_cards_monthly') }}
where is_card_active
    and is_account_closed