--1
create table obiekty(
	id SERIAL primary KEY,
	nazwa varchar(20),
	geom geometry
);

--a
insert into obiekty (nazwa, geom) values('obiekt1', ST_Collect(
	array[
		'LINESTRING(0 1, 1 1)',
		'CIRCULARSTRING(1 1, 2 2, 3 1)',
		'CIRCULARSTRING(3 1, 4 2, 5 1)',
		'LINESTRING(5 1, 6 1)'	
	]
));

--b
insert into obiekty (nazwa, geom) values('obiekt2', ST_Collect(
	array[
		'LINESTRING(10 6, 14 6)',
		'CIRCULARSTRING(14 6, 16 4, 14 2)',
		'CIRCULARSTRING(14 2, 12 0, 10 2)',
		'LINESTRING(10 2, 10 6)',
		'CIRCULARSTRING(11 2, 12 3, 13 2, 12 1, 11 2)'		
	]
));
--c
insert into obiekty (nazwa, geom) values('obiekt3', ST_Collect(
	array[
		'LINESTRING(10 17, 12 13)',
		'LINESTRING(12 13, 7 15)',
		'LINESTRING(7 15, 10 17)'
	]
));

--d
insert into obiekty (nazwa, geom) values('obiekt4', ST_Collect(
	array[
		'LINESTRING(20 20, 25 25)',
		'LINESTRING(25 25, 27 24)',
		'LINESTRING(27 24, 25 22)',
		'LINESTRING(25 22, 26 21)',
		'LINESTRING(26 21, 22 19)',
		'LINESTRING(22 19, 20.5 19.5)'
	]
));
--e
insert into obiekty (nazwa, geom) values('obiekt5', ST_Collect(
	array[
	'POINT(38 32 234)',
	'POINT(30 30 59)'
	]
));
--f
insert into obiekty (nazwa, geom) values('obiekt6', ST_Collect(
	array[
	'LINESTRING(1 1, 3 2)',
	'POINT(4 2)'
	]
));
select * from obiekty;

--2
select st_area(st_buffer(st_shortestline(
	(select geom from obiekty where nazwa = 'obiekt3'), 
	(select geom from obiekty where nazwa = 'obiekt4')),5));
--3
update obiekty set geom =  st_geomfromtext('POLYGON((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20))')
where nazwa = 'obiekt4';

--4
insert into obiekty(nazwa, geom) values( 'obiekt7', ST_Collect( (select geom from obiekty where nazwa = 'obiekt3'),(select geom from obiekty where nazwa = 'obiekt4')));

--5
select sum(st_area(st_buffer(geom, 5))) from obiekty where st_hasArc(geom) = false;