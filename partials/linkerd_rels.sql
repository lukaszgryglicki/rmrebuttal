select 1001 as ord, (select timestamp from start_date) as f, '2017-01-01 00:00:00' as t, '2016' as rel
union select 1004 as ord, '2017-01-01 00:00:00'::timestamp as f, '2018-01-01 00:00:00'::timestamp as t, '2017' as rel
union select 1005 as ord, '2018-01-01 00:00:00'::timestamp as f, now()::date as t, '2018' as rel
