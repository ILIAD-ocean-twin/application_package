# Application Packaging Best practices Tutorial (Wavy Ocean Data Processing)

In this tutorial we aim to show the practice of creating an application package tool and pipeline from an existing Jupyter Notebook sample script.

## Existing Notebook Example (tha basis for this tutorial)

The file [`WavyOceanDataProcessing.ipynb`](files/WavyOceanDataProcessing.ipynb) is a Jupyter Notebook (also available as [Google Colab Notebook](https://colab.research.google.com/drive/1vk8UBxYbeu4WwY8JgYDcTSL8FTFpFz8W?usp=sharing)) that reads a CSV observation file, from a WAVY Ocean drifter dataset, generated during the European project [MELOA](www.ec-meloa.eu/) and publicly available at the [project's catalogue](http://catalogue.ec-meloa.eu/). This notebook allows the user to select the dataset (and url for the csv file), the operation, i.e. `eq` (equal), `lt` (less than), `gt` (greater than), `lte` (less than or equal), `gte` (greater than or equal) or `ne` (not equal), to be performed and the value to be compared with the contents of `temp_1` column, and to extract and visualise all observations that are valid for the specified filter. The output of the notebook is a CSV file with the selected rows and an interactive map displaying these values. 

You may have noticed that the notebook also creates a metadata.json file with geospatial and temporal boundaries from the outputed CSV file.
```json
{
   "description":"MELOA_WO_TEMP1",
   "geometry":{
      "type":"MultiPoint",
      "coordinates":[
         [28.6095,-17.9338],[28.6147,-17.9268],[28.615,-17.9266],[28.6156,-17.9268]
      ]
   },
   "media_type":"TEXT",
   "start_datetime":"2021-10-28 11:59:00.000",
   "end_datetime":"2021-10-29 19:15:00.000",
   "bbox":[28.6095,-17.9387,28.6191,-17.9266]
}
```

This metadata file will be required later in this example. It will be used as input for [[the tool](https://iliad-registry.inesctec.pt/collections/aps/items/2stac)] that will output the results of the processing pipeline as a STAC Catalogue.


**NOTE**: Python version 3.10 or above is required to run this tool.


## The Python code for the tool

Create a _`WavyOcean.py`_ file. Copy the contents of the [`WavyOceanDataProcessing.ipynb`](files/WavyOceanDataProcessing.ipynb) notebook file to start editing the script.

The main function in our code will require 3 arguments which will be the inputs for the WavyOcean processing tool (constants in the notebook):
- OPERATION 
  - --op ->  the operation, i.e. eq (default), lt, gt, lte, gte, ne
- BASE_VALUE
  - --base -> the base value
- DATASET
  - --url -> the dataset URL
To define these inputs for the tool we will use  the _Click_ Package, just like in [HelloWorld Tutorial](../HelloWorld/README.md).

Install the _Click_ Package using pip:
```bash
pip install click
```

Edit `WavyOcean.py` to import click and define the options:

```python
import sys
import click
import urllib.request
import os
import csv
import json


@click.command()
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

With the above python file you should be able to execute with:

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


### The Dockerfile

Create a `Dockerfile` file with the instruction to create a Docker Image:

```docker
FROM python:alpine3.19

WORKDIR /opt

RUN pip install click

COPY WavyOcean.py /opt

CMD ["python", "/opt/WavyOcean.py",  "--help"]
```

### Build the Docker Image

Use the Docker CLI to build your meloa-wo-filter:0.1.0 Docker Image

Open a commandline in the same folder where you have the _`Dockerfile`_ and the _`WavyOcean.py`_ files and run:

```bash
docker build . -t meloa-wo-filter:0.1.0 --no-cache
```

### Run the Docker Image

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

### Upload the Docker Image to a Docker Repository

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

We've previouslly seen that the output of an Application Package pipeline should be a STAC catalogue document. We already found a tool thar receives as input a data file and a metadata file and builds the pipeline output as a STAC Catalogue. This tool is avaliable in the [ILIAD Registry](https://iliad-registry.inesctec.pt/collections/aps/items/2stac) and the [CWL is available in the ILIAD GITHUB](https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/2stac/2stac.cwl)

Create a _`WavyOcean-pipeline-010.cwl`_ file with the contents of both tools and the description of the pipeline:

```yml
- class: Workflow
  id: filter
  inputs:
    url:
      type: string
      doc: CSV endpoint
    base:
      type: float
      doc: baseline
    op:
      type: string?
      doc: operation
  steps:
    step_1:
      run: '#meloa-filter'
      in:
        url: url
        base: base
        op: op
      out:
      - results
      - metadata
    step_3:
      run: '#2stac'
      in:
        result: step_1/results
        metadata: step_1/metadata
      out:
      - results

  outputs:
  - id: wf_outputs
    outputSource:
    - step_3/results
    type:
      Directory

  s:softwareVersion: 0.1.0
  s:name: WO MELOA csv filter pipeline
  s:description: A pipeline to filter WO data and provide a STAC output
  s:keywords:
    - python
    - MELOA
    - Wavy Ocean
    - example pipeline
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Marco Oliveira
      s:email: marco.a.oliveira@inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/
  s:dateCreated: "2024-08-20"

- class: CommandLineTool
  baseCommand: python
  id: meloa-filter

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
  s:name: WO MELOA csv filter
  s:description: A tool to filter WO data
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

- class: CommandLineTool
  id: 2stac

  baseCommand: python
  arguments:
  - /opt/2stac.py
  - --result
  - valueFrom: $( inputs.result )
  - --metadata
  - valueFrom: $( inputs.metadata )

  inputs:
    result:
      type: File
      doc: The resulting file of the previous model to insert in STAC
      s:name: Input result file
      s:description: The resulting file of the previous model to insert in STAC
      s:keywords:
        - result
        - File
      s:fileFormat: "*/*"
    metadata:
      type: File
      doc: The resulting metadata of the previous model to insert in STAC
      s:name: Input metadata file
      s:description: The resulting metadata of the previous model to insert in STAC
      s:keywords:
        - metadata
        - File
      s:fileFormat: "application/json"

  outputs:
    results:
      outputBinding:
        glob: .
      type: Directory
      doc: STAC output

  requirements:
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac:2.0.0

  s:name: 2Stac
  s:softwareVersion: 2.0.0
  s:description: Transform the result into a STAC
  s:keywords:
    - stac
    - metadata
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository:
  s:dateCreated: "2024-08-20"
```
