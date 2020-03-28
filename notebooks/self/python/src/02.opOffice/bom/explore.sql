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

select count(1) from dist_bom_part; 

CREATE TEMPORARY TABLE a ENGINE=MEMORY 
as (
	select part_num, count(1) as repeatedCnt
	 from dist_bom_part
	group by part_num
); 

select * from a; 

select count(1) from a; 

CREATE TEMPORARY TABLE b ENGINE=MEMORY 
as (
	select repeatedCnt,  count(1) as size
	 from a 
	group by repeatedCnt
); 

select * from b; 

select * from b 
order by repeated_cnt; 


# BOM 数量、料号数量
select count(distinct bom_id) bomCnt
	from bom_item; 
	
select count(distinct part_num) partCnt
	from bom_item;         
	
# 在两个 BOM 中出现的 料号数量
select count(1) as matCnt
from (select part_num, count(1) as repeatedCnt
      from (select part_num, bom_id
            from bom_item
            group by part_num, bom_id) dist_bom_part
      group by part_num) a
 where a.repeatedCnt > 1; 
 
 #  使用次数大于 1 次的物料，在 BOM 子件中的行数；
select count(1) as matCnt
from (select part_num, count(1) as repeatedCnt
      from (select part_num, bom_id
            from bom_item
            group by part_num, bom_id) dist_bom_part
      group by part_num
      ) a
inner join (select part_num, bom_id
            from bom_item
            group by part_num, bom_id) b 
on a.part_num = b.part_num
 and a.repeatedCnt > 1; 
                
                
 #  bom 的子件复用率
select b.bom_id, count(1) repeatCnt
 from (select part_num, count(1) as repeatedCnt
      from (select part_num, bom_id
            from bom_item
            group by part_num, bom_id) dist_bom_part
      group by part_num) a
 inner join (select part_num, bom_id
            from bom_item
            group by part_num, bom_id) b  
  on a.part_num = b.part_num
and a.repeatedCnt > 1
group by b.bom_id;   
                

select aa.bomID, aa.partCount, ifnull(bb.repeatCnt, 0) repeatCnt, aa.project, aa.client
   from bom_project_mapping aa
left join (
select b.bom_id, count(1) repeatCnt
 from (select part_num, count(1) as repeatCnt
      from (select part_num, bom_id
            from bom_item
            group by part_num, bom_id) dist_bom_part
      group by part_num) a
 inner join (select part_num, bom_id
            from bom_item
            group by part_num, bom_id) b  
  on a.part_num = b.part_num
and a.repeatCnt > 1
group by b.bom_id
) bb
on aa.bomID = bb.bom_id; 

##  重复使用次数对应的料号
select m.*
  from (
select  a.part_num
from (select part_num, count(1) as repeatedCnt
      from (select part_num, bom_id
            from bom_item
            group by part_num, bom_id) dist_bom_part
      group by part_num
      ) a
inner join (select part_num, bom_id
            from bom_item
            group by part_num, bom_id) b 
on a.part_num = b.part_num
 and a.repeatedCnt = 10
group by a.part_num) rep
inner join mat_info m on rep.part_num = m.part_num; 


###  物料基本信息
CREATE TABLE `mat_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `part_num` varchar(200) DEFAULT NULL,
  `part_version` varchar(45) DEFAULT NULL,
  `part_name` varchar(500) DEFAULT NULL,
  `part_family` varchar(45) DEFAULT NULL,
  `part_name_zh` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

insert into mat_info (part_num, part_version, part_name, part_family, part_name_zh)
	select part_num, max(part_version), max(part_name), max(part_family), max(part_name_zh)
      from bom_item
	group by part_num; 

select * from mat_info; 

#### 查看 客户-工厂-项目 对应关系
select  b.client, b.plant, count(distinct b.project) project_cnt, count(distinct b.bomID) bom_cnt
  from (
  select a.client, a.plant, a.project, a.bomID 
    from bom_project_mapping a
group by a.client, a.plant, a.project, a.bomID
  ) b
group by b.client, b.plant; 

#  按 bom 来看
select  b.client, b.plant, count(1) bom_cnt
  from (
  select a.client, a.plant, a.bomID 
    from bom_project_mapping a
group by a.client, a.plant, a.bomID
  ) b
group by b.client, b.plant; 


 select * from  bom_project_mapping a; 
 
 
#  入库单
SELECT * FROM po_item order by id desc ;

SELECT * FROM po_head order by id desc ;


select count(1) from po_item;

select * from po_head where batch = '1910-2' order by orderNum;

#  前后两种方法下，解析出来的单子不一样
 select a.orderNum
   from (select orderNum from po_head where batch = '1810-2' ) a 
left join (select orderNum from po_head where batch = '1810' ) b
on a.orderNum = b.orderNum 
where b.orderNum is null;  

#  删除表记录
delete from po_head where batch = '1812'; 
delete from po_item where batch = '1812'; 

truncate table po_head; 

truncate table po_item; 

###  
select * 
  from po_head
where batch = '1812'; 



select ibDate, count(1) from po_item group by ibDate order by ibDate; 

update po_head set batch = '1810'; 

update po_item set batch = '1810'; 



CREATE TEMPORARY TABLE t_po_mat ENGINE=MEMORY 
as (
select  i.material,  sum(receivedQuantity) as receivedQty
  from po_item i
group by i.material 
); 


CREATE TEMPORARY TABLE t_bom_mat ENGINE=MEMORY 
as (
select b.part_num,  count(1) as cnt
  from bom_item b
  group by b.part_num
); 


CREATE TEMPORARY TABLE t_cmb ENGINE=MEMORY 
as (
select p.material, p.receivedQty, b.cnt
  from t_po_mat p 
inner join t_bom_mat b on  p.material = b.part_num
) ; 

select count(1) from t_cmb; 

select count(1) from t_bom_mat; 

select count(1) from t_po_mat; 


######## 根据 料号，查找用到的 BOM
select m.bomID, m.partCount, project, client, plant, city, a.repeatCount
  from bom_project_mapping m 
inner join (
select bom_id, count(1) unitCount
  from bom_item a 
where a.part_num = 'N0152612'
group by bom_id
) a on a.bom_id = m.bomID; 

select * from mat_info where part_num = 'N0152612'; 

######## 以项目为颗粒度，查看共用性

select count(1)
  from (
select c.partNum, count(1) repeatCnt
  from (
select b.project, a.part_num partNum
  from bom_item a 
inner join bom_project_mapping b on a.bom_id = b.bomID
group by b.project, a.part_num 
) c 
group by c.partNum
) d 
where d.repeatCnt > 1; 

##  项目下 bom 数量
insert into project_info (project, client, bomCount) 
  select project, client, count(1)
from  bom_project_mapping m
group by project, client; 

## 项目下 零件数量 
update project_info bb
	inner join (
select c.project, count(1) partCount
  from (
select b.project, a.part_num partNum
  from bom_item a 
inner join bom_project_mapping b on a.bom_id = b.bomID
group by b.project, a.part_num 
) c
group by c.project) aa on aa.project = bb.project 
set bb.partCount = aa.partCount; 

## 项目下  复用的零件数量 

update project_info cc 
  inner join (
select bb.project, count(1) reuseCount
  from (select b.project, a.part_num partNum
  from bom_item a 
inner join bom_project_mapping b on a.bom_id = b.bomID
group by b.project, a.part_num ) bb 
inner join 
(
select  d.partNum
  from (
select c.partNum, count(1) repeatCnt
  from (
select b.project, a.part_num partNum
  from bom_item a 
inner join bom_project_mapping b on a.bom_id = b.bomID
group by b.project, a.part_num 
) c 
group by c.partNum
) d 
where d.repeatCnt > 1) aa on aa.partNum = bb.partNum
group by bb.project ) dd 
on dd.project = cc.project 
set cc.reusePartCount = dd.reuseCount; 

##  计算复用率
 update project_info 
 set reuseRate = reusePartCount * 100 / partCount
 where 1 = 1; 
 
  update project_info 
 set reuseRate = 0
 where reuseRate is null ; 


select * from project_info 

###  项目 和 物料的对应关系
 insert into project_mat (project, partNum)
 select b.project, a.part_num partNum
  from bom_item a 
inner join bom_project_mapping b on a.bom_id = b.bomID
group by b.project, a.part_num;  

### 更新零件使用的次数
update project_mat a 
inner join (
select partNum, count(1) cnt
  from project_mat
  group by partNum) b on a.partNum = b.partNum
set a.reused = b.cnt; 

 select * from project_mat; 
 
 ####### bom 和 mat 的对应关系
 ## 1. (bom, mat) 的对应关系
 insert into bom_mat (bomID, partNum)
 select a.bom_id, part_num
   from bom_item a 
group by a.bom_id, part_num; 



## 2. 以 mat 为基准，更新 reuse 数量（在不同 bom 下使用到的次数）
update bom_mat a 
  inner join (
  select partNum, count(1) reused
     from bom_mat group by partNum
  ) b 
on a.partNum = b.partNum
set a.reused = b.reused; 

## 3. bom  的基本信息
## bom 下所有 mat 的数量
insert into bom_info (bomID, partCount)
select a.bomID, count(1) partCount
  from bom_mat a
  group by a.bomID; 
  
# bom 下复用的 mat 数量  
update bom_info a 
  inner join (
  select a.bomID, count(1) partCount
  from bom_mat a
  where a.reused > 1
  group by a.bomID
  ) b on a.bomID = b.bomID
set a.reusePartCount = b.partCount; 

update bom_info a
  set a.reuseRate = 100 * ifnull(a.reusePartCount, 0) / a.partCount; 

select * from bom_info; 
  


##########  销售数据分析
select * from region_sales;
select * from region_sales_stats order by region, year; 

delete from region_sales; 
delete from region_sales_stats; 

select *
from region_sales_stats
where year = '2016'
order by quantity2 desc;


select *  
from region_sales
where year = '2016'
  and region = '江苏'
order by quantity desc;


select batch, count(1)
  from po_head 
group by batch;  



select batch, count(1)
  from po_item 
group by batch; 


									   
