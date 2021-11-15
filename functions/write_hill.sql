CREATE OR REPLACE FUNCTION dem.write_hill(linestring GEOMETRY, start_hill_marker INTEGER, end_hill_marker INTEGER, hill_height NUMERIC, hill_length NUMERIC) RETURNS JSON AS
$$
DECLARE

    hill_geometry GEOMETRY;
    r RECORD;
    id_var BIGINT;
BEGIN


    CREATE TABLE IF NOT EXISTS ng_research.hills(
        id BIGSERIAL,
        wkb_geometry geometry(LineStringZ,4326),
        hill_height NUMERIC,
        hill_length NUMERIC,
        attributes JSONB
    );


    INSERT INTO ng_research.hills(wkb_geometry,hill_height, hill_length, attributes)
    SELECT
           hill_geometry,
           hill_height,
           hill_length,
           json_build_object()
    RETURNING id
    INTO id_var;

    RETURN json_build_object('hill_id', id_var);

END;
$$ LANGUAGE PLPGSQL;
--DB