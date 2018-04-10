create or replace function pg_temp.array_uniq_stable(anyarray) returns anyarray AS
$$
select array_agg(distinct_value ORDER BY first_index)
from (
  select
    value as distinct_value, 
    min(index) as first_index 
  from 
    unnest($1) with ordinality as input(value, index)
  group by
    value
) as unique_input;
$$
language 'sql' immutable strict;

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
  sub.company,
  sub.rank,
  sub.events
from (
  select d.f as date_from,
    d.t as date_to,
    d.rel as release,
    e.actor_id as actor,
    af.company_name as company,
    row_number() over actors_by_activity as rank,
    count(distinct e.id) as events
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
      'PushEvent', 'PullRequestEvent', 'IssuesEvent'
    )
  group by
    d.f,
    d.t,
    d.rel,
    e.actor_id,
    af.company_name
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
), top_committers as (
select sub.date_from,
  sub.date_to,
  sub.release,
  sub.actor,
  sub.company,
  sub.rank,
  sub.events
from (
  select d.f as date_from,
    d.t as date_to,
    d.rel as release,
    e.actor_id as actor,
    af.company_name as company,
    row_number() over actors_by_activity as rank,
    count(distinct e.id) as events
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
    and e.type = 'PushEvent'
  group by
    d.f,
    d.t,
    d.rel,
    e.actor_id,
    af.company_name
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
), top_issuers as (
select sub.date_from,
  sub.date_to,
  sub.release,
  sub.actor,
  sub.company,
  sub.rank,
  sub.events
from (
  select d.f as date_from,
    d.t as date_to,
    d.rel as release,
    e.actor_id as actor,
    af.company_name as company,
    row_number() over actors_by_activity as rank,
    count(distinct e.id) as events
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
    and e.type = 'IssuesEvent'
  group by
    d.f,
    d.t,
    d.rel,
    e.actor_id,
    af.company_name
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
), top_prs as (
select sub.date_from,
  sub.date_to,
  sub.release,
  sub.actor,
  sub.company,
  sub.rank,
  sub.events
from (
  select d.f as date_from,
    d.t as date_to,
    d.rel as release,
    e.actor_id as actor,
    af.company_name as company,
    row_number() over actors_by_activity as rank,
    count(distinct e.id) as events
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
    and e.type = 'PullRequestEvent'
  group by
    d.f,
    d.t,
    d.rel,
    e.actor_id,
    af.company_name
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
), top_reviewers as (
select sub.date_from,
  sub.date_to,
  sub.release,
  sub.actor,
  sub.company,
  sub.rank,
  sub.events
from (
  select d.f as date_from,
    d.t as date_to,
    d.rel as release,
    e.actor_id as actor,
    af.company_name as company,
    row_number() over actors_by_activity as rank,
    count(distinct e.id) as events
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
    and e.type = 'PullRequestReviewCommentEvent'
  group by
    d.f,
    d.t,
    d.rel,
    e.actor_id,
    af.company_name
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
), top_commenters as (
select sub.date_from,
  sub.date_to,
  sub.release,
  sub.actor,
  sub.company,
  sub.rank,
  sub.events
from (
  select d.f as date_from,
    d.t as date_to,
    d.rel as release,
    e.actor_id as actor,
    af.company_name as company,
    row_number() over actors_by_activity as rank,
    count(distinct e.id) as events
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
    and e.type in ('IssueCommentEvent', 'IssueCommentEvent')
  group by
    d.f,
    d.t,
    d.rel,
    e.actor_id,
    af.company_name
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
), contributors_summary as (
  select string_agg(a.login, ',' order by tc.rank) as top_actors,
    (select string_agg(c, ',') from unnest(pg_temp.array_uniq_stable(array_agg(tc.company order by tc.rank))) t(c)) as top_companies,
    (select count(*) filter (where c is not null) from unnest(pg_temp.array_uniq_stable(array_agg(tc.company order by tc.rank))) t(c)) as n_top_companies,
    sum(tc.events) as events,
    d.f as date_from
  from
    dates d,
    top_contributors tc,
    gha_actors a
  where
    d.f = tc.date_from
    and tc.actor = a.id
  group by
    d.f
), committers_summary as (
  select string_agg(a.login, ',' order by tc.rank) as top_actors,
    (select string_agg(c, ',') from unnest(pg_temp.array_uniq_stable(array_agg(tc.company order by tc.rank))) t(c)) as top_companies,
    (select count(*) filter (where c is not null) from unnest(pg_temp.array_uniq_stable(array_agg(tc.company order by tc.rank))) t(c)) as n_top_companies,
    sum(tc.events) as events,
    d.f as date_from
  from
    dates d,
    top_committers tc,
    gha_actors a
  where
    d.f = tc.date_from
    and tc.actor = a.id
  group by
    d.f
), issuers_summary as (
  select string_agg(a.login, ',' order by ti.rank) as top_actors,
    (select string_agg(c, ',') from unnest(pg_temp.array_uniq_stable(array_agg(ti.company order by ti.rank))) t(c)) as top_companies,
    (select count(*) filter (where c is not null) from unnest(pg_temp.array_uniq_stable(array_agg(ti.company order by ti.rank))) t(c)) as n_top_companies,
    sum(ti.events) as events,
    d.f as date_from
  from
    dates d,
    top_issuers ti,
    gha_actors a
  where
    d.f = ti.date_from
    and ti.actor = a.id
  group by
    d.f
), prs_summary as (
  select string_agg(a.login, ',' order by tpr.rank) as top_actors,
    (select string_agg(c, ',') from unnest(pg_temp.array_uniq_stable(array_agg(tpr.company order by tpr.rank))) t(c)) as top_companies,
    (select count(*) filter (where c is not null) from unnest(pg_temp.array_uniq_stable(array_agg(tpr.company order by tpr.rank))) t(c)) as n_top_companies,
    sum(tpr.events) as events,
    d.f as date_from
  from
    dates d,
    top_prs tpr,
    gha_actors a
  where
    d.f = tpr.date_from
    and tpr.actor = a.id
  group by
    d.f
), reviewers_summary as (
  select string_agg(a.login, ',' order by tr.rank) as top_actors,
    (select string_agg(c, ',') from unnest(pg_temp.array_uniq_stable(array_agg(tr.company order by tr.rank))) t(c)) as top_companies,
    (select count(*) filter (where c is not null) from unnest(pg_temp.array_uniq_stable(array_agg(tr.company order by tr.rank))) t(c)) as n_top_companies,
    sum(tr.events) as events,
    d.f as date_from
  from
    dates d,
    top_reviewers tr,
    gha_actors a
  where
    d.f = tr.date_from
    and tr.actor = a.id
  group by
    d.f
), commenters_summary as (
  select string_agg(a.login, ',' order by tc.rank) as top_actors,
    (select string_agg(c, ',') from unnest(pg_temp.array_uniq_stable(array_agg(tc.company order by tc.rank))) t(c)) as top_companies,
    (select count(*) filter (where c is not null) from unnest(pg_temp.array_uniq_stable(array_agg(tc.company order by tc.rank))) t(c)) as n_top_companies,
    sum(tc.events) as events,
    d.f as date_from
  from
    dates d,
    top_commenters tc,
    gha_actors a
  where
    d.f = tc.date_from
    and tc.actor = a.id
  group by
    d.f
)
select
  sub.*,
  sub.contributions / sub.days as contributions_per_day,
  sub.pushes / sub.days as pushes_per_day,
  sub.issue_evs / sub.days as issue_evs_per_day,
  sub.pr_evs / sub.days as pr_evs_per_day,
  sub.pr_reviews / sub.days as pr_reviews_per_day,
  sub.comment_evs / sub.days as comment_evs_per_day,
  (select top_actors from contributors_summary where date_from = sub.date_from) as top_contributors,
  (select top_companies from contributors_summary where date_from = sub.date_from) as top_contributors_coms,
  (select n_top_companies from contributors_summary where date_from = sub.date_from) as n_top_contributing_coms,
  (select events from contributors_summary where date_from = sub.date_from) as top_contributions,
  (select (100.0 * events) / sub.contributions from contributors_summary where date_from = sub.date_from) as top_contributions_perc,
  (select top_actors from committers_summary where date_from = sub.date_from) as top_committers,
  (select top_companies from committers_summary where date_from = sub.date_from) as top_committers_coms,
  (select n_top_companies from committers_summary where date_from = sub.date_from) as n_top_committing_coms,
  (select events from committers_summary where date_from = sub.date_from) as top_commits,
  (select (100.0 * events) / sub.pushes from committers_summary where date_from = sub.date_from) as top_commits_perc,
  (select top_actors from issuers_summary where date_from = sub.date_from) as top_issuers,
  (select top_companies from issuers_summary where date_from = sub.date_from) as top_issuers_coms,
  (select n_top_companies from issuers_summary where date_from = sub.date_from) as n_top_issuers_coms,
  (select events from issuers_summary where date_from = sub.date_from) as top_issues,
  (select (100.0 * events) / sub.issue_evs from issuers_summary where date_from = sub.date_from) as top_issues_perc,
  (select top_actors from prs_summary where date_from = sub.date_from) as top_pr_creators,
  (select top_companies from prs_summary where date_from = sub.date_from) as top_pr_creators_coms,
  (select n_top_companies from prs_summary where date_from = sub.date_from) as n_top_pr_creators_coms,
  (select events from prs_summary where date_from = sub.date_from) as top_prs,
  (select (100.0 * events) / sub.pr_evs from prs_summary where date_from = sub.date_from) as top_prs_perc,
  (select top_actors from reviewers_summary where date_from = sub.date_from) as top_reviewers,
  (select top_companies from reviewers_summary where date_from = sub.date_from) as top_reviewers_coms,
  (select n_top_companies from reviewers_summary where date_from = sub.date_from) as n_top_reviewers_coms,
  (select events from reviewers_summary where date_from = sub.date_from) as top_reviews,
  (select (100.0 * events) / sub.pr_reviews from reviewers_summary where date_from = sub.date_from) as top_reviews_perc,
  (select top_actors from commenters_summary where date_from = sub.date_from) as top_commenters,
  (select top_companies from commenters_summary where date_from = sub.date_from) as top_commenters_coms,
  (select n_top_companies from commenters_summary where date_from = sub.date_from) as n_top_commenters_coms,
  (select events from commenters_summary where date_from = sub.date_from) as top_comments,
  (select (100.0 * events) / sub.comment_evs from commenters_summary where date_from = sub.date_from) as top_comments_perc
from (
  select
    d.f as date_from,
    d.t as date_to,
    d.rel as release,
    DATE_PART('day', d.t - d.f) as days,
    count(e.id) filter (where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent')) as contributions,
    count(e.id) filter (where e.type = 'PushEvent') as pushes,
    count(e.id) filter (where e.type = 'IssuesEvent') as issue_evs,
    count(e.id) filter (where e.type = 'PullRequestEvent') as pr_evs,
    count(e.id) filter (where e.type = 'PullRequestReviewCommentEvent') as pr_reviews,
    count(e.id) filter (where e.type in ('IssueCommentEvent', 'IssueCommentEvent')) as comment_evs,
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
    count(distinct af.company_name) filter (where e.type in ('IssueCommentEvent', 'IssueCommentEvent') and af.company_name is not null) as commenting_coms
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
  ) sub
order by
  sub.date_from
;

drop function if exists pg_temp.array_uniq_stable(anyarray);
