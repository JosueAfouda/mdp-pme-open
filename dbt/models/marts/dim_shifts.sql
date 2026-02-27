select
  shift_id,
  employee_id,
  shift_date,
  role,
  shift_window,
  shift_start_at,
  shift_end_at,
  shift_duration_hours
from {{ ref('stg_shifts') }}
