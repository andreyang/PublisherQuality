use warehouse_stg;
select 'Overall filter rate:' ayayayayay from publisher_quality_summary
limit 1
;

select min(date_range), round(sum(bot_ad_ct)/sum(ad_ct),2) ad_filter_rate,
        round(sum(bot_stream_ct)/sum(stream_ct),2) stream_filter_rate
from (
	select concat(min(event_date), ' - ', max(event_date)) date_range, 
	sum(is_bot*ad_ct) bot_ad_ct, sum(ad_ct) ad_ct,
        sum(is_bot*stream_ct) bot_stream_ct, sum(stream_ct) stream_ct
	from publisher_quality_summary_butterfly
	where event_date >= str_to_date(concat(year(subdate(curdate(), INTERVAL 1 day)), '-', month(subdate(curdate(), INTERVAL 1 day)), '-01'),'%Y-%m-%d')
	and event_date < curdate()
	union all
	select concat(min(event_date), ' - ', max(event_date)) date_range, 
	sum(is_bot*ad_ct) bot_ad_ct, sum(ad_ct) ad_ct,
	sum(is_bot*stream_ct) bot_stream_ct, sum(stream_ct) stream_ct
	from publisher_quality_summary
	where event_date >= str_to_date(concat(year(subdate(curdate(), INTERVAL 1 day)), '-', month(subdate(curdate(), INTERVAL 1 day)), '-01'),'%Y-%m-%d')
	and event_date < curdate()
	and publisher <> 'food daddy'
) tt
;

select '------------' ayayayayay
from publisher_quality_summary
limit 1
;

select 'Publisher level filter rate:' ayayayayay 
from publisher_quality_summary
limit 1
;

select  max(a.company) company,
        a.publisher,
        case when sum(a.ad_ct) >= 1000 then round(sum(a.ad_ct_bot)/sum(a.ad_ct),4) when sum(a.stream_ct) >= 1000 then round(sum(a.stream_ct_bot)/sum(a.stream_ct),4) end bot_filter,
	round(sum(a.stream_ct_bot)/sum(a.stream_ct),4) stream_filter_rate,
        round(sum(a.cookie_ct_neat)/sum(a.ip_ct_neat),2) cookie_per_ip,
        round(sum(b.overlap_ip_ct)/sum(b.ip_ct),4) cross_visit,
        round(sum(a.ad_ct_neat)/sum(a.ip_ct_neat),2) ads_per_ip,
        round(sum(a.stream_ct_neat)/sum(a.ip_ct_neat),2) stream_per_ip,
        #sum(a.ip_ct_neat) ip_ct_neat,
        #sum(a.cookie_ct_neat) cookie_ct_neat,
        #sum(a.stream_ct_neat) stream_ct_neat,
        #sum(a.ad_ct_neat) ad_ct_neat,
        #sum(a.player_ct_neat) player_ct_neat,
        #player stats
        #sum(cookie_ct) cookie_ct,
        #sum(a.ip_ct) ip_ct,
        sum(a.player_ct) player_ct,
        #sum(a.impression) impression,
        round(sum(a.clicked_player_ct)/sum(a.player_ct),4) player_clicked,
        round(sum(a.player_adjusted_volume_ct)/sum(a.player_ct),4) player_adjusted_volume,
        round(sum(a.player_muted_ct)/sum(a.player_ct),4) player_muted,
        round(sum(a.player_adNotEnabled_ct)/sum(a.player_ct),4) player_adNotEnabled,
        round(sum(a.player_adAbsent_ct)/sum(a.player_ct),4) player_adAbsent,
        round(sum(a.player_in_iframe_ct)/sum(a.player_ct),4) player_in_iframe,
        round(sum(a.player_visible_ct)/sum(a.player_ct),4) player_visible,
        #stream stats
        sum(a.stream_ct) stream_ct,
        round(sum(a.stream_0_volume_ct)/sum(a.stream_ct),4) stream_0_volume,
        round(sum(a.stream_autostart_ct)/sum(a.stream_ct),4) stream_autostart,
        #ads stats
        sum(a.ad_ct) ad_ct,
        round(sum(a.adClicked2Site)/sum(a.ad_ct),4) adClicked2Site,
        sum(a.adSkipped) adSkipped,
        sum(a.adsStopped) adsStopped,
        sum(a.adError) adError
from (
select max(company) company,
        publisher,
        sum(ip_ct_neat) ip_ct_neat,
        sum(cookie_ct_neat) cookie_ct_neat,
        sum(stream_ct_neat) stream_ct_neat,
        sum(ad_ct_neat) ad_ct_neat,
        sum(player_ct_neat) player_ct_neat,
        #player stats
        sum(cookie_ct) cookie_ct,
        sum(ip_ct) ip_ct,
        sum(player_ct) player_ct,
        sum(impression) impression,
        sum(clicked_player_ct) clicked_player_ct,
        sum(player_adjusted_volume_ct) player_adjusted_volume_ct,
        sum(player_muted_ct) player_muted_ct,
        sum(player_adNotEnabled_ct) player_adNotEnabled_ct,
        sum(case when player_adAbsent_ct > player_ct then player_ct else player_adAbsent_ct end) player_adAbsent_ct,
        sum(player_in_iframe_ct) player_in_iframe_ct,
        sum(player_visible_ct) player_visible_ct,
        #stream stats
        sum(stream_ct) stream_ct,
        sum(IF(is_bot = 1,stream_ct,0)) stream_ct_bot,
        sum(stream_0_volume_ct) stream_0_volume_ct,
        sum(stream_autostart_ct) stream_autostart_ct,
        #ads stats
        sum(ad_ct) ad_ct,
        sum(IF(is_bot = 1, ad_ct, 0)) ad_ct_bot,
        sum(adClicked2Site) adClicked2Site,
        sum(adSkipped) adSkipped,
        sum(adsStopped) adsStopped,
        sum(adError) adError
        from publisher_quality_summary
        where event_date >= str_to_date(concat(year(subdate(curdate(), INTERVAL 1 day)), '-', month(subdate(curdate(), INTERVAL 1 day)), '-01'),'%Y-%m-%d')
        and event_date < curdate()
	group by publisher
	union all
select 	NULL company,
	lower(p.name) publisher,
        sum(ip_ct_neat) ip_ct_neat,
        sum(cookie_ct_neat) cookie_ct_neat,
        sum(stream_ct_neat) stream_ct_neat,
        sum(ad_ct_neat) ad_ct_neat,
        sum(player_ct_neat) player_ct_neat,
        #player stats
        sum(cookie_ct) cookie_ct,
        sum(ip_ct) ip_ct,
        sum(player_ct) player_ct,
        sum(impression) impression,
        sum(clicked_player_ct) clicked_player_ct,
        sum(player_adjusted_volume_ct) player_adjusted_volume_ct,
        sum(player_muted_ct) player_muted_ct,
        sum(player_adNotEnabled_ct) player_adNotEnabled_ct,
        sum(case when player_adAbsent_ct > player_ct then player_ct else player_adAbsent_ct end) player_adAbsent_ct,
        sum(player_in_iframe_ct) player_in_iframe_ct,
        sum(player_visible_ct) player_visible_ct,
        #stream stats
        sum(stream_ct) stream_ct,
        sum(IF(is_bot = 1,stream_ct,0)) stream_ct_bot,
        sum(stream_0_volume_ct) stream_0_volume_ct,
        sum(stream_autostart_ct) stream_autostart_ct,
        #ads stats
        sum(ad_ct) ad_ct,
        sum(IF(is_bot = 1, ad_ct, 0)) ad_ct_bot,
        sum(adClicked2Site) adClicked2Site,
        sum(adSkipped) adSkipped,
        sum(adsStopped) adsStopped,
        sum(adError) adError
        from publisher_quality_summary_butterfly a join client_portal.domains d on (a.domain_id = id)
        join client_portal.publishers p on (d.publisher_id = p.id)
        where event_date >= str_to_date(concat(year(subdate(curdate(), INTERVAL 1 day)), '-', month(subdate(curdate(), INTERVAL 1 day)), '-01'),'%Y-%m-%d')
        and event_date < curdate()
	group by lower(p.name)
        ) a
        left outer join
        (select publisher,
        sum(ip_ct) ip_ct,
        sum(overlap_ip_ct) overlap_ip_ct
        from overlap_ip_summary
        where event_date >= str_to_date(concat(year(subdate(curdate(), INTERVAL 1 day)), '-', month(subdate(curdate(), INTERVAL 1 day)), '-01'),'%Y-%m-%d')
        and event_date < curdate()
	group by publisher
        ) b
        on (a.publisher = b.publisher)
where a.publisher <> 'undefined' and a.publisher <> 'test' and a.publisher <> 'food daddy'
#and a.stream_ct >= 1000
group by a.publisher
;
