CREATE OR REPLACE FUNCTION dem.get_height_for_point_geometry(geometry_param GEOMETRY) RETURNS NUMERIC AS
$$
DECLARE
	idw_height_var NUMERIC;
	values_var NUMERIC[];
BEGIN

SELECT idw_height,
	   array_agg(val) OVER () as values
	   INTO idw_height_var,values_var
FROM (
SELECT
	   round(val::NUMERIC,2) as val,
	   container_geometry,
	   ROUND(
		   (SUM (val/ST_DISTANCE(wkb_geometry::GEOGRAPHY, centroid::GEOGRAPHY))   OVER ()
		 /  SUM (1/ST_DISTANCE(wkb_geometry::GEOGRAPHY, centroid::GEOGRAPHY))     OVER ()
			 )::NUMERIC
		   ,2
	   ) AS idw_height

FROM
(
	SELECT
	   ST_TRANSFORM(geometry_param, 4326) AS wkb_geometry,
	   ST_BUFFER(ST_TRANSFORM(geometry_param, 4326)::GEOGRAPHY,12)::GEOMETRY AS point_buffer
) PQ
LEFT JOIN LATERAL
(
	SELECT
	val,
	ST_Contains(geom, wkb_geometry) as container_geometry,
		 	geom,
			ST_CEntroid(geom) as centroid
	FROM dem.srtm_vector
	WHERE ST_INTERSECTS(geom, point_buffer)
	UNION
	SELECT
	val,
	ST_Contains(geom, wkb_geometry) as container_geometry,
		 	geom,
			ST_CEntroid(geom) as centroid
	FROM dem.alos_vector
	WHERE ST_INTERSECTS(geom, point_buffer)
	UNION
	SELECT
	val,
	ST_Contains(geom, wkb_geometry) as container_geometry,
		 	geom,
			ST_CEntroid(geom) as centroid
	FROM dem.copernicus_vector
	WHERE ST_INTERSECTS(geom, point_buffer)
		UNION
	SELECT
	val,
	ST_Contains(geom, wkb_geometry) as container_geometry,
		 	geom,
			ST_CEntroid(geom) as centroid
	FROM dem.terrain_50_vector
	WHERE ST_INTERSECTS(geom, point_buffer)
) SUB_QUERY
ON true
) SUB
WHERE container_geometry IS true
LIMIT 1;

RETURN idw_height_var;
END;
$$LANGUAGE PLPGSQL;