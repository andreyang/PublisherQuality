use ayang;

drop table if exists ay_temp_ip;
create table ay_temp_ip as
select y, m, d, case when rg_event like '%playerReady' then 'impression' 
			when  rg_event = 'adPlaying' then 'ad' 
			when rg_event like '%playerMediaTime' then 'stream' 
			else NULL end rg_event, ip, count(*) ct
from ay_temp_pq
where rg_event IN ('adPlaying', 'playerReady', 'jwplayerReady', 'playerMediaTime', 'jwplayerMediaTime')
group by y, m, d, case when rg_event like '%playerReady' then 'impression' 
			when  rg_event = 'adPlaying' then 'ad' 
			when rg_event like '%playerMediaTime' then 'stream' 
			else NULL end, ip
;

drop table if exists ay_temp_ip_sum;
create table ay_temp_ip_sum as
select y, m, d, rg_event, avg(ct) avg_ct, stddev(ct) stddev_ct
from ay_temp_ip
group by y, m, d, rg_event
;

drop table if exists ay_temp_banned_ip;
create table ay_temp_banned_ip as
select a.ip, '10 stddev' note, a.y, a.m, a.d
from 
	ay_temp_ip a
	join
	ay_temp_ip_sum b
on (a.rg_event = b.rg_event and a.y = b.y and a.m = b.m and a.d = b.d)
	left outer join (select ip, y, m, d, note from banned_ip where note = '10 stddev') c
	on (a.ip = c.ip and a.y = c.y and a.m = c.m and a.d = c.d)
where a.ct > b.avg_ct + 10*b.stddev_ct
--safety
and a.ct > 100
and c.note is NULL
;

insert into table banned_ip
select distinct ip, note, y, m, d
from ay_temp_banned_ip
;