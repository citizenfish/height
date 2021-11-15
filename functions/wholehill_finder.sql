CREATE OR REPLACE FUNCTION dem.wholehill_finder(linestring_param GEOMETRY) RETURNS JSON AS
$$
DECLARE

    dHeight NUMERIC DEFAULT 0;
    hill_height NUMERIC DEFAULT 0;
    hill_length NUMERIC DEFAULT 0;
    total_hill_height NUMERIC DEFAULT 0;
    total_hill_length NUMERIC DEFAULT 0;
    hill_state TEXT DEFAULT 'NOT_IN_HILL';
    notInHillDistance NUMERIC DEFAULT 0;
    previous_height NUMERIC DEFAULT 0;
    pr RECORD;
	start_hill_marker INTEGER DEFAULT 0;
    hills_written INTEGER DEFAULT 0;
    NOT_IN_HILL_DISTANCE NUMERIC DEFAULT 50;
    MIN_HILL_HEIGHT NUMERIC DEFAULT 30;
    MIN_HILL_DISTANCE NUMERIC DEFAULT 150;
    POINT_SPREAD NUMERIC DEFAULT 10;
	write_hill_var JSON;

	hill_geometry GEOMETRY;
	last_point GEOMETRY;
BEGIN

    FOR pr IN SELECT ST_Z(geom) as height, path[1] as p_order, geom FROM ( SELECT (ST_DUMPPOINTS(linestring_param)).*) FOO ORDER BY 2 ASC LOOP

        IF pr.p_order = 1 THEN
            previous_height = pr.height;
            CONTINUE;

        END IF;

        dHeight = pr.height - previous_height;

        IF hill_geometry IS NULL AND last_point IS NULL THEN
            last_point = pr.geom;
        ELSE
            IF hill_geometry IS NULL AND last_point IS NOT NULL THEN
                hill_geometry = ST_MAKELINE(last_point, pr.geom);
            ELSE
                hill_geometry = ST_ADDPOINT(hill_geometry, pr.geom);
            END IF;
        END IF;

        --We are entering a hill
        IF  dHeight > 0 AND hill_state NOT IN  ('IN_HILL', 'OUT_HILL') THEN

            start_hill_marker = pr.p_order;
            hill_state = 'IN_HILL';
            notInHillDistance = 0;
            hill_height = dHeight;
            hill_length = POINT_SPREAD;
        END IF;

        --We are still in a hill
        IF hill_state = 'IN_HILL' THEN
            hill_height = hill_height + dHeight;
            hill_length = hill_length + POINT_SPREAD;
            total_hill_height = hill_height;
            total_hill_length = hill_length;
        END IF;

        --We have popped out of a hill, maybe only temporarily
        IF (dHeight <= 0 AND hill_state = 'IN_HILL') OR hill_state = 'OUT_HILL' THEN

               --We have popped back into hill
               IF dHeight > 0 THEN
                    hill_height = hill_height + dHeight;
                    hill_length  = hill_length + notInHillDistance + 10;
                    total_hill_height = hill_height;
                    total_hill_length = hill_length;
                    hill_state = 'IN_HILL';
                    notInHillDistance = 0;
               ELSE
                    hill_state = 'OUT_HILL';
                    notInHillDistance = notInHillDistance + 10;
               END IF;


            --been in this state for too long so hill has ended
            IF notInHillDistance >= NOT_IN_HILL_DISTANCE THEN
                IF hill_height >= MIN_HILL_HEIGHT AND hill_length >= MIN_HILL_DISTANCE THEN
                    RAISE NOTICE 'WRITING_HILL AT POINT % HEIGHT %, LENGTH %', pr.p_order, hill_height, hill_length;
                    --write_hill_var = dem.write_hill(linestring_param, start_hill_marker, pr.p_order - 1, hill_height, hill_length);
                    INSERT INTO ng_research.hills(wkb_geometry,hill_height, hill_length, attributes)
                    SELECT
                           hill_geometry,
                           hill_height,
                           hill_length,
                           json_build_object();
                    hills_written = hills_written + 1;
                END IF;

                hill_state = 'RESTART';
                --RAISE NOTICE 'RESTART AT notInHillDistance % with height % and length %',notInHillDistance,hill_height,hill_length;
                hill_height = 0;
                hill_length = 0;
                notInHillDistance = 0;
                hill_geometry = NULL;
                last_point = NULL;

            END IF;



        END IF;

        --RAISE NOTICE 'Height % dHeight %, point number %, state %', pr.height, dHeight, pr.p_order, hill_state;
        previous_height = pr.height;

    END LOOP;

    RETURN json_build_object('wrote_hills', CASE WHEN hills_written > 0 THEN true ELSE false END,
                             'hill_count',  hills_written,
                             'final_state', hill_state



                             );

END;
$$ LANGUAGE PLPGSQL;
