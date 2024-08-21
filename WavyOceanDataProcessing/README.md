# Application Packaging Best practices Tutorial (Wavy Ocean Data Processing)

In this tutorial we aim to show the practice on preparing an Application Package Tool with an existing Jupyter Notebook example script.

## Our Jupyter Notebook python example

The [`WavyOcean.ipynb`](files/WavyOcean.ipynb) file is a Jupyter Notebook that reads a specific header (`temp1`) on CSV files, from the WAVY Ocean drifters, from [MELOA](www.ec-meloa.eu/) Project. This CSV is passed as a public URL argument. This tool also allows the user to select the operator, i.e. eq (equal), lt (less than), gt (greater than), lte (less or equal), gte (greater or equal), ne (not equal), and the value to compare with the `temp1` column. The output is a CSV file with the rows that match the operator and value.

#### NOTE: this script only runs with python greater than 3.10.

This code depends of 3 variables that will be the inputs of our tool:

- operation
- base_value
- dataset

The script will also generate a metadata.json file with geo spacial and temporal information of the CSV file generated.

TODO: example of the code execution

### Create python scrypt code

We will add the 3 possible arguments with the _Click_ Package (`pip install click`), like in the [HelloWorld Tutorial](../HelloWorld/README.md):

- --op -> operation: eq (default), lt, gt, lte, gte, ne
- --base -> base value
- --url -> dataset file URL

Create your code using the _Click_ Package. Copy the content of `WavyOcean.ipynb` to `WavyOcean.py` and edit:

```python
import sys
import click
import urllib.request
import os
import csv
import json


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
    urllib.request.urlretrieve(url, "to_parse.csv")

    output_dir = "./result"

    try:
        os.mkdir(output_dir)
    except FileExistsError:
        pass

    compare_op = ["eq", "ne", "gt", "gte", "lt", "lte"]

    if op not in compare_op:
        print(f"Operation not supported")
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
```

With the above python file you should be able to call with:

```bash
python3 WavyOcean.py --base 24 --url http://catalogue.ec-meloa.eu/dataset/24116ae9-7425-45e8-a605-29fbf917649c/resource/c2f7d170-e0eb-4f35-a82f-5a8bc4be38f6/download/meloa_test_00064_00wo52_20211029t111600_20220122t193600_13_133.csv
```

which will generate 2 files inside the `./result` folder:

- `result.csv` with the filtered rows, that has the `temperature` column greater than 24ºC.
- `metadata.json` with the geo spacial and temporal information of the CSV file generated.

You now also have a _--help_ option:

```bash
python3 WavyOcean.py --help
```

which returns:

> Usage: WavyOcean.py [OPTIONS]
> Wavy Ocean Data Processing
>
> Options:
> -op, --op TEXT operation
> -base, --base TEXT baseline [required]
> -url, --url TEXT url [required]
> --help Show this message and exit.

## Application Packaging the Wavy Ocean Data Processing Tool

To ensure that this tool can be run everywhere, we will follow the Application Packaging best practices with Application containerization and CWL tool description, as explained on [HelloWorld Tutorial](../HelloWorld/README.md).

**NOTE**: A complete version of the WavyOcean example (wich also includes [logging](https://docs.python.org/3/library/logging.html)) is available in the github repository: [WavyOcean.py](./files/WavyOcean_v2.py)

### Application package software container

#### The Dockerfile

Create a `Dockerfile` file with the instruction to create a Docker Image.
The file contents are:

```docker
FROM python:alpine3.19

WORKDIR /opt

RUN pip install click

COPY WavyOcean.py /opt

CMD ["python", "/opt/WavyOcean.py",  "--help"]
```

#### Build the Docker Image

Use the Docker CLI to build your meloa-wo-filter:v0 Docker Image

Open a commandline in the same folder where you have the _`Dockerfile`_ and the _`WavyOcean.py`_ files and run:

```bash
docker build . -t meloa-wo-filter:0.1.0 --no-cache
```

#### Run the Docker Image

To test run the docker image we created just type on the command-line:

```bash
docker run meloa-wo-filter:0.1.0
```

And you will get a response from the application help as seen before:

> Usage: WavyOcean.py [OPTIONS]
> Wavy Ocean Data Processing
>
> Options:
> -op, --op TEXT operation
> -base, --base TEXT baseline [required]
> -url, --url TEXT url [required]
> --help Show this message and exit.

To execute the python code we added to the docker image type on the command-line:

```bash
docker run -v ./result:/opt/result meloa-wo-filter:0.1.0 sh -c "python /opt/WavyOcean.py --base 24 --url http://catalogue.ec-meloa.eu/dataset/24116ae9-7425-45e8-a605-29fbf917649c/resource/c2f7d170-e0eb-4f35-a82f-5a8bc4be38f6/download/meloa_test_00064_00wo52_20211029t111600_20220122t193600_13_133.csv"
```

This command is slightly more complex but will not be required again. We need it to ensure we have our code working as expected. It will create the _`./result/result.csv`_ and _`./result/metadata.json`_ files.

#### Upload the Docker Image to a Docker Repository

I've created a [repository for this WavyOcean container image at DockerHub](https://hub.docker.com/repository/docker/amarooliveira/meloa-wo-filter/general) so, now I can tag them correctly and update this container image at the repository.

**NOTE:** If you created your own repository at [Docker Hub](https://hub.docker.com/) you may need to [`docker login`](https://docs.docker.com/reference/cli/docker/login/) on the command-line.

To update the image tag to include my repository name (_amarooliveria/meloa-wo-filter_) I need to execute:

```bash
docker tag meloa-wo-filter:0.1.0 amarooliveira/meloa-wo-filter:0.1.0
```

Now that I have the correct name for my image I can update the image in the repository:

```bash
docker push amarooliveira/meloa-wo-filter:0.1.0
```

## Describe the Application Package Tool

### The CWL Document

In an Application Package, the structure that is defined for a CWL document is composed of at least 2 classes, respectively the class _workflow_ that allows for the definition of parameters of the application, and an instance of the class _commandLineTool_ that enables the description of tools and respectively arguments.

> cwlVersion: v1.2
>
> $graph:
>
> - class: Workflow
>   id: wo_data_pipeline
>   ...
>
> - class: CommandLineTool
>   id: wo_data_tool
>   ...

### Describe the command-line Tool

To describe the Application Package Tool create a _`WavyOcean-tool-010.cwl`_ file with the following content:

```cwl
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: CommandLineTool
  baseCommand: python
  id: wo_data_tool

  arguments:
  - /opt/WavyOcean.py
  - --url
  - valueFrom: $( inputs.url )
  - --base
  - valueFrom: $( inputs.base )
  - valueFrom: $(
      function () {
        if (inputs.op) {
          return ["--op", inputs.op];
        } else {
          return [];
        }
      }())
  inputs:
    url:
      type: string
      doc: CSV dataset endpoint
    base:
      type: float
      doc: base value
    op:
      type: string?
      doc: operation to filter
      default: "gt"

  outputs:
    results:
      type: File
      outputBinding:
        glob: "result/result.csv"
      doc: result file
      s:fileFormat: "text/csv"
    metadata:
      type: File
      outputBinding:
        glob: "result/metadata.json"
      doc: metadata description
      s:fileFormat: "application/json"

  requirements:
    ResourceRequirement: {}
    NetworkAccess:
      networkAccess: true
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: meloa-wo-filter:0.1.0

  s:softwareVersion: 0.1.0
  s:name: WO Data Processing Tool
  s:description: A python Wavy Ocean Data Processing example tool
  s:keywords:
    - python
    - wavy
    - meloa
    - ocean
    - data processing
    - example tool
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Marco Oliveira
      s:email: marco.a.oliveira@inesctec.pt
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/
  s:dateCreated: "2024-08-20"
```

### Describe the Application Package

If you intend to provide more than a too, then the CWL must also include the description of the _workflow_ class.

Create a _`WavyOcean-pipeline.cwl`_ file with the following content:
