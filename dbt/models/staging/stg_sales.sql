select
  cast(sales_id as integer) as sales_id,
  cast(employee_id as integer) as employee_id,
  cast(date as date) as sold_date,
  cast(time as time) as sold_time,
  cast(date as timestamp) + cast(time as time) as sold_at,
  weekday,
  payment_type,
  cast(total_price as numeric(10, 2)) as total_price,
  cast(total_discount as numeric(10, 2)) as total_discount,
  _sdc_extracted_at
from {{ source('raw', 'sales') }}
