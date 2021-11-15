# Strategy

All dem data is loaded into the schema **dem**

Raster data is converted to a set of vector tiles for ease of calculation and computation

# Obtaining Dems

Opendem is a project attempting to collate dem information for free worldwide https://wiki.openstreetmap.org/wiki/OpenDEM


- SRTM 30m [https://www.gislounge.com/download-30-meter-srtm-data-easily-with-this-point-and-click-interface/]
- terrain 50 [https://www.ordnancesurvey.co.uk/business-government/tools-support/terrain-50-support]
- ALOS 30 [https://www.eorc.jaxa.jp/ALOS/en/aw3d30/index.htm]
- Copernicus []

# Loading Dems

Loaded using the raster2pgsql utility. All dems converted to 4326 CRS


```bash
cd dem_data
./load_dem_data.sh
```

# Making vector tile sets

Run the SQL in **make_vector_tile_sets.sql**
