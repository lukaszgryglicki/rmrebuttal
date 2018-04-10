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
), top_contributors as (
select sub.date_from,
  sub.date_to,
  sub.release,
  sub.actor,
  sub.events
from (
  select d.f as date_from,
    d.t as date_to,
    d.rel as release,
    e.dup_actor_login as actor,
    row_number() over actors_by_activity as rank,
    count(distinct e.id) as events
  from
    dates d,
    gha_events e
  where
    e.created_at >= d.f
    and e.created_at < d.t
    and (e.dup_actor_login {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent'
    )
  group by
    d.f,
    d.t,
    d.rel,
    e.dup_actor_login
  window
    actors_by_activity as (
      partition by
        d.f
      order by
        count(distinct e.id) desc
    )
  ) sub
where
  sub.rank <= 10
)
select * from top_contributors;
/*
select
  d.f as date_from,
  d.t as date_to,
  d.rel as release,
  count(distinct e.actor_id) filter (where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent')) as contributors,
  count(distinct e.actor_id) filter (where e.type = 'PushEvent') as committers,
  count(distinct e.actor_id) filter (where e.type = 'IssuesEvent') as issuers,
  count(distinct e.actor_id) filter (where e.type = 'PullRequestEvent') as pr_creators,
  count(distinct e.actor_id) filter (where e.type = 'PullRequestReviewCommentEvent') as pr_reviewers,
  count(distinct e.actor_id) filter (where e.type in ('IssueCommentEvent', 'IssueCommentEvent')) as commenters,
  count(distinct af.company_name) filter (where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent') and af.company_name is not null) as contributing_coms,
  count(distinct af.company_name) filter (where e.type = 'PushEvent' and af.company_name is not null) as committing_coms,
  count(distinct af.company_name) filter (where e.type = 'IssuesEvent' and af.company_name is not null) as issuers_coms,
  count(distinct af.company_name) filter (where e.type = 'PullRequestEvent' and af.company_name is not null) as pr_creating_coms,
  count(distinct af.company_name) filter (where e.type = 'PullRequestReviewCommentEvent' and af.company_name is not null) as pr_reviewing_coms,
  count(distinct af.company_name) filter (where e.type in ('IssueCommentEvent', 'IssueCommentEvent') and af.company_name is not null) as commenting_coms,
from
  dates d,
  gha_events e
left join
  gha_actors_affiliations af
on
  e.actor_id = af.actor_id
  and af.dt_from <= e.created_at
  and af.dt_to > e.created_at
where
  e.created_at >= d.f
  and e.created_at < d.t
  and (e.dup_actor_login {{exclude_bots}})
  and e.type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent',
    'PullRequestReviewCommentEvent',
    'IssueCommentEvent', 'IssueCommentEvent'
  )
group by
  d.f,
  d.t,
  d.rel
order by
  d.f
;*/
/*
  string_agg(e.dup_actor_login, ',') filter (where e.actor_id in (
    select actor_id
    from
      gha_events inn
    where
      inn.type = 'PushEvent'
      and inn.created_at >= d.f
      and inn.created_at < d.t
      and (inn.dup_actor_login {{exclude_bots}})
    group by
      inn.actor_id
    order by
      count(id) desc
    limit 
      10
  )) as top_10_committers
*/
