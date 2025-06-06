# Application Package read-only file system Python Example

When the Application Package is executed, all the file system is read-only, except the `/tmp` and **$HOME**. The `$HOME` variable is set randomly just when the container is started, so it is not possible to know it in advance. To overcome this limitation, the following Python code can be used to create files in the writable directories:

**NOTE:** All bash commands should be executed on the [files](./files) directory

## Python Code

The Python code is a simple Hello World that writes a message to a file in the `/opt` directory.
Create a file [HelloWorld_v0.py](./files/HelloWorld_v0.py) with the following code:

```python
import sys
import logging

MODEL_NAME = "[HELLOWORLD]"

logging.basicConfig(
    stream=sys.stderr,
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)-8s %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)

def main():

    logging.info(f"{MODEL_NAME} Process started")
    message = (
        "Hello "
        + " from python "
        + str(sys.version_info[0])
        + "."
        + str(sys.version_info[1])
        + "."
        + str(sys.version_info[2])
        + "!\n"
    )
    result = "/opt/result.txt"
    f = open(result, "a")
    f.write(message)
    f.close()

    logging.info(f"{MODEL_NAME} result: {message}")
    logging.info(f"{MODEL_NAME} Process finished!")


if __name__ == "__main__":
    main()
```

## Docker

Create a [Dockerfile_v0](./files/Dockerfile_v0) file with the instruction to create a Docker Image.
The file contents are:

```docker
FROM python:alpine3.12

WORKDIR /opt

COPY HelloWorld_v0.py ./HelloWorld.py
COPY requirements.txt ./

RUN pip install -r requirements.txt

CMD ["python", "/opt/HelloWorld.py",  "--help"]
```

### Build the Docker Image

Use the Docker CLI to build your helloworld:v0 Docker Image

Open a commandline in the same folder where you have the _Dockerfile_ and the _HelloWorld_v0.py_ files and run:

```bash
docker build . -t helloworld:v0 -f Dockerfile_v0 --no-cache
```

### Run the Docker Image

To run the Docker Image, use the following command:

```bash
docker run helloworld:v0
```

#### Expected result

```
2025-02-13T12:01:52 INFO     [HELLOWORLD] Process started
2025-02-13T12:01:52 INFO     [HELLOWORLD] result: Hello from python 3.9.5!

2025-02-13T12:01:52 INFO     [HELLOWORLD] Process finished!
```

## CWL Document

Create a CWL document [HelloWorld-tool-000.cwl](./files/HelloWorld-tool-000.cwl) to describe the Application Package.

```yaml
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: CommandLineTool
  baseCommand: python
  id: hello_tool

  arguments:
    - /opt/HelloWorld.py

  stdout: output.txt

  inputs: []

  outputs:
    result:
    type: File
    outputBinding:
      glob: "result.txt"
    doc: result file

  requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: helloworld:v0

  s:softwareVersion: 0.0.0
  s:name: Hello World Example Tool Failing
  s:description: A python hello world example application package tool that writes a file to a read-only directory
  s:keywords:
    - python
    - hello world
    - example tool
  s:programmingLanguage: python
  s:producer:
    class: s:Organization
    s:name: INESCTEC
    s:url: https://inesctec.pt
    s:address:
      class: s:PostalAddress
      s:addressCountry: PT
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/
  s:dateCreated: '2025-02-13'
```

### Run Application Package

To run the Application Package, use the following command:

```bash
cwltool https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/HelloWorldFsReadOnly/files/HelloWorld-tool-000.cwl#hello_tool
```

or locally:

```bash
cwltool HelloWorld-tool-000.cwl#hello_tool
```

### Expected Output (FAIL)

The expected output is an error message like:

```
OSError: [Errno 30] Read-only file system: '/opt/result.txt'
```

This error message is expected because the `/opt` directory is read-only. So, the Python code cannot write the file.

## Run the Docker Image with read-only file system

To run the Docker Image with a read-only file system, use the following command:

```bash
docker run --read-only --tmpfs /tmp --tmpfs /kwhwj -e HOME='/kwhwj' -w /kwhwj helloworld:v0
```

#### Expected result

The expected output is an error message like:

```
OSError: [Errno 30] Read-only file system: '/opt/result.txt'
```

This error message is expected because the `/opt` directory is read-only. So, the Python code cannot write the file.

## Update Python Code

Update the HelloWorld Python code to write the file in the writable directories.

There are 2 possible writable directories:

1. `/tmp`
2. `$HOME` - where in cwltool is your working directory (`./`, `pwd`).

Create a file [HelloWorld_v1.py](./files/HelloWorld_v1.py) with the following code:

```python
import os
import sys
import logging

MODEL_NAME = "[HELLOWORLD]"

logging.basicConfig(
    stream=sys.stderr,
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)-8s %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)

def main():

    logging.info(f"{MODEL_NAME} Process started")
    message = (
        "Hello "
        + " from python "
        + str(sys.version_info[0])
        + "."
        + str(sys.version_info[1])
        + "."
        + str(sys.version_info[2])
        + "!\n"
    )

    # this is the writable directory ($HOME with cwltool)
    result = "result.txt"
    f = open(result, "a")
    f.write(message)
    f.close()

    # this is /tmp dir that is writable
    result = "/tmp/result.txt"
    f = open(result, "a")
    f.write(message)
    f.close()

    # this is $HOME dir that is writable
    result = f"/{os.environ['HOME']}/result.txt"
    f = open(result, "a")
    f.write(message)
    f.close()

    logging.info(f"{MODEL_NAME} result: {message}")
    logging.info(f"{MODEL_NAME} Process finished!")


if __name__ == "__main__":
    main()
```

## Update the Docker

Update the Dockerfile to use the new version of the Python code.
Create a file [Dockerfile_v1](./files/Dockerfile_v1) with the following code:

```docker
FROM python:alpine3.12

WORKDIR /opt

COPY HelloWorld_v1.py ./HelloWorld.py

CMD ["python", "/opt/HelloWorld.py",  "--help"]
```

### Build the new Docker Image

Use the Docker CLI to build your helloworld:v1 Docker Image

```bash
docker build . -t helloworld:v1 -f Dockerfile_v1 --no-cache
```

### Run the new Docker Image

To run the Docker Image, use the following command:

```bash
docker run --read-only --tmpfs /tmp --tmpfs /hudwga -e HOME='/hudwga' -w /hudwga helloworld:v1
```

### The expected result

```
2025-02-13T12:01:52 INFO     [HELLOWORLD] Process started
2025-02-13T12:01:52 INFO     [HELLOWORLD] result: Hello from python 3.9.5!

2025-02-13T12:01:52 INFO     [HELLOWORLD] Process finished!
```

**PS:** if you don't specify the `-w` parameter, the working directory will be `/opt` which is read-only.
When you define the `-w` parameter, you are saying to the container to use the writable directory as working directory.

So if you remove this, the run will fail because on the Python Code:

```python
# this is the writable directory (./ = $HOME)
result = "result.txt"
f = open(result, "a")
f.write(message)
f.close()
```

Your current directory will be `/opt` which is read-only.

## Update the CWL Document

Update the CWL document [HelloWorld-tool-001.cwl](./files/HelloWorld-tool-001.cwl) to execute the Docker Image with the new Python code.

```yaml
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: CommandLineTool
  baseCommand: python
  id: hello_tool

  arguments:
  - /opt/HelloWorld.py

  stdout: output.txt

  inputs: []

  outputs:
    result:
    type: File
    outputBinding:
      glob: "result.txt"
    doc: result file

  requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: helloworld:v1

  s:softwareVersion: 0.1.0
  s:name: Hello World Example Tool Working
  s:description: A python hello world example application package tool that writes a file to a writable directory
  s:keywords:
    - python
    - hello world
    - example tool
  s:programmingLanguage: python
  s:producer:
    class: s:Organization
    s:name: INESCTEC
    s:url: https://inesctec.pt
    s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/
  s:dateCreated: "2025-02-13"
```

### Run the new Application Package

To run the Application Package, use the following command:

```bash
cwltool https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/HelloWorldFsReadOnly/files/HelloWorld-tool-001.cwl#hello_tool
```

or locally:

```bash
cwltool HelloWorld-tool-001.cwl#hello_tool
```

## Notes
1. You can use the docker image from our repository by changing the `dockerPull` parameter in the CWL document:

```yaml
requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: helloworld:v0
```

to:

```yaml
requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: iliad-repository.inesctec.pt/helloworld:v0
```