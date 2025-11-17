import os
import pprint
from datetime import datetime, timedelta
from typing import Dict

import click
import pandas as pd
import pyproj

# import toml
import xarray as xr

from opendrift.models.sedimentdrift import OceanDrift
from opendrift.readers import reader_netCDF_CF_generic
from tqdm import tqdm

OPENDRIFT_LOGLEVEL = 20  # Info output (0: debug, 50: no output)


def _load_config_from_env(
    aqua_site_file,
    aqua_site_distances_files,
    aqua_opendrift_particles_per_site,
    aqua_opendrift_simulation_duration_hours,
    aqua_opendrift_output_file,
    aqua_connectivity_number_of_neighbours,
    aqua_connectivity_radius,
    aqua_connectivity_output_file,
    aqua_connectivity_output_file_with_locality_id,
) -> Dict:
    config = {
        "sitedata": {
            "site_file": aqua_site_file,
            "sites_distances_file": aqua_site_distances_files,
        },
        "opendrift": {
            "particles_per_site": aqua_opendrift_particles_per_site,
            "simulation_duration_hours": aqua_opendrift_simulation_duration_hours,
            "output_file": aqua_opendrift_output_file,
        },
        "connectivity": {
            "number_of_neighbours": int(aqua_connectivity_number_of_neighbours),
            "radius": int(aqua_connectivity_radius),
            "output_file": aqua_connectivity_output_file,
            "output_file_withLocalityId": aqua_connectivity_output_file_with_locality_id,
        },
    }
    return config


def run_opendrift(config, df_locs, starttime):
    """Run OpenDrift forecast from all localities"""

    # Initialize opendrift model
    o = OceanDrift(
        loglevel=OPENDRIFT_LOGLEVEL
    )  # Set loglevel to 0 for debug information

    # Norkyst ocean model for current
    norkyst_agg = "https://thredds.met.no/thredds/dodsC/sea/norkyst800m/1h/aggregate_be"
    reader_norkyst = reader_netCDF_CF_generic.Reader(norkyst_agg)

    # Configure model
    o.add_reader(
        reader_norkyst,
        variables=["x_sea_water_velocity", "y_sea_water_velocity", "x_wind", "y_wind"],
    )
    o.set_config("environment:fallback:x_sea_water_velocity", 0)
    o.set_config("environment:fallback:y_sea_water_velocity", 0)
    o.set_config("drift:horizontal_diffusivity", 1)
    o.set_config("general:coastline_action", "previous")

    # Seed at all localities
    for _, row in df_locs.iterrows():
        lon_ = row["lon"]
        lat_ = row["lat"]
        o.seed_elements(
            lon=lon_,
            lat=lat_,
            radius=10,
            number=config["particles_per_site"],
            origin_marker=row["localityNo"],
            time=starttime,
        )

    # Run model
    o.run(
        duration=timedelta(hours=config["simulation_duration_hours"]),
        time_step=600,
        time_step_output=600,
        outfile=config["output_file"],
    )


def calculate_distance_connectivity_nearest(
    ncfile, df_sites, df_dists, min_dist, num_sites=10, particles_per_site=100
):
    """Calculate simple connectivity between sites, only consider 10 closest sites to each

    Approach: count number of trajectories that pass within a radius of each site.
              Normalize by total tractories, return % values.
    """

    names = df_sites.set_index("localityNo")["name"]

    df_connect = pd.DataFrame(
        index=df_sites.localityNo, columns=df_sites.localityNo, dtype="float"
    )
    df_connect[:] = 0
    geod = pyproj.Geod(ellps="WGS84")

    with xr.open_dataset(ncfile) as ds:
        for _, row in tqdm(df_sites.iterrows(), total=df_sites.shape[0]):

            # Get N nearest sites
            nearest_ids = (
                df_dists[row["localityNo"]]
                .sort_values(ascending=True)
                .index[:num_sites]
            )
            lons = [row["lon"]] * ds.lon.shape[1]
            lats = [row["lat"]] * ds.lon.shape[1]

            # Iterate trajecory, determine overlap with current bound, determine origin
            for t in range(ds.lon.shape[0]):
                origin = ds.origin_marker.values[t, 0]
                if not (origin in nearest_ids):
                    continue
                dists = geod.inv(lons, lats, ds.lon.values[t, :], ds.lat.values[t, :])[
                    2
                ]

                # Add 1 to this site-origin if any trajectory passes closer than min_dist
                df_connect.loc[row["localityNo"], origin] += (dists < min_dist).max()

    # Normalize (convert to %)
    df_connect = 100 * df_connect / particles_per_site

    return df_connect


def _replace_headers_in_connectivity_dataframe_num2name(
    df_connectivity: pd.DataFrame, df_localities: pd.DataFrame
) -> pd.DataFrame:
    """for a connectivity dataframe with indices/columns are site IDs, change them the indices/
    columns the site names"""
    new_index_dict = {}
    for _, row in df_localities.iterrows():
        new_index_dict[row["localityNo"]] = row["name"]
    dfx = df_connectivity.copy()
    dfx.rename(columns=new_index_dict, inplace=True)
    dfx.rename(index=new_index_dict, inplace=True)
    dfx.rename_axis("name", axis=0, inplace=True)
    dfx.rename_axis("name", axis=1, inplace=True)
    return dfx


@click.command()
@click.option(
    "--aqua_site_file",
    "-aqua_site_file",
    "aqua_site_file",
    help="aqua_site_file",
    required=True,
)
@click.option(
    "--aqua_site_distances_files",
    "-aqua_site_distances_files",
    "aqua_site_distances_files",
    help="aqua_site_distances_files",
    required=True,
)
@click.option(
    "--aqua_opendrift_particles_per_site",
    "-aqua_opendrift_particles_per_site",
    "aqua_opendrift_particles_per_site",
    help="aqua_opendrift_particles_per_site",
    type=int,
    required=True,
)
@click.option(
    "--aqua_opendrift_simulation_duration_hours",
    "-aqua_opendrift_simulation_duration_hours",
    "aqua_opendrift_simulation_duration_hours",
    help="aqua_opendrift_simulation_duration_hours",
    type=int,
    required=True,
)
@click.option(
    "--aqua_opendrift_output_file",
    "-aqua_opendrift_output_file",
    "aqua_opendrift_output_file",
    help="aqua_opendrift_output_file",
    default="modeloutput/salmon_midnor.nc",
    required=True,
)
@click.option(
    "--aqua_connectivity_number_of_neighbours",
    "-aqua_connectivity_number_of_neighbours",
    "aqua_connectivity_number_of_neighbours",
    help="aqua_connectivity_number_of_neighbours",
    type=int,
    required=True,
)
@click.option(
    "--aqua_connectivity_radius",
    "-aqua_connectivity_radius",
    "aqua_connectivity_radius",
    help="aqua_connectivity_radius",
    type=int,
    required=True,
)
@click.option(
    "--aqua_connectivity_output_file",
    "-aqua_connectivity_output_file",
    "aqua_connectivity_output_file",
    help="aqua_connectivity_output_file",
    default="modeloutput/salmon_midnor_connectivity.xlsx",
    required=True,
)
@click.option(
    "--aqua_connectivity_output_file_with_locality_id",
    "-aqua_connectivity_output_file_with_locality_id",
    "aqua_connectivity_output_file_with_locality_id",
    help="aqua_connectivity_output_file_with_locality_id",
    default="modeloutput/salmon_midnor_connectivity_withLocalityId.xlsx",
    required=True,
)
@click.option(
    "--starttime",
    help="Start time of simulation",
    default=datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
    type=click.DateTime(),
)
def run(
    aqua_site_file,
    aqua_site_distances_files,
    aqua_opendrift_particles_per_site,
    aqua_opendrift_simulation_duration_hours,
    aqua_opendrift_output_file,
    aqua_connectivity_number_of_neighbours,
    aqua_connectivity_radius,
    aqua_connectivity_output_file,
    aqua_connectivity_output_file_with_locality_id,
    starttime,
):
    # Load config
    config = _load_config_from_env(
        aqua_site_file,
        aqua_site_distances_files,
        aqua_opendrift_particles_per_site,
        aqua_opendrift_simulation_duration_hours,
        aqua_opendrift_output_file,
        aqua_connectivity_number_of_neighbours,
        aqua_connectivity_radius,
        aqua_connectivity_output_file,
        aqua_connectivity_output_file_with_locality_id,
    )
    pprint.pp(config)

    os.makedirs("modeloutput", exist_ok=True)

    import opendrift

    print(f"Opendrift version: {opendrift.__version__}  ")

    # Load positions for sites nearest to Tristeinen
    df_locs = pd.read_excel(config["sitedata"]["site_file"])
    df_dists = pd.read_excel(config["sitedata"]["sites_distances_file"], index_col=0)

    print(f"Running model, start time: {starttime}")
    run_opendrift(config["opendrift"], df_locs, starttime)

    # Calculate and store connectivity matrix
    print("Calculate connectivity matrix")
    # df_connect = calculate_simple_connectivity(OUTFILE, df_locs)
    df_connect = calculate_distance_connectivity_nearest(
        config["opendrift"]["output_file"],
        df_locs,
        df_dists,
        min_dist=config["connectivity"]["radius"],
        num_sites=config["connectivity"]["number_of_neighbours"],
        particles_per_site=config["opendrift"]["particles_per_site"],
    )
    # (opt) write a connectivity matrix that has localityNo instead of site names as headers
    if "output_file_withLocalityId" in config["connectivity"].keys():
        df_connect.to_excel(config["connectivity"]["output_file_withLocalityId"])
    df_connect = _replace_headers_in_connectivity_dataframe_num2name(
        df_connect, df_locs
    )
    df_connect.to_excel(config["connectivity"]["output_file"])

    print("--- ALL DONE ---", config["opendrift"]["output_file"])
    print("--- ALL DONE ---")


if __name__ == "__main__":
    run()
