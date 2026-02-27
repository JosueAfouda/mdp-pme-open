select
  cast(id as integer) as product_id,
  product_name,
  cast(unit_cost as numeric(10, 3)) as unit_cost,
  cast(unit_price as numeric(10, 2)) as unit_price,
  _sdc_extracted_at
from {{ source('raw', 'products') }}
