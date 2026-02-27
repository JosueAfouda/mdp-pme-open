select
  md5(concat_ws('||', sold_date::text, product_id::text)) as product_day_key,
  sold_date,
  product_id,
  product_name,
  sum(quantity_sold) as sales_volume,
  sum(sales_revenue) as sales_revenue,
  sum(discount_amount) as total_discount_amount,
  sum(cogs_amount) as total_cogs,
  sum(gross_profit) as gross_profit,
  count(distinct sales_id) as number_of_transactions
from {{ ref('fct_sales_lines') }}
group by 1, 2, 3, 4
