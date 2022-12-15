-- 2
CREATE INDEX idx_intersects_rast_gist ON uk_250k USING gist (ST_ConvexHull(rast));
SELECT AddRasterConstraints('public'::name,'uk_250k'::name,'rast'::name);

-- 3 
create table tmp(rid serial4, rast raster);
insert into tmp SELECT rid, rast FROM public.uk_250k limit 1000; -- na wszystkich danych operacja sie nie udala

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])) AS loid FROM public.tmp;
----------------------------------------------
SELECT lo_export(loid, 'E:\l7_raster.tiff')
FROM tmp_out;

SELECT lo_unlink(loid)
  FROM tmp_out;
  
 -- 6
SELECT UpdateGeometrySRID('national_parks1','geom',2180);
SELECT UpdateRasterSRID('uk_250k','rast',2180);

create table uk_lake_district as
select u.rid, st_clip(u.rast, n.geom,true) as rast
from uk_250k u, national_parks1 n where n.gid = 1 and st_intersects(u.rast, n.geom);

 -- 10
create or replace function public.ndvi(
value double precision [] [] [],
pos integer [][],
VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value
[1][1][1]);
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;


CREATE TABLE  public.ndvi_wyn AS
WITH r AS (
SELECT * FROM public.dane
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, ARRAY[1,4],
'ndvi(double precision[],
integer[],text[])'::regprocedure,
'32BF'::text
) AS rast
FROM r;

-- 11
CREATE TABLE tmp_out2 AS
SELECT lo_from_bytea(0,ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])) AS loid FROM public.ndvi_wyn;
----------------------------------------------
SELECT lo_export(loid, 'E:\l7_ndvi.tiff')
FROM tmp_out2;

SELECT lo_unlink(loid) FROM tmp_out2;