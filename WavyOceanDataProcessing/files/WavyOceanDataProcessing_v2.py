import sys
import logging
import click
import urllib.request
import os
import csv
import json

MODEL_NAME = "[WO_DATA_PROCESSING]"

logging.basicConfig(
    stream=sys.stderr,
    level=logging.DEBUG,
    format=f"%(asctime)s %(levelname)-8s {MODEL_NAME} %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)


@click.command(
    short_help="WO Data Processing",
    help="Wavy Ocean Data Processing",
    context_settings=dict(
        ignore_unknown_options=True,
        allow_extra_args=True,
    ),
)
@click.option("--op", "-op", "op", help="operation", required=False, default="gt")
@click.option("--base", "-base", "base", help="base value", required=True)
@click.option("--url", "-url", "url", help="url / dataset", required=True)
def main(op, base, url):

    logging.info(f"Process started")
    urllib.request.urlretrieve(url, "to_parse.csv")

    output_dir = "./result"

    try:
        os.mkdir(output_dir)
    except FileExistsError:
        pass

    compare_op = ["eq", "ne", "gt", "gte", "lt", "lte"]

    if op not in compare_op:
        logging.error(f"Operation not supported")
        sys.exit(1)

    valid_op = ""
    match op:
        case "ne":
            valid_op = "!="
        case "gt":
            valid_op = ">"
        case "gte":
            valid_op = ">="
        case "lt":
            valid_op = "<"
        case "lte":
            valid_op = "<="
        case _:
            valid_op = "=="

    coordinates = []
    dates = []
    temps1 = []
    results = []
    headers = None
    with open("to_parse.csv", "r") as csv_file:
        reader = csv.reader(csv_file)
        headers = next(reader)

        temp1 = headers.index("temp_1")
        latitude = headers.index("latitude")
        longitude = headers.index("longitude")
        times = headers.index("timestamp")
        for row in list(reader):
            if eval(f"{row[temp1]} {valid_op} {base}"):
                results.append(row)
                temps1.append(row[temp1])
                coordinates.append((float(row[latitude]), float(row[longitude])))
                dates.append(row[times])

    _from = min(dates)
    _to = max(dates)
    bbox = bounding_box(coordinates)
    metadata = {
        "description": "MELOA_WO_TEMP1",
        "geometry": {"type": "MultiPoint", "coordinates": coordinates},
        "media_type": "TEXT",
        "start_datetime": _from,
        "end_datetime": _to,
        "bbox": bbox,
    }

    metadataFile = os.path.join(output_dir, "metadata.json")
    f = open(metadataFile, "a")
    f.write(json.dumps(metadata))
    f.close()

    results.insert(0, headers)
    with open(os.path.join(output_dir, "result.csv"), "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerows(results)

    logging.info(f"Process finished!")


def bounding_box(points):
    x_coordinates, y_coordinates = zip(*points)

    return [
        min(x_coordinates),
        min(y_coordinates),
        max(x_coordinates),
        max(y_coordinates),
    ]


if __name__ == "__main__":
    main()
