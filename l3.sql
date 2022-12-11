-- 1
with res_build as(
	select tkb2.polygon_id, tkb2.geom from t2019_kar_buildings tkb2  
	left join t2018_kar_buildings tkb on tkb2.geom=tkb.geom 
	where tkb.polygon_id IS NULL
),

-- 2
res_points as(
	select tkpt2.poi_id, tkpt2.geom, tkpt2.type  from t2019_kar_poi_table tkpt2
	left join t2018_kar_poi_table tkpt on tkpt2.geom=tkpt.geom 
	where tkpt.poi_id IS NULL
)
select count(*), p.type from res_build b 
join res_points p
on st_distance(b.geom, p.geom) <=500
group by p.type;

-- 3
create table streets_reprojected(
	gid serial4, 
	link_id float8, 
	st_name varchar(254), 
	ref_in_id float8, 
	nref_in_id float8, 
	func_class varchar(1), 
	speed_cat varchar(1), 
	fr_speed_l float8, 
	to_speed_l float8, 
	dir_travel varchar(1), 
	geom geometry
);

insert into streets_reprojected 
SELECT gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, to_speed_l, dir_travel, 
st_transform(st_setsrid(geom,4326), 3068) FROM public.t2019_kar_streets;

-- 4
create table input_points(id SERIAL primary KEY,
	nazwa varchar(20),
	geom geometry
);

insert into input_points(nazwa, geom) values('p1', 'POINT(8.36093 49.03174)');
insert into input_points(nazwa, geom) values('p2', 'POINT(8.39876 49.00644)');

-- 5
update input_points 
set geom = st_transform(st_setsrid(geom,4326), 3068);

-- 6
update t2019_kar_street_node 
set geom = st_transform(st_setsrid(geom,4326), 3068);

with res_lines as(
	select st_makeline(geom) as geom from input_points 
) 
SELECT * FROM t2019_kar_street_node sn 
cross join res_lines rl 
where st_distance(sn.geom, rl.geom) <= 200;

-- 7
select count(distinct p.poi_id) from t2019_kar_poi_table p 
	join t2019_kar_land_use_a l 
	on st_distance(p.geom, l.geom) <= 300	
	where p.type='Sporting Goods Store';
	
-- 8
CREATE SEQUENCE seq start 1; 

create table T2019_KAR_BRIDGES as
select nextval('seq'), st_intersection(r.geom, w.geom) from t2019_kar_railways r 
	join t2019_kar_water_lines w
	on st_intersects(r.geom, w.geom);


