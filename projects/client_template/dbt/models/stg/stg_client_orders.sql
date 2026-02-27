-- Template staging: normalisation d'une table brute de commandes.
select
  cast(order_id as bigint) as order_id,
  cast(customer_id as bigint) as customer_id,
  cast(order_date as date) as order_date,
  cast(order_total as numeric(18, 2)) as order_total
from raw.orders
