raster2pgsql -d -I -C -s 4326  N50W004.hgt dem.srtm_raster -t 50x50 | psql -d daveb
raster2pgsql -d -I -C -s 27700  sx_terrain_50_merged.tif dem.terrain_50_raster -t 50x50 | psql -d daveb
raster2pgsql -d -I -C -s 4326  N050W004_AVE_DSM.tif dem.alos_raster -t 50x50 | psql -d daveb
raster2pgsql -d -I -C -s 3035  sx_clipped_copernicus.tif dem.copernicus_raster -t 25x25 | psql -d daveb


