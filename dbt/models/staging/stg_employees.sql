select
  cast(id as integer) as employee_id,
  name as first_name,
  last_name,
  trim(name || ' ' || last_name) as full_name,
  contact_number,
  cast(date_of_birth as date) as birth_date,
  cast(hire_date as date) as hire_date,
  cast(hourly_rate as numeric(10, 2)) as hourly_rate,
  _sdc_extracted_at
from {{ source('raw', 'employees') }}
