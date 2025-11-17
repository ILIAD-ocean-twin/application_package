import sys

sys.path.insert(0, ".local/lib/python3.12/site-packages")

import os

import contextlib
from collections import namedtuple
from pathlib import Path

import directory_tree
import matplotlib.pyplot as plt
import numpy as np
import pyopia
import pyopia.cli
import pyopia.instrument.silcam
import pyopia.io
import pyopia.statistics
import dask.diagnostics
import json

from xarray.core.parallelcompat import list_chunkmanagers

list_chunkmanagers()


def calculcate_copepod_concentration(
    xstats,
    image_stats,
    cop_prob_lim=0.7,
    path_length_mm=30,
):
    """Calculate copepod concentration (#/L) from PyOPIA stats"""

    # Get xstats for probable copepod particles
    xstats_cop = xstats.where(xstats["probability_copepod"] > cop_prob_lim).dropna(
        dim="index"
    )

    # Recreate PyOPIA config from xstats
    conf = pyopia.io.steps_from_xstats(xstats)
    pixel_size = conf["general"]["pixel_size"]

    # Get number of images
    num_images = image_stats.timestamp.size

    # Get raw image shape
    imx, imy, _ = xstats_cop.attrs["raw_image_shape"]

    # Calculate sample volume
    sample_volume = pyopia.statistics.get_sample_volume(
        pixel_size, path_length_mm, imx=imx, imy=imy
    )

    # Calculate total number of copepods per liter based on total volume sampled
    total_sample_volume = float(sample_volume * num_images)
    num_copepods = xstats_cop.index.size
    copepods_per_litre = float(num_copepods / total_sample_volume)

    return_tuple = namedtuple(
        "CopepodEstimates",
        ["copepods_per_litre", "num_copepods", "total_sample_volume", "num_images"],
    )

    return return_tuple(
        copepods_per_litre=copepods_per_litre,
        num_copepods=num_copepods,
        total_sample_volume=total_sample_volume,
        num_images=num_images,
    )


def main():

    # proj_dir_tmp = tempfile.TemporaryDirectory()
    # proj_dir = Path(proj_dir_tmp.name) / Path("pyopiaproject")
    # proj_dir = Path("./")
    # copy /app/pyopiaproject to proj_dir

    proj_dir = Path("pyopiaproject")
    # os.makedirs(proj_dir, exist_ok=True)
    # proj_name = proj_dir.name
    # print(proj_dir)

    # with contextlib.chdir(proj_dir.parent):
    # with contextlib.chdir(proj_dir):
    pyopia.cli.init_project("pyopiaproject", instrument="silcam", example_data=True)

    os.makedirs(proj_dir / "processed", exist_ok=True)

    directory_tree.DisplayTree(proj_dir, header=True)

    #
    # Load PyOPIA config, get stats file and processed directory paths
    #
    conf = pyopia.io.load_toml(proj_dir / Path("config.toml"))

    stats_file = proj_dir / Path(
        conf["steps"]["output"]["output_datafile"] + "-STATS.nc"
    )
    processed_dir = stats_file.parent

    print(conf)

    #
    # Generate list of images to be processed
    #
    with contextlib.chdir(proj_dir):
        img_files = sorted(Path("images").glob("*.silc"))
    print(img_files)

    #
    # Process images
    #
    with contextlib.chdir(proj_dir):
        # Initialise the pipeline and run the initial steps
        processing_pipeline = pyopia.pipeline.Pipeline(conf)

        for filename in img_files:
            # Process the image to obtain the stats dataframe
            stats = processing_pipeline.run(str(filename))

    #
    # Merge per-image stats files into one netcdf
    #
    directory_tree.DisplayTree(processed_dir, header=True)

    # with contextlib.chdir(proj_dir):
    pyopia.io.merge_and_save_mfdataset(processed_dir)

    #
    # Load stats
    #
    xstats = pyopia.io.load_stats(str(stats_file))
    stats = xstats.to_pandas()
    stats["depth"] = np.random.uniform(5, 15, size=xstats.index.size)
    pyopia.statistics.add_best_guesses_to_stats(stats)
    print(stats)

    #
    # Load image stats - contains whole-image statistics
    #
    image_stats = pyopia.io.load_image_stats(stats_file)
    print(image_stats)

    #
    # Get particles with high probability of being copepods
    #
    xstats = xstats.where(xstats["probability_copepod"] > 0.7).dropna(dim="index")
    print(xstats)

    #
    # Plot volume distribution from xstats - only copepods [uL / sample vol.]
    #
    dias, vd_total = pyopia.statistics.vd_from_stats(
        xstats, conf["general"]["pixel_size"]
    )

    plt.plot(
        dias,
        vd_total,
    )
    plt.xscale("log")
    plt.xlabel("ECD [um]")
    plt.ylabel("Volume Distribution [uL/sample vol.]")
    plt.savefig(proj_dir / "vd_copepods.png")

    #
    # Plot volume distribution from xstats - only copepods [uL / L]
    # NB: This needs the correct number of images to get the total sample volume right - use image_stats for that
    #
    path_length_mm = 30
    pixel_size = conf["general"]["pixel_size"]

    # Get number of images
    nimages = image_stats.timestamp.size

    # Get raw image shape
    imx, imy, _ = xstats.attrs["raw_image_shape"]

    # Calculate sample volume
    sample_volume = pyopia.statistics.get_sample_volume(
        pixel_size, path_length_mm, imx=imx, imy=imy
    )

    # Convert to uL / L
    vd_total_scaled = vd_total / (sample_volume * nimages)

    plt.plot(dias, vd_total_scaled, "k")
    plt.xscale("log")
    plt.xlabel("ECD [um")
    plt.ylabel("Volume distribution [uL/L]")
    plt.xlim(80, 12000)

    plt.savefig(proj_dir / "vd_copepods_per_L.png")

    #
    # Create montage of copepod particles
    #
    im_mont = pyopia.statistics.make_montage(
        xstats.to_pandas(),
        pixel_size=pixel_size,
        roidir=str(proj_dir / Path(conf["steps"]["statextract"]["export_outputpath"])),
        auto_scaler=500,
        msize=1024,
        maxlength=100000,
        crop_stats=None,
        eyecandy=True,
    )

    # pyopia.plotting.montage_plot(im_mont, pixel_size)
    # plt.title(f"Montage based on copepod particles (N={xstats.index.size})")
    # plt.savefig(proj_dir / "montage_copepods.png")
    # ax = plt.axes()

    h, w = im_mont.shape[:2]
    fig = plt.figure(figsize=(w / 100, h / 100), dpi=100)  # (w,dpi)→pixels
    ax = fig.add_axes([0, 0, 1, 1])
    msize = np.shape(im_mont)[0]

    ex = pixel_size * np.float64(msize) / 1000.0

    ax.imshow(im_mont, cmap="gray", extent=[0, ex, 0, ex])
    ax.set_ylabel("mm")
    ax.set_xlabel("mm")
    plt.title(f"Montage based on copepod particles (N={xstats.index.size})")
    fig.savefig(proj_dir / "particles.png", dpi=100, bbox_inches="tight", pad_inches=0)

    #
    # Calculate total number of copepods per liter based on total volume sampled
    #
    total_sample_volume = sample_volume * nimages
    num_copepods = xstats.index.size
    print(f"Total number of images: {nimages}")
    print(f"Total volume sampled: {total_sample_volume:.1f} (L)")
    print(f"Number of copepods: {num_copepods}")
    print(f"Copepods per liter: {num_copepods / total_sample_volume:.2g} (#/L)")

    # ymin = stats["minr"].min() * pixel_size / 1000.0
    # ymax = stats["maxr"].max() * pixel_size / 1000.0
    # xmin = stats["minc"].min() * pixel_size / 1000.0
    # xmax = stats["maxc"].max() * pixel_size / 1000.0

    point_lat = xstats.attrs["latitude"]
    point_lon = xstats.attrs["longitude"]

    ## bbox with 1m^2 of area around the point
    bbox_size_m = 1.0
    ymin = point_lat - (bbox_size_m / 2) / 111320.0
    ymax = point_lat + (bbox_size_m / 2) / 111320.0
    xmin = point_lon - (bbox_size_m / 2) / (111320.0 * np.cos(np.deg2rad(point_lat)))
    xmax = point_lon + (bbox_size_m / 2) / (111320.0 * np.cos(np.deg2rad(point_lat)))

    nc_metadata = {
        "filename": stats_file.name,
        "description": "NetCDF result file containing PyOPIA statistics",
        "geometry": {
            "type": "Point",
            "coordinates": [
                point_lon,
                point_lat,
            ],
        },
        "start_datetime": stats["timestamp"].min(),
        "end_datetime": stats["timestamp"].max(),
        "media_type": "application/netcdf",
        "bbox": [
            float(xmin),
            float(ymin),
            float(xmax),
            float(ymax),
        ],
    }

    with open(proj_dir / "nc_metadata.json", "w") as f:
        json.dump(nc_metadata, f, indent=4, default=str)

    #
    # Calculate total number of copepods per liter based on total volume sampled
    # with custom function defined at the top of this notebook
    #
    calculcate_copepod_concentration(
        xstats,
        image_stats,
        cop_prob_lim=0.7,
        path_length_mm=30,
    )


if __name__ == "__main__":
    main()
