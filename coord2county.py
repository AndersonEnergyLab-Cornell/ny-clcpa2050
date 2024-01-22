import pandas as pd
import geopy.distance
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon
import numpy as np
import geopandas as gpd
import pyproj
from shapely.ops import transform

proj = pyproj.Transformer.from_crs("epsg:26918", "epsg:4326")
# read the shapefile
shapefile_path = 'NYS_Civil_Boundaries.shp/Counties.shp'
gdf = gpd.read_file(shapefile_path)

# print the first 5 rows of the attribute table
print(gdf.head())

# 1. Load county boundaries data (e.g., shapefile) and extract names and polygons
# counties_df = pd.read_csv('Data/NYcounties.csv')
# county_names = gdf['NAME'].tolist()
# for poly in gdf.geometry:
#     if poly.geom_type == 'Polygon':
#         countinue
#     elif poly.geom_type == 'MultiPolygon':
#         for p in poly:
#             polyg = polygon.union(p)
#         poly = polyg


# polygons = gdf.geometry.tolist()
# polygons = [p for poly in polygons for p in poly]
# county_polygons = [Polygon(polygon) for polygon in gdf['geometry'].tolist()]

# 2. Convert list of coordinates into points
coords = pd.read_csv('Data/Temperature/Temp1980.csv',header = None)
lat = coords.loc[:,0].to_numpy()
lon = coords.loc[:,1].to_numpy()
coords = [lon,lat]
coords = np.array(coords)
coords = coords.T
print(coords)
# coords = [(40.7128, -74.0060), (42.6526, -73.7562), (43.0481, -76.1474)]
gdf['nearest_point'] = None
# Iterate over each county polygon
for index, row in gdf.iterrows():
    county_poly = row['geometry']
    if county_poly.geom_type == 'MultiPolygon':
        polygon = Polygon()
        for poly in county_poly.geoms:
            polyg = polygon.union(poly)
        county_poly = polyg
    county_name = row['NAME']
    county_poly = transform(proj.transform, county_poly)
    # print(county_poly)
    # Find the nearest point in the county to each coordinate
    nearest_points = []
    min_dist = float('inf')
    for point in coords:
        centroid = county_poly.centroid
        # print(centroid)
        dist = centroid.distance(Point(point))
        # print(dist)
        # dist = county_poly.distance(Point(point))
        if dist < min_dist:
            min_dist = dist
            nearest_point = point
        gdf.at[index, 'nearest_point'] = nearest_point
    # Add the nearest point coordinates to the counties dataframe
    # gdf.loc[index, 'nearest_points'] = nearest_points
# np.savetxt('Data/nearest_point.csv',nearest_point)
counties = gdf[['NAME','FIPS_CODE','nearest_point']]
counties.to_csv('countywithpoint.csv')