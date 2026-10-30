#! NOTES
#! define inputs with click


import datetime
import geopandas as gpd
import numpy as np

from opendrift.models.openoil import OpenOil

# from opendrift.models.sedimentdrift import OceanDrift
from opendrift.readers import reader_netCDF_CF_generic
import opendrift
import os

#! new start
import click


@click.command()
@click.option(
    "--norkyst_agg",
    "-norkyst_agg",
    "norkyst_agg",
    help="OPeNDAP NorKyst v3",
    required=False,
    default="https://thredds.met.no/thredds/dodsC/fou-hi/norkystv3_800m_m00_be",
)
@click.option(
    "--starttime",
    "-starttime",
    "starttime",
    help="Start time of simulation",
    required=False,
    default=datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
    type=click.DateTime(),
)
@click.option(
    "--duration",
    "-duration",
    "duration",
    help="Duration of simulation, in hours",
    required=False,
    default=8,
    type=int,
)
#! new end

def run(norkyst_agg, starttime, duration):
    opendrift.__version__

    os.makedirs("modeloutput", exist_ok=True)

    gdf = gpd.read_file("/simulation/data/EMODnet_HA_OG_Offshore_Installations_20240216.shp")
    myfilter = np.logical_and(gdf.COUNTRY == "Norway", gdf.FUNCTION == "Subsea", gdf.PRIM_PROD == "Crude Oil")
    gdf = gdf[myfilter]
    gdf["CODE"] = gdf["CODE"].astype(int)
    gdf = gdf.head(4)

    # gdf.T

    o = OpenOil(loglevel=20)
    # Reader
    # norkyst_agg = "https://thredds.met.no/thredds/dodsC/fou-hi/norkystv3_800m_m00_be"
    reader_norkyst = reader_netCDF_CF_generic.Reader(norkyst_agg)

    # Configure Model
    o.add_reader(
        reader_norkyst,
    )
    o.set_config("drift:vertical_mixing", True)
    o.set_config("seed:droplet_size_distribution", "uniform")
    o.set_config("seed:droplet_diameter_min_subsea", 0.0001)
    o.set_config("seed:droplet_diameter_max_subsea", 0.0005)

    # Seed Particles
    lons = gdf.geometry.x.values
    lats = gdf.geometry.y.values
    depths = gdf.WD_M.values
    codes = list(gdf.CODE.values)

    for kk in range(len(lons)):
        o.seed_elements(
            lon=lons[kk],
            lat=lats[kk],
            z=-depths[kk],
            radius=64,
            number=256,
            origin_marker=codes[kk],
            time=starttime,
        )

    o.run(
        duration=datetime.timedelta(hours=duration),
        time_step=600,
        time_step_output=600,
        outfile="modeloutput/result.nc",
    )


if __name__ == "__main__":
    run()
