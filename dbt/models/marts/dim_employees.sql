select
  employee_id,
  first_name,
  last_name,
  full_name,
  contact_number,
  birth_date,
  hire_date,
  hourly_rate
from {{ ref('stg_employees') }}
