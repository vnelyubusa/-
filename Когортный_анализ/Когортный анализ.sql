with a as (
  select 
    card,
    datetime,
    first_value(to_char(datetime, 'YYYY-MM')) over(partition by card order by datetime) as cohort,
    extract(days from datetime - first_value(datetime) over(partition by card order by datetime)) as diff,   
    summ
  from bonuscheques
  where card like '2000%'
) 
select 
  cohort,
  count(distinct card) as cnt,
  max(diff) as max_diff,
  sum(case when diff = 0 then summ end) / count(distinct card) as "0",
  case when max(diff) > 0 then sum(case when diff <= 30 then summ end) / count(distinct card) end
 as "30",
  case when max(diff) > 30 then sum(case when diff <= 60 then summ end) / count(distinct card) end as "60",
  case when max(diff) > 60 then sum(case when diff <= 90 then summ end) / count(distinct card) end as "90",
  case when max(diff) > 90 then sum(case when diff <= 180 then summ end) / count(distinct card) end as "180",
  case when max(diff) > 180 then sum(case when diff <= 300 then summ end) / count(distinct card) end as "300"
from a
group by cohort