with transaction_kpis as (
  select
    sold_date,
    count(distinct sales_id) as number_of_transactions,
    sum(total_price) as sales_revenue,
    avg(total_price) as average_transaction_value
  from {{ ref('stg_sales') }}
  group by 1
),
line_kpis as (
  select
    sold_date,
    sum(quantity_sold) as sales_volume,
    sum(discount_amount) as total_discount_amount,
    sum(cogs_amount) as total_cogs,
    sum(gross_profit) as gross_profit
  from {{ ref('fct_sales_lines') }}
  group by 1
)

select
  transaction_kpis.sold_date,
  transaction_kpis.sales_revenue,
  line_kpis.sales_volume,
  line_kpis.gross_profit,
  transaction_kpis.number_of_transactions,
  transaction_kpis.average_transaction_value,
  line_kpis.total_discount_amount,
  line_kpis.total_cogs
from transaction_kpis
inner join line_kpis
  on transaction_kpis.sold_date = line_kpis.sold_date
