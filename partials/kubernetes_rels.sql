select 1001 as ord, (select timestamp from start_date) as f, '2015-07-11 04:02:31' as t, 'start - v1.0.0' as rel
union select 1002 as ord, '2015-07-11 04:02:31'::timestamp as f, '2015-09-25 23:41:40'::timestamp as t, 'v1.0.0 - v1.1.0' as rel
union select 1003 as ord, '2015-09-25 23:41:40'::timestamp as f, '2016-03-16 22:01:03'::timestamp as t, 'v1.1.0 - v1.2.0' as rel
union select 1004 as ord, '2016-03-16 22:01:03'::timestamp as f, '2016-07-01 19:19:06'::timestamp as t, 'v1.2.0 - v1.3.0' as rel
union select 1005 as ord, '2016-07-01 19:19:06'::timestamp as f, '2016-09-26 18:09:47'::timestamp as t, 'v1.3.0 - v1.4.0' as rel
union select 1006 as ord, '2016-09-26 18:09:47'::timestamp as f, '2016-12-12 23:29:43'::timestamp as t, 'v1.4.0 - v1.5.0' as rel
union select 1007 as ord, '2016-12-12 23:29:43'::timestamp as f, '2017-03-28 16:23:06'::timestamp as t, 'v1.5.0 - v1.6.0' as rel
union select 1008 as ord, '2017-03-28 16:23:06'::timestamp as f, '2017-06-29 22:53:16'::timestamp as t, 'v1.6.0 - v1.7.0' as rel
union select 1009 as ord, '2017-06-29 22:53:16'::timestamp as f, '2017-09-28 22:13:57'::timestamp as t, 'v1.7.0 - v1.8.0' as rel
union select 1010 as ord, '2017-09-28 22:13:57'::timestamp as f, '2017-12-15 20:53:13'::timestamp as t, 'v1.8.0 - v1.9.0' as rel
union select 1011 as ord, '2017-12-15 20:53:13'::timestamp as f, '2018-03-26 16:41:58'::timestamp as t, 'v1.9.0 - v1.10.0' as rel
union select 1012 as ord, '2018-03-26 16:41:58'::timestamp as f, '2018-06-27 20:06:28'::timestamp as t, 'v1.10.0 - v1.11.0' as rel
union select 1013 as ord, '2018-06-27 20:06:28'::timestamp as f, '2018-09-27 16:54:27'::timestamp as t, 'v1.11.0 - v1.12.0' as rel
union select 1014 as ord, '2018-09-27 16:54:27'::timestamp as f, '2018-12-03 20:54:59'::timestamp as t, 'v1.12.0 - v1.13.0' as rel
union select 1015 as ord, '2018-12-03 20:54:59'::timestamp as f, '2019-03-25 15:44:16'::timestamp as t, 'v1.13.0 - v1.14.0' as rel
union select 1016 as ord, '2019-03-25 15:44:16'::timestamp as f, now()::date as t, 'v1.14.0 - now' as rel
union select 1101 as ord, (select timestamp from start_date) as f, '2015-01-01 00:00:00' as t, '2014' as rel
union select 1103 as ord, '2015-01-01 00:00:00'::timestamp as f, '2016-01-01 00:00:00'::timestamp as t, '2015' as rel
union select 1103 as ord, '2016-01-01 00:00:00'::timestamp as f, '2017-01-01 00:00:00'::timestamp as t, '2016' as rel
union select 1104 as ord, '2017-01-01 00:00:00'::timestamp as f, '2018-01-01 00:00:00'::timestamp as t, '2017' as rel
union select 1105 as ord, '2018-01-01 00:00:00'::timestamp as f, '2019-01-01 00:00:00'::timestamp as t, '2018' as rel
union select 1106 as ord, '2019-01-01 00:00:00'::timestamp as f, now()::date as t, '2019' as rel
