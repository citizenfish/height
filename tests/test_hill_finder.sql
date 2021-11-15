DO
$$
DECLARE

    ret_var JSON;
BEGIN

    DELETE FROM ng_research.hills;

    SELECT dem.hillfinder(wkb_geometry, ARRAY[ogc_fid], 0, startnode, endnode)
    INTO ret_var
    FROM ng_research.brixham_roads_with_z
    WHERE ogc_fid = 2641382;

    RAISE NOTICE 'RESULT %', ret_var;
END;
$$
LANGUAGE PLPGSQL;