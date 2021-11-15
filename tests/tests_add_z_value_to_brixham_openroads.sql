DROP TABLE IF EXISTS ng_research.brixham_roads_with_z;
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
INTO ng_research.brixham_roads_with_z
FROM openroads.roads
WHERE wkb_geometry && 'BOX(281220.3 49454.2,298308.6 55992.5)'::BOX2d;

ALTER TABLE ng_research.brixham_roads_with_z ALTER COLUMN wkb_geometry type geometry(LineStringZ, 4326);