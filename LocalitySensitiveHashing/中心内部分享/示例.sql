set hive.exec.parallel = true;
select 
	/*+mapjoin(my_id)*/
	vec.* 
from (
	select distinct hash_id 
	from (
		select dst hash_id  
		from bourne_smoba_hero_user_7_days_all_in_hash_3_month_result partition(p_20160801) a
		where src = -8791039284290038412
		union all 
		select distinct src hash_id  
		from bourne_smoba_hero_user_7_days_all_in_hash_3_month_result partition(p_20160801) a
		where src = -8791039284290038412
	)
) my_id join (
	select *
	from bourne_smoba_hero_user_7_days_all_in_hash_3_month partition(p_20160801) a
) vec
on my_id.hash_id = vec.hash_id