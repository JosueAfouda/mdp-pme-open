with parsed as (
  select
    md5(concat_ws('||', date, role, employee_id, hours)) as shift_id,
    cast(employee_id as integer) as employee_id,
    cast(date as date) as shift_date,
    role,
    hours as shift_window,
    cast(split_part(hours, '-', 1) as time) as shift_start_time,
    cast(split_part(hours, '-', 2) as time) as shift_end_time,
    _sdc_extracted_at
  from {{ source('raw', 'shifts') }}
)

select
  shift_id,
  employee_id,
  shift_date,
  role,
  shift_window,
  cast(shift_date as timestamp) + shift_start_time as shift_start_at,
  cast(shift_date as timestamp) + shift_end_time as shift_end_at,
  extract(
    epoch from (
      (cast(shift_date as timestamp) + shift_end_time)
      - (cast(shift_date as timestamp) + shift_start_time)
    )
  ) / 3600.0 as shift_duration_hours,
  _sdc_extracted_at
from parsed
