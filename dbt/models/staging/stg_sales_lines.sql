select
  cast(id as integer) as sales_line_id,
  cast(sales_id as integer) as sales_id,
  cast(product_id as integer) as product_id,
  cast(nullif(promotion_id, '') as numeric(10, 0))::integer as promotion_id,
  cast(date as date) as sold_date,
  cast(quantity_sold as integer) as quantity_sold,
  cast(discount_rate as numeric(10, 4)) as discount_rate,
  cast(unit_price as numeric(10, 2)) as unit_price,
  cast(unit_discount as numeric(10, 2)) as unit_discount,
  cast(total_price as numeric(10, 2)) as total_price,
  cast(total_discount as numeric(10, 2)) as total_discount,
  _sdc_extracted_at
from {{ source('raw', 'sales_lines') }}
