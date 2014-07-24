use ayang;

drop table if exists ay_temp_cookie;
create table ay_temp_cookie as
select y, m, d, case when rg_event like '%playerReady' then 'impression' 
			when  rg_event = 'adPlaying' then 'ad' 
			when rg_event like '%playerMediaTime' then 'stream' 
			else NULL end rg_event, cookie, count(*) ct
from ay_temp_pq
where rg_event IN ('adPlaying', 'playerReady', 'jwplayerReady', 'playerMediaTime', 'jwplayerMediaTime')
and cookie <> 'undefined' and cookie <> '' and cookie is not NULL
group by y, m, d, case when rg_event like '%playerReady' then 'impression' 
			when  rg_event = 'adPlaying' then 'ad' 
			when rg_event like '%playerMediaTime' then 'stream' 
			else NULL end, cookie
;

drop table if exists ay_temp_cookie_sum;
create table ay_temp_cookie_sum as
select y, m, d, rg_event, avg(ct) avg_ct, stddev(ct) stddev_ct
from ay_temp_cookie
group by y, m, d, rg_event
;

drop table if exists ay_temp_banned_cookie;
create table ay_temp_banned_cookie as
select a.cookie, '10 stddev' note, a.y, a.m, a.d
from 
	ay_temp_cookie a
	join
	ay_temp_cookie_sum b
on (a.rg_event = b.rg_event and a.y = b.y and a.m = b.m and a.d = b.d)
	left outer join (select cookie from banned_cookie where note = '10 stddev') c
	on (a.cookie = c.cookie)
where a.ct > b.avg_ct + 10*b.stddev_ct
--safety
and a.ct > 30
and c.cookie is NULL
;

insert into table banned_cookie
select cookie, note,
	regexp_extract(min(concat(y, '-', m, '-', d)), '([0-9]{4})-([0-9]{2})-([0-9]{2})',1) y, 
	regexp_extract(min(concat(y, '-', m, '-', d)), '([0-9]{4})-([0-9]{2})-([0-9]{2})',2) m,
	regexp_extract(min(concat(y, '-', m, '-', d)), '([0-9]{4})-([0-9]{2})-([0-9]{2})',3) d
from ay_temp_banned_cookie
group by cookie, note
;
