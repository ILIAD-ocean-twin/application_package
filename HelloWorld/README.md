# Application Packaging Best practices Tutorial (Hello World)

In this tutorial we aim to show the practice on preparing an Application Package Tool with a Hello World python example. 
It will run in a machine that has no python installed. All the required dependencies are embeded in the Application Package Tool.

## Our initial Hello World python example

Create a [`HelloWorld_v0.py`](files/HelloWorld_v0.py) file. The hello world python example (with no specific dependencies) should have the following content: 

```python
import sys

def main(args=sys.argv):

    if len(args) < 2:
        print("Please provide a name as an argument.")
        return
    
    message = (
        "Hello "
        + args[1]
        + " from python "
        + str(sys.version_info[0])
        + "."
        + str(sys.version_info[1])
        + "."
        + str(sys.version_info[2])
        + "!\n"
    )
    print(message)

if __name__ == "__main__":
    main()
```

This code expects one argument with a _name_. It will print either a message welcoming the user or a message requesting the _name_ argument for execution.

it can be run with :
```bash
python3 helloworld_v0.py Marco  
```

which will print a message in the console like:

> Hello Marco from python 3.9.6!

## Improve the CLI API of our Hello Word Python Example

[Click](https://click.palletsprojects.com/) is a Python package for easy and quick creation of command line interfaces (CLI).

We will use it to validate required argument and automate the creation of an help page for our example. 

### Install dependency

You can add the dependency to your project using pip:
```bash
pip install click
```
Alternativelly you can use the provided [_requirements.txt_](files/original/requirements.txt) file with:
```bash
pip install -r requirements.txt
``` 

### Update Hello World python code

We will add the argument _--name_ (also accept _-n_) to our Hello World CLI API. The option _--help_ is automatically added by the _Click_ Package.

Update your code to use the _Click_ Package. Copy `HelloWorld_v0.py` to `HelloWorld_v1.py` and edit:

```python
import sys
import click

@click.command()
@click.option("--name", "-n", "name", help="name", required=True)
def main(name):

    message = (
        "Hello "
        + name
        + " from python "
        + str(sys.version_info[0])
        + "."
        + str(sys.version_info[1])
        + "."
        + str(sys.version_info[2])
        + "!\n"
    )
    print(message)


if __name__ == "__main__":
    main()
```

A function becomes a Click command line tool by decorating it through [`click.command()`](https://click.palletsprojects.com/api/#click.command). At its simplest, just decorating a function with this decorator will make it into a callable script but you can add parameters, using the [`click.option()`](https://click.palletsprojects.com/api/#click.option) (and [`click.argument()`](https://click.palletsprojects.com/api/#click.argument)) function decorators.

With the above update you should change your code execution call with:
```bash
python3 helloworld_v1.py --name Marco
```
which will print a message in the console like:

> Hello Marco from python 3.9.6!

You now also have a _--help_ option:
```bash
python3 HelloWorld_v1.py --help
```

which returns:
>Usage: HelloWorld_v1.py [OPTIONS]
>
>Options:
>  -n, --name TEXT  name  [required]
>  --help           Show this message and exit.


Now this last version of the code cannot be run in a python setup without the  _Click_ package requirement, otherwise you get:
>Traceback (most recent call last):
>  File "HelloWorld_v1.py", line 2, in <module>
>    import click
>ModuleNotFoundError: No module named 'click'


## Application Packaging the HelloWorld Tool

To ensure that this tool can be run everywhere, we will follow the Application Packaging best practices with Application containerization and CWL tool description.

For Application Packaging you will need [Docker Engine](https://www.docker.com/) installed in your system. This tutorial is not aimed at teaching Docker, you can consult [Docker Docs](https://docs.docker.com/) if you need further learning materials

An Application Package provides the best practices for a Software engineer to adapt, build, describe and share a portable representation of a processing workflow. It can containerize the complete or individual steps of a processing pipeline, and should be sufficiently described, e.g., inputs, outputs, and spatial and temporal validity.
In an Application Package, the tools should be prepared to be called for execution by passing a set of known parameters and expect the resulting output to be imputed to the next step of a processing pipeline, or to be available for the caller. 
The Application Package is composed of two artifacts – a Docker container image and a CWL document.

Current version of our Hello World python example isn't outputing a file thus, if we build an Application Package Tool we might not be able to pass the tools output into an input of the tool in the following step of the pipeline.

Lets update the code to write to a file instead of to the console. Copy `HelloWorld_v1.py` to `HelloWorld_v2.py` and edit:

```python
import sys
import click

@click.command()
@click.option("--name", "-n", "name", help="name", required=True)
def main(name):

    message = (
        "Hello "
        + name
        + " from python "
        + str(sys.version_info[0])
        + "."
        + str(sys.version_info[1])
        + "."
        + str(sys.version_info[2])
        + "!\n"
    )
    result = "result.txt"
    f = open(result, "w")
    f.write(message)
    f.close()

if __name__ == "__main__":
    main()
```

Now we have a Hello World version whose output is a text file with the same content as the console output in previous versions.

**NOTE**: A complete version of the HelloWorld example (wich also includes [logging](https://docs.python.org/3/library/logging.html)) is available in the github repository: [HelloWorld_v3.py](./files/HelloWorld_v3.py)

**NOTE**: It is also possible to write a CWL that outputs the process standard output as a file, you can see how in the [Application Packaging for HelloWorld_v0.py version of this tutorial](./ApplicationPackaging_HelloWorld_v0.md)

### Application package software container
An Application Package refers to a comprehensive collection of software, resources, and specifications bundled together, designed to distribute and execute specific data processing workflows. It ensures the application's easy distribution, installation, and execution across various computing environments. 
Two main building blocks exist in an Application Package: Application Package Document and Application Package Container.
The Application Package leverages on Docker technology for implementing the Application Package Container. A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings.
The Application is executed as a command-line interface (CLI) tool that runs as a non-interactive executable program: it receives input arguments, performs a computation, and terminates after producing some output.

#### The Dockerfile

Create a `Dockerfile_v2` file with the instruction to create a Docker Image.
The file contents are: 

```docker
FROM python:alpine3.12

WORKDIR /opt

COPY HelloWorld_v2.py ./HelloWorld.py
COPY requirements.txt ./

RUN pip install -r requirements.txt

CMD ["python", "/opt/HelloWorld.py",  "--help"]
```

#### Build the Docker Image

Use the Docker CLI to build your helloworld:v0 Docker Image

Open a commandline in the same folder where you have the _`Dockerfile_v2`_ and the _`HelloWorld_v2.py`_ files and run:
```bash
docker build . -f Dockerfile_v2 -t helloworld:0.2.0 --no-cache
```
#### Run the Docker Image

To test run the docker image we created just type on the command-line:

```bash
docker run helloworld:0.2.0
```

And you will get a response from the application help as seen before:

>Usage: HelloWorld.py [OPTIONS]
>
>Options:
>  -n, --name TEXT  name  [required]
>  --help           Show this message and exit.

To execute the python code we added to the docker image type on the command-line:

```bash
docker run -v ./result:/opt/result helloworld:0.2.0 sh -c "python /opt/HelloWorld.py -n Marco && cp /opt/result.txt /opt/result/result.txt"
```
This command is slightly more complex but will not be required again. We need it to ensure we have our code working as expected. It will create the _`./result/result.txt`_ file with the following content:

>Hello Marco from python 3.9.5!

#### Upload the Docker Image to a Docker Repository

I've created a [repository for these HelloWorld container images at DockerHub](https://hub.docker.com/repository/docker/amarooliveira/helloworld/general) so, now I can tag them correctly and update this container image at the repository.

**NOTE:** If you created your own repository at [Docker Hub](https://hub.docker.com/) you may need to [`docker login`](https://docs.docker.com/reference/cli/docker/login/) on the command-line.

To update the image tag to include my repository name (_amarooliveria/helloworld_) I need to execute:
```bash
docker tag helloworld:0.2.0 amarooliveira/helloworld:0.2.0
```

Now that I have the correct name for my image I can update the image in the repository:
```bash
docker push amarooliveira/helloworld:0.2.0
```

## Describe the Application Package Tool

A Package that complies with the Best Practice for Application Package needs to be a valid [CWL document](https://www.commonwl.org/) with a single _Workflow_ Class and at least one _CommandLineTool_ Class at the root level, to define the command-line and respective arguments and container image for each CommandLineTool, to define the Application parameters, to define the requirements for runtime environment. 
The _Workflow_ class orchestrates the execution of the application command line and retrieves all the outputs of the processing _steps_.
An Application Package Document is an information model for aggregating the resources that contribute to a scientific work, including domain-specific annotations and provenance traces.

### The CWL Document
In an Application Package, the structure that is defined for a CWL document is composed of at least 2 classes, respectively the class _workflow_ that allows for the definition of parameters of the application, and an instance of the class _commandLineTool_ that enables the description of tools and respectively arguments.

>cwlVersion: v1.2
>
>$graph:
>- class: Workflow
>  id: hello_pipeline
>  ...
>
>- class: CommandLineTool
>  id: hello_tool
>  ...

### Application Package Metadata
To provide richer informations on the Application Package we use Schema.org metadata, which is globally defined within the _s:_ namespace tag in the CWL file. Schema.org metadata provides a standardised set of tags used to provide structured information about web content. When applied to CWL, Schema.org metadata serves as a powerful tool for describing and organising various aspects of tools and workflows, making them discoverable, accessible, and understandable. In the examples you can see the metadata elements that are being used.

### Describe the command-line Tool
A command-line tool is a non-interactive executable program that reads some input, performs a computation, and terminates after producing some output.
The _CommandLineTool_ class defines the actual interface of the command-line tool and its arguments according to the CWL _CommandLineTool_ standard.
The CWL explicitly supports the use of software container technologies, such as Docker or Singularity, to enable the portability of the underlying analysis tools. The Application Package needs to explicitly provide for each command-line tool the container requirements defining the container image needed.
The field _DockerRequirement_ indicates that the component should be run in a container and specifies how to fetch the image. InlineJavascriptRequirement is a field that enables the manipulation of input parameters in CWL, which is used in the Inputs & Outputs bullet below.

To describe the Application Package Tool create a _`HelloWorld-tool-020.cwl`_ file with the following content:

```cwl
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: CommandLineTool
  baseCommand: python
  id: hello_tool

  arguments:
  - /opt/HelloWorld.py
  - --name
  - valueFrom: $( inputs.name )
  
  inputs:
    name:
      type: string
      doc: the name to greet

  outputs:
    result:
      type: file
      outputBinding:
        glob: "result.txt"
      doc: result file
      s:fileFormat: "text/plain"

  requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: amarooliveira/helloworld:0.2.0

  s:softwareVersion: 0.2.0
  s:name: Hello World Example Tool
  s:description: A python hello world example application package tool
  s:keywords:
    - python
    - hello world
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

Create a _`HelloWorld-pipeline-020.cwl`_ file with the following content:

```cwl
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: Workflow
  id: hello_pipeline
  doc: A single step pipeline that uses the helloworld tool

  inputs:
    name:
      type: string
      doc: the name to greet
  
  steps:
    hello:
      run: '#hello_tool'
      in: 
        name: name
      out:
        result

  outputs:
  - id: result
    outputSource:
    - hello/result
    type: File
    s:fileFormat: "text/plain"

  s:softwareVersion: 0.2.0
  s:name: Hello World Example
  s:description: A python hello world example application package
  s:keywords:
    - python
    - hello world
    - example
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
  baseCommand: python
  id: hello_tool

  arguments:
  - /opt/HelloWorld.py
  - valueFrom: $( inputs.name )

  stdout: output.txt
  
  inputs:
    name:
      type: string
      doc: the name to greet

  outputs:
    result:
      type: stdout

  requirements:
    DockerRequirement:
      dockerPull: amarooliveira/helloworld:0.2.0

  s:softwareVersion: 0.2.0
  s:name: Hello World Example Tool
  s:description: A python hello world example application package tool
  s:keywords:
    - python
    - hello world
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

You may have noticed that an Application Package includes all the description of the Tools. The _`HelloWorld-pipeline-020.cwl`_ file contains all the tool description of _`HelloWorld-tool-020.cwl`_ file.

## Share the Application Package in the Iliad Registry

Both the Tools and the Pipelines can be shared in an [Application Package Registry](https://iliad-registry.inesctec.pt/).

## Execute the Hello World Application Package

To execute the HelloWorld Application Package you need to have an execution environment for CWL installed, [you can find several available](https://www.commonwl.org/implementations/).

For presentation purposes I use [cwltool](https://github.com/common-workflow-language/cwltool) which [has packages for most distributions](https://github.com/common-workflow-language/cwltool#cwltool-packages).

To run the Application Package, all you need to have access is to the CWL file.
Find the CWL file location (not need to download), open a command-line on a system with CWL support, and execute:
```bash
cwltool https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/HelloWorld/files/HelloWorld-pipeline-000.cwl#hello_pipeline --name Marco
``` 

The execution and the outputs will be coherent independently of where you run it.