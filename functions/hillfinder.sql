CREATE OR REPLACE FUNCTION dem.hillfinder(geometry_param GEOMETRY, ogc_fids INTEGER[], depth INTEGER DEFAULT 0, startnode_param TEXT DEFAULT NULL, endnode_param TEXT DEFAULT NULL) RETURNS JSON AS
$$
DECLARE
    r RECORD;
    hill_result JSON;
    depth_limit INTEGER DEFAULT 20;
BEGIN

    hill_result = dem.wholehill_finder(geometry_param);

    IF hill_result->>'wrote_hills' != 'true' THEN
        hill_result = dem.wholehill_finder(ST_REVERSE(geometry_param));
    END IF;

    CASE
        WHEN hill_result->>'wrote_hills' = 'true' AND  hill_result->>'final_state' IN ('RESTART', 'OUT_HILL') THEN
            RETURN hill_result;
        WHEN hill_result->>'wrote_hills' = 'false' AND (hill_result->>'total_gradient')::NUMERIC < 1 THEN
            RAISE NOTICE 'WORKING %', json_build_object('hill_segment', false, 'hill_finder', hill_result);
        ELSE
            RAISE NOTICE 'NOT SURE HOW WE GOT HERE %', hill_result;
    END CASE;


    IF depth > depth_limit  AND hill_result->>'final_state' != 'IN_HILL' THEN

        RETURN json_build_object('error', 'depth_exceeded');
    END IF;

    --Iterate down all connected line strings
    FOR r IN SELECT wkb_geometry, ogc_fid, startnode, endnode
             FROM ng_research.brixham_roads_with_z
             WHERE ((startnode = endnode_param   AND endnode   != startnode_param)
             OR    (endnode = startnode_param   AND startnode != endnode_param)
             OR    (startnode = startnode_param AND endnode   != endnode_param)
             OR    (endnode = endnode_param     AND startnode != startnode_param))
             AND  NOT ogc_fid = ANY(ogc_fids)
             AND class != 'Unknown'
             LOOP

        RAISE NOTICE 'AT DEPTH % fids % DEBUG FOUND fid %, start % end %, calling with start % and end % ',depth, ogc_fids, r.ogc_fid, r.startnode, r.endnode,CASE WHEN r.startnode NOT IN (startnode_param, endnode_param) THEN r.startnode ELSE '' END, CASE WHEN r.endnode NOT IN (startnode_param, endnode_param) THEN r.endnode ELSE '' END;
        RETURN dem.hillfinder(
                              --ST_LINEMERGE will deal with points order properly as it stitches in logical order
                              ST_LINEMERGE((SELECT ST_COLLECT(geom) FROM (SELECT geometry_param AS geom UNION SELECT r.wkb_geometry AS geom) FOO)),
                              array_append(ogc_fids, r.ogc_fid),
                              depth + 1,
                              --We only go in one direction otherwise could return to same place hence the NULLS
                              CASE WHEN r.startnode NOT IN (startnode_param, endnode_param) THEN r.startnode ELSE '' END,
                               CASE WHEN r.endnode NOT IN (startnode_param, endnode_param) THEN r.endnode ELSE '' END
                              );
    END LOOP;

    RETURN json_build_object('message', 'failed after loop');
END;
$$
LANGUAGE PLPGSQL;