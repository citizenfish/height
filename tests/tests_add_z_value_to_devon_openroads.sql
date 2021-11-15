DROP TABLE IF EXISTS ng_research.devon_roads_with_z;

WITH DEVON AS (

    SELECT ST_BUFFER(ST_TRANSFORM(wkb_geometry,27700),500) as devon_geom
    FROM boundary."Boundary-line-ceremonial-counties_region"
    WHERE name='Devon'
)

SELECT  ogc_fid,
		dem.add_height_to_line(wkb_geometry) as wkb_geometry,
		class,
		roadnumber,
		name1,
		name2,
		formofway,
		"primary",
		trunkroad,
		loop,
		startnode,
		endnode,
		structure,
		function
INTO ng_research.devon_roads_with_z
FROM openroads.roads,DEVON
WHERE ST_CONTAINS(devon_geom,wkb_geometry);

ALTER TABLE ng_research.devon_roads_with_z ALTER COLUMN wkb_geometry type geometry(LineStringZ, 4326);