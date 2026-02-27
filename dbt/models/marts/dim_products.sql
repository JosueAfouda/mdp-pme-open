select
  product_id,
  product_name,
  unit_cost,
  unit_price
from {{ ref('stg_products') }}
