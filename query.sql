with dates as (
  select '2014-01-01 00:00:00'::timestamp as f, '2015-07-11 04:02:31' as t
  union select '2015-07-11 04:02:31'::timestamp as f, '2015-09-25 23:41:40'::timestamp as t
  union select '2015-09-25 23:41:40'::timestamp as f, '2016-03-16 22:01:03'::timestamp as t
  union select '2016-03-16 22:01:03'::timestamp as f, '2016-07-01 19:19:06'::timestamp as t
  union select '2016-07-01 19:19:06'::timestamp as f, '2016-09-26 18:09:47'::timestamp as t
  union select '2016-09-26 18:09:47'::timestamp as f, '2016-12-12 23:29:43'::timestamp as t
  union select '2016-12-12 23:29:43'::timestamp as f, '2017-03-28 16:23:06'::timestamp as t
  union select '2017-03-28 16:23:06'::timestamp as f, '2017-06-29 22:53:16'::timestamp as t
  union select '2017-06-29 22:53:16'::timestamp as f, '2017-09-28 22:13:57'::timestamp as t
  union select '2017-09-28 22:13:57'::timestamp as f, '2017-12-15 20:53:13'::timestamp as t
  union select '2017-12-15 20:53:13'::timestamp as f, '2018-03-26 16:41:58'::timestamp as t
  union select '2018-03-26 16:41:58'::timestamp as f, now() as t
)
select
  d.f,
  d.t,
  count(*) as count
from
  gha_events e,
  dates d
where
  e.created_at >= d.f
  and e.created_at < d.t
group by
  d.f,
  d.t
; 
