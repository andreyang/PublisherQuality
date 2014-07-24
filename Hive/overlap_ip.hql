use ayang;

drop table if exists ay_temp_site_ip;
create table ay_temp_site_ip as
select distinct concat(y, '-', 	m, '-', d) event_date, y, m, d, ip, reflect('java.net.URLDecoder', 'decode', rg_publisher, 'utf-8') rg_publisher
from ay_temp_pq
;

drop table if exists overlap_ip_sum_temp;
create table overlap_ip_sum_temp as
select a.event_date, a.y, a.m, a.d, a.rg_publisher, count(distinct a.ip) ip_ct, count(distinct case when a.rg_publisher = b.rg_publisher then NULL else b.ip end) overlap_ip_ct
from ay_temp_site_ip a left outer join ay_temp_site_ip b
on (a.event_date = b.event_date and a.ip = b.ip and a.y = b.y and a.m = b.m and a.d = b.d)
group by a.event_date, a.y, a.m, a.d, a.rg_publisher
;

insert into table overlap_ip_sum
select *
from overlap_ip_sum_temp
;