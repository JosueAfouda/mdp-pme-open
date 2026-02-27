select
  promotion_id,
  product_id,
  promotion_name,
  description,
  promotion_start_date,
  promotion_end_date,
  discount_rate,
  is_holiday
from {{ ref('stg_promotions') }}
