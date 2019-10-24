select * from bom_item; 

select bom_id, count(1) from bom_item group by bom_id; 

select count(1) from bom_item; 

delete from bom_item; 


CREATE TEMPORARY TABLE dist_bom_part ENGINE=MEMORY 
as (
	select part_num, bom_id
        from bom_item
        group by part_num, bom_id
); 

CREATE TEMPORARY TABLE a ENGINE=MEMORY 
as (
	select part_num, count(1) as repeated_cnt
	 from dist_bom_part
	group by part_num
); 

select * from a; 

select count(1) from a; 

CREATE TEMPORARY TABLE b ENGINE=MEMORY 
as (
	select repeated_cnt,  count(1) as size
	 from a 
	group by repeated_cnt
); 

select * from b; 

select * from b 
order by repeated_cnt 