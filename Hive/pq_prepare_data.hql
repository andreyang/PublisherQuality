use ayang;

drop table if exists ay_temp_pq;
create table ay_temp_pq as
select 	params['rg_event'] rg_event,
		params['rg_action'] rg_action,
		params['rg_settings'] rg_settings,
		params['rg_session'] cookie,
		params['rg_visible'] rg_visible,
		params['rg_iframe'] rg_iframe,
		params['rg_guid'] rg_guid,
		ip,
		time_local,
		CONCAT(COALESCE(params['rg_session'], 'na'), COALESCE(params['rg_player_uuid'], 'na'), COALESCE(params['rg_instance'], 'na'), COALESCE(params['rg_page_host_url'], 'na')) player_instance,
		lower(params['rg_publisher']) rg_publisher,
		y,
		m,
		d
from cocoon.data_primitives
where y = '${year}'
and m = '${month}'
and d between '${begindate}' and '${enddate}'
and (params['rg_event'] IN ('adPlaying', 'playerReady', 'jwplayerReady', 'adNotEnabled', 'adError', 'adsStopped', 'rgError', 'adAbsent', 'adClicked2Site', 'adSkipped') 
     or (params['rg_event'] IN ('playerMediaTime', 'jwplayerMediaTime') and params['rg_category'] like 'Stream%Progress' and (params['rg_counter'] like '%+0' or params['rg_counter'] like '%\%200'))
     or params['rg_event'] like '%playerMediaMute'
     or params['rg_event'] like '%playerMediaVolume'
    )
and params['rg_publisher'] not IN ('localhost', '127.0.0.1')
and params['rg_guid'] not in ('889e6b80-0621-012e-2ba9-12313b079c51','68664b27-3510-48f4-a1be-d0d0b64d3115')
;