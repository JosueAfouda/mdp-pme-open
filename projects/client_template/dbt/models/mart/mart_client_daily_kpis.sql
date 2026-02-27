-- Template mart: KPI journaliers.
select
  order_date,
  count(distinct order_id) as number_of_orders,
  sum(order_total) as sales_revenue,
  avg(order_total) as average_order_value
from {{ ref('stg_client_orders') }}
group by 1
