use ayang;

drop table if exists ay_temp_cookie_ip;
create table ay_temp_cookie_ip as
select cookie, ip, y, m, d from 
(
select y, m, d, time_local, case when rg_event like '%playerReady' then 'impression' 
			when  rg_event = 'adPlaying' then 'ad' 
			when rg_event like '%playerMediaTime' then 'stream' 
			else NULL end rg_event, cookie, ip, count(*) ct
from ay_temp_pq
where rg_event IN ('adPlaying', 'playerReady', 'jwplayerReady', 'playerMediaTime', 'jwplayerMediaTime') and cookie <> 'undefined' and cookie <> '' and cookie is not NULL
group by y, m, d, time_local, case when rg_event like '%playerReady' then 'impression' 
			when  rg_event = 'adPlaying' then 'ad' 
			when rg_event like '%playerMediaTime' then 'stream' 
			else NULL end, cookie, ip
having count(*) >= 5
) t
;

drop table if exists ay_temp_banned_cookie_ip;
create table ay_temp_banned_cookie_ip as
select a.cookie, a.ip, '5 views per second' note, a.y, a.m, a.d
from 
	ay_temp_cookie_ip a
	left outer join (select cookie, ip, note from banned_cookie_ip where note = '5 views per second') b
	on (a.cookie = b.cookie and a.ip = b.ip)
where b.note is NULL
;

insert into table banned_cookie_ip
select cookie, ip, note, 
	regexp_extract(min(concat(y, '-', m, '-', d)), '([0-9]{4})-([0-9]{2})-([0-9]{2})',1) y, 
	regexp_extract(min(concat(y, '-', m, '-', d)), '([0-9]{4})-([0-9]{2})-([0-9]{2})',2) m,
	regexp_extract(min(concat(y, '-', m, '-', d)), '([0-9]{4})-([0-9]{2})-([0-9]{2})',3) d
from ay_temp_banned_cookie_ip
group by cookie, ip, note
;