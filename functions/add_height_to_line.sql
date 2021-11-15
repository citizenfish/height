CREATE OR REPLACE FUNCTION dem.add_height_to_line(geometry_param GEOMETRY) RETURNS GEOMETRY AS
$$
DECLARE
    ret_geometry GEOMETRY;
BEGIN

    WITH ROAD_POINTS AS (
        SELECT (ST_DUMPPOINTS(ST_LINEMERGE(ST_SEGMENTIZE(ST_TRANSFORM(geometry_param,4326)::GEOGRAPHY,10)::GEOMETRY))).*

    )
    SELECT 	 ST_MAKELINE(ST_MAKEPOINT(ST_X(geom),ST_Y(geom),dem.get_height_for_point_geometry(geom)) ORDER BY PATH) as wkb_geometry
            INTO ret_geometry
    FROM ROAD_POINTS;


    RETURN ST_SETSRID(ST_FORCE3D(ret_geometry),4326);

END;
$$
LANGUAGE PLPGSQL;