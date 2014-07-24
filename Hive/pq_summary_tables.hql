use ayang;

drop table if exists publisher_quality_sum_temp;
create table publisher_quality_sum_temp as
select date(from_utc_timestamp(cast(time_local as bigint),'UTC')) event_date,
        a.y, a.m, a.d, 
	reflect('java.net.URLDecoder', 'decode', a.rg_publisher, 'utf-8') publisher,
	case when COALESCE(ci.note, c.note, i.note) is not NULL then 1 else 0 end is_bot,
	--skip records for cookie/ip comparison
	count(distinct case when a.cookie <> '' and a.cookie <> 'undefined' then a.ip else NULL end) ip_ct_neat, 
	count(distinct case when a.cookie <> '' and a.cookie <> 'undefined' then a.cookie else NULL end) cookie_ct_neat,
	sum(case when a.cookie <> '' and a.cookie <> 'undefined' and a.rg_event like '%playerMediaTime' then 1 else 0 end) stream_ct_neat,
	sum(case when a.cookie <> '' and a.cookie <> 'undefined' and a.rg_event = 'adPlaying' then 1 else 0 end) ad_ct_neat,
	count(distinct case when a.cookie <> '' and a.cookie <> 'undefined' and a.rg_event like '%playerReady' then a.player_instance else NULL end) player_ct_neat,
	--player stats
	count(distinct a.cookie) cookie_ct,
	count(distinct a.ip) ip_ct,
	count(distinct case when a.rg_event like '%playerReady' then a.player_instance else NULL end) player_ct,
	sum(case when a.rg_event like '%playerReady' then 1 else 0 end) impression,
	count(distinct case when a.rg_event like '%playerMediaTime' then a.player_instance else NULL end) clicked_player_ct,
	count(distinct case when a.rg_event like '%playerMediaVolume' then a.player_instance else NULL end) player_adjusted_volume_ct,
	count(distinct case when a.rg_event like '%playerMediaMute' and a.rg_action like 'Mute%true' then a.player_instance else NULL end) player_muted_ct,
	count(distinct case when a.rg_event = 'adNotEnabled' then a.player_instance else NULL end) player_adNotEnabled_ct,
	--work around an config issue with overlay ads
	count(distinct case when a.rg_event = 'adAbsent' and a.rg_action not like '%branding%' then a.player_instance else NULL end) player_adAbsent_ct,
	count(distinct case when a.rg_event like '%playerReady' and a.rg_iframe = 'true' then a.player_instance else NULL end) player_in_iframe_ct,
	count(distinct case when a.rg_event like '%playerReady' and a.rg_visible IN ('100%25', '%3E50%25') then a.player_instance else NULL end) player_visible_ct,
	--stream stats
	sum(case when a.rg_event like '%playerMediaTime' then 1 else 0 end) stream_ct,
	sum(case when a.rg_event like '%playerMediaTime' and a.rg_settings like '%Volume:\%200\%20%' then 1 else 0 end) stream_0_volume_ct,
	sum(case when a.rg_event like '%playerMediaTime' and a.rg_settings like '%Autostart:\%20true' then 1 else 0 end) stream_autostart_ct,
	--ads stats
	sum(case when a.rg_event = 'adPlaying' then 1 else 0 end) ad_ct,
	sum(case when a.rg_event = 'adClicked2Site' then 1 else 0 end) adClicked2Site,
	sum(case when a.rg_event = 'adSkipped' then 1 else 0 end) adSkipped,
	sum(case when a.rg_event = 'adsStopped' then 1 else 0 end) adsStopped,
	sum(case when a.rg_event = 'adError' then 1 else 0 end) adError
from ay_temp_pq a 
	left outer join (select cookie, ip, CONCAT('T1 - ', note) note from banned_cookie_ip) ci
	on (a.cookie = ci.cookie and a.ip = ci.ip)
	left outer join (select ip, y, m, d, CONCAT('T3 ip - ', note) note from banned_ip where note = '10 stddev') i
	on (a.ip = i.ip and a.y = i.y and a.m = i.m and a.d = i.d)
	left outer join (select cookie, CONCAT('T2 cookie - ', note) note from banned_cookie where note = '10 stddev') c
	on (a.cookie = c.cookie)
group by date(from_utc_timestamp(cast(time_local as bigint),'UTC')),
        a.y, a.m, a.d, reflect('java.net.URLDecoder', 'decode', a.rg_publisher, 'utf-8'), case when COALESCE(ci.note, c.note, i.note) is not NULL then 1 else 0 end
;

insert into table publisher_quality_sum
select event_date, a.y, a.m, a.d, 
	publisher,
	is_bot,
	--skip records for cookie/ip comparison
	ip_ct_neat, 
	cookie_ct_neat,
	stream_ct_neat,
	ad_ct_neat,
	player_ct_neat,
	--player stats
	cookie_ct,
	ip_ct,
	player_ct,
	impression,
	clicked_player_ct,
	player_adjusted_volume_ct,
	player_muted_ct,
	player_adNotEnabled_ct,
	--work around an config issue with overlay ads
	player_adAbsent_ct,
	player_in_iframe_ct,
	player_visible_ct,
	--stream stats
	stream_ct,
	stream_0_volume_ct,
	stream_autostart_ct,
	--ads stats
	ad_ct,
	adClicked2Site,
	adSkipped,
	adsStopped,
	adError
from publisher_quality_sum_temp a 
;

drop  table if exists publisher_quality_summary_temp;
create table publisher_quality_summary_temp
as
select a.publisher,
        event_date, a.y, a.m, a.d,
	is_bot,
	ip_ct_neat, 
	cookie_ct_neat,
	stream_ct_neat,
	ad_ct_neat,
	player_ct_neat,
	cookie_ct,
	ip_ct,
	player_ct,
	impression,
	clicked_player_ct,
	player_adjusted_volume_ct,
	player_muted_ct,
	player_adNotEnabled_ct,
	player_adAbsent_ct,
	player_in_iframe_ct,
	player_visible_ct,
	--stream stats
	stream_ct,
	stream_0_volume_ct,
	stream_autostart_ct,
	ad_ct,
	adClicked2Site,
	adSkipped,
	adsStopped,
	adError,
	b.company
from publisher_quality_sum_temp a left join company_site_map b
	on (a.publisher = b.rg_publisher);
	
insert into table publisher_quality_summary
select *
from publisher_quality_summary_temp
;