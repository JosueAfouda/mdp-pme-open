select
  cast(id as integer) as promotion_id,
  cast(product_id as integer) as product_id,
  name as promotion_name,
  description,
  cast(start_date as date) as promotion_start_date,
  cast(end_date as date) as promotion_end_date,
  cast(discount_rate as numeric(10, 4)) as discount_rate,
  cast(is_holiday as boolean) as is_holiday,
  _sdc_extracted_at
from {{ source('raw', 'promotions') }}
