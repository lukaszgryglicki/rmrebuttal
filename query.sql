with dates as (
  select '2014-01-01 00:00:00'::timestamp as f, '2015-07-11 04:02:31' as t, 'start - v1.0.0' as rel
  union select '2015-07-11 04:02:31'::timestamp as f, '2015-09-25 23:41:40'::timestamp as t, 'v1.0.0 - v1.1.0' as rel
  union select '2015-09-25 23:41:40'::timestamp as f, '2016-03-16 22:01:03'::timestamp as t, 'v1.1.0 - v1.2.0' as rel
  union select '2016-03-16 22:01:03'::timestamp as f, '2016-07-01 19:19:06'::timestamp as t, 'v1.2.0 - v1.3.0' as rel
  union select '2016-07-01 19:19:06'::timestamp as f, '2016-09-26 18:09:47'::timestamp as t, 'v1.3.0 - v1.4.0' as rel
  union select '2016-09-26 18:09:47'::timestamp as f, '2016-12-12 23:29:43'::timestamp as t, 'v1.4.0 - v1.5.0' as rel
  union select '2016-12-12 23:29:43'::timestamp as f, '2017-03-28 16:23:06'::timestamp as t, 'v1.5.0 - v1.6.0' as rel
  union select '2017-03-28 16:23:06'::timestamp as f, '2017-06-29 22:53:16'::timestamp as t, 'v1.6.0 - v1.7.0' as rel
  union select '2017-06-29 22:53:16'::timestamp as f, '2017-09-28 22:13:57'::timestamp as t, 'v1.7.0 - v1.8.0' as rel
  union select '2017-09-28 22:13:57'::timestamp as f, '2017-12-15 20:53:13'::timestamp as t, 'v1.8.0 - v1.9.0' as rel
  union select '2017-12-15 20:53:13'::timestamp as f, '2018-03-26 16:41:58'::timestamp as t, 'v1.9.0 - v1.10.0' as rel
  union select '2018-03-26 16:41:58'::timestamp as f, now() as t, 'v1.10.0 - now' as rel
)
select
  d.f as date_from,
  d.t as date_to,
  d.rel as kubernetes_release,
  count(distinct dup_actor_login) as contributors
from
  gha_events e,
  dates d
where
  e.created_at >= d.f
  and e.created_at < d.t
  and (e.dup_actor_login {{exclude_bots}})
  and e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent')
group by
  d.f,
  d.t,
  d.rel
order by
  d.f
; 
