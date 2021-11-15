SELECT (ST_PixelAsPolygons(rast)).* INTO dem.srtm_vector FROM dem.srtm_raster;
CREATE INDEX srtm_vector_geom_idx ON dem.srtm_vector  USING GIST(geom);

SELECT ST_TRANSFORM(geom, 4326) as geom,
	   val,
	   x,
	   y
INTO  dem.terrain_50_vector
FROM(SELECT (ST_PixelAsPolygons(rast)).* FROM dem.terrain_50_raster) FOO;

CREATE INDEX terrain_50_vector_geom_idx ON dem.terrain_50_vector  USING GIST(geom);

SELECT (ST_PixelAsPolygons(rast)).*  INTO  dem.alos_vector FROM dem.alos_raster;
CREATE INDEX alos_vector_geom_idx       ON dem.alos_vector  USING GIST(geom);

SELECT ST_TRANSFORM(geom, 4326) as geom,
	   val,
	   x,
	   y
INTO  dem.copernicus_vector
FROM(SELECT (ST_PixelAsPolygons(rast)).* FROM dem.copernicus_raster) FOO;

CREATE INDEX copernicus_vector_geom_idx ON dem.copernicus_vector  USING GIST(geom);