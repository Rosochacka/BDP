CREATE EXTENSION postgis;

create database c2;

--4
create table buildings (
	id integer primary key, 
	geometry geometry, 
	name varchar
);

create table roads (
	id integer primary key, 
	geometry geometry, 
	name varchar
);

create table poi (
	id integer primary key, 
	geometry geometry, 
	name varchar
);

--5
insert into buildings values
	(1, 'POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', 'BuildingA'),
	(2, 'POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', 'BuildingB'),
	(3, 'POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 'BuildingC'),
	(4, 'POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 'BuildingD'),
	(5, 'POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', 'BuildingF');

insert into roads values
	(1, 'LINESTRING(0 4.5, 12 4.5)', 'RoadX'),
	(2, 'LINESTRING(7.5 10.5, 7.5 0)', 'RoadY');

insert into poi values
	(1, 'POINT(6 9.5)', 'K'),
	(2, 'POINT(9.5 6)', 'I'),
	(3, 'POINT(1 3.5)', 'G'),
	(4, 'POINT(6.5 6)', 'J'),
	(5, 'POINT(5.5 1.5)', 'H');

--a
select sum(st_length(r.geometry)) from roads r;

--b
select st_astext(b.geometry) as geometria, st_area(b.geometry) as pole, st_perimeter(b.geometry) as obwod from buildings b where b.name='BuildingA';

--c
select b.name, st_area(b.geometry) as pole from buildings b order by b.name;

--d
select b.name, st_perimeter(b.geometry) as obwod from buildings b order by st_area(b.geometry) desc limit 2;

--e
select st_distance(b.geometry, p.geometry) from buildings b, poi p where b.name = 'BuildingC' and p.name = 'K';

--f
select st_area(st_difference( 
	(select b.geometry from buildings b where b.name = 'BuildingC'), 
	st_buffer(
	(select b.geometry from buildings b where b.name = 'BuildingB'), .5)
));

--g
select b.name from roads r, buildings b where r.name='RoadX' and ST_Y(st_centroid(r.geometry)) < st_y(st_centroid(b.geometry));

--8
select st_area(st_symdifference( b.geometry, st_geomfromtext('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')))  from buildings b where b.name = 'BuildingC';