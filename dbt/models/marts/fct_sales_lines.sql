with sales as (
  select * from {{ ref('stg_sales') }}
),
sales_lines as (
  select * from {{ ref('stg_sales_lines') }}
),
products as (
  select * from {{ ref('dim_products') }}
),
employees as (
  select * from {{ ref('dim_employees') }}
),
promotions as (
  select * from {{ ref('dim_promotions') }}
)

select
  sales_lines.sales_line_id,
  sales.sales_id,
  sales.employee_id as cashier_employee_id,
  employees.full_name as cashier_employee_name,
  sales_lines.product_id,
  products.product_name,
  sales_lines.promotion_id,
  promotions.promotion_name,
  sales.sold_date,
  sales.sold_at,
  sales.weekday,
  sales.payment_type,
  sales_lines.quantity_sold,
  sales_lines.discount_rate,
  sales_lines.unit_price,
  products.unit_cost,
  sales_lines.unit_discount,
  sales_lines.total_discount as discount_amount,
  sales_lines.quantity_sold * sales_lines.unit_price as gross_sales_amount,
  sales_lines.total_price as sales_revenue,
  sales_lines.quantity_sold * products.unit_cost as cogs_amount,
  sales_lines.total_price - (sales_lines.quantity_sold * products.unit_cost) as gross_profit,
  (sales_lines.promotion_id is not null) as has_promotion
from sales_lines
left join sales
  on sales_lines.sales_id = sales.sales_id
left join products
  on sales_lines.product_id = products.product_id
left join employees
  on sales.employee_id = employees.employee_id
left join promotions
  on sales_lines.promotion_id = promotions.promotion_id
