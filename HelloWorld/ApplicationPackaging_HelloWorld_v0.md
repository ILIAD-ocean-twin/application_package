# Application Package HelloWold v0 Python Example

If you want to see what an Application Package without the _Click_ Package would look like, follow these instructions.

To create an application package you need to have the [Docker Engine](https://www.docker.com/) installed on your system. This tutorial is not intended to teach Docker, you can consult the [Docker Docs](https://docs.docker.com/) if you need further learning material.

## Application Package Software Container
An Application Package is a comprehensive collection of software, resources, and specifications bundled together, designed to distribute and execute specific data processing workflows. It ensures that the application can be easily distributed, installed and run in different computing environments. 
There are two main building blocks in an Application Package: Application Package Document and Application Package Container.
The Application Package uses Docker technology to implement the Application Package Container. A Docker container image is a lightweight, self-contained, executable software package that contains everything needed to run an application: code, runtime, system tools, system libraries, and settings.
The application is run as a command line interface (CLI) tool that runs as a non-interactive executable: it takes input arguments, performs a computation, and terminates after producing some output.

### The Dockerfile

Create a `Dockerfile` file with the instruction to create a Docker Image.
The file contents are: 

```docker
FROM python:alpine3.6

WORKDIR /opt

COPY HelloWorld_v0.py ./HelloWorld.py
```

### Build the Docker Image

Use the Docker CLI to build your helloworld:v0 Docker Image

Open a commandline in the same folder where you have the _Dockerfile_ and the _HelloWorld_v0.py_ files and run:
```bash
docker build . -t helloworld:0.0.0 --no-cache
```

### Upload the Docker Image to a Docker Repository

I've created a [repository for these HelloWorld container images on DockerHub](https://hub.docker.com/repository/docker/amarooliveira/helloworld/general) so, now I can tag them correctly and update this container image at the repository.

**NOTE:** If you have created your own repository at [DockerHub](https://hub.docker.com/), you may need to use [`docker login`](https://docs.docker.com/reference/cli/docker/login/) on the command line.

To update the image tag to include my repository name (_amarooliveria/helloworld_) I need to execute:
```bash
docker tag helloworld:0.0.0 amarooliveira/helloworld:0.0.0
```

Now that I have the correct name for my image I can update the image in the repository:
```bash
docker push amarooliveira/helloworld:0.0.0
```

## Describe the Application Package Tool

A Package that conforms to the Best Practice for Application Package must be a valid [CWL document](https://www.commonwl.org/) with a single _Workflow_ class and at least one _CommandLineTool_ class at the root level. These define the command line and associated arguments and container image for each CommandLineTool, the application parameters, the requirements for the runtime environment. 
The _Workflow_ class orchestrates the execution of the application command line and retrieves all the output of the processing _steps_.
An Application Package Document is an information model for aggregating the resources that contribute to a scientific work, including domain-specific annotations and provenance traces.

### The CWL Document
In an Application Package, the structure defined for a CWL document is composed of at least 2 classes, namely the _workflow_ class, which allows the definition of the parameters of the application, and an instance of the _commandLineTool_ class, which allows the description of tools or arguments.

>cwlVersion: v1.2
>
>$graph:
>- class: Workflow
>  id: hellowworld
>  ...
>
>- class: CommandLineTool
>  id: helloworld-tool
>  ...

### Application Package Metadata
To provide richer information about the Application Package, we use Schema.org metadata, which is defined globally within the _s:_ namespace tag in the CWL file. Schema.org metadata is a standardised set of tags used to provide structured information about web content. When applied to CWL, Schema.org metadata serves as a powerful tool for describing and organising various aspects of tools and workflows, making them discoverable, accessible and understandable. The examples show the metadata elements used.

### Describe the command-line Tool
A command line tool is a non-interactive executable program that reads some input, performs some computation, and terminates after producing some output.
The _CommandLineTool_ class defines the actual interface of the command line tool and its arguments according to the CWL _CommandLineTool_ standard.
The CWL explicitly supports the use of software container technologies, such as Docker or Singularity, to enable portability of the underlying analysis tools. The application package must explicitly provide the container requirements for each command line tool, defining the required container image.
The _DockerRequirement_ field indicates that the component should run in a container and specifies how to fetch the image. InlineJavascriptRequirement is a field that allows the manipulation of input parameters in CWL, which is used in the Inputs & Outputs bullet below.

To describe the Application Package Tool create a _`HelloWorld-tool-000.cwl`_ file with the following content:

```cwl
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/

$graph:
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
      dockerPull: amarooliveira/helloworld:0.0.0

  s:softwareVersion: 0.0.0
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

### How to describe an Application Package

If you intend to provide more than a too, then the CWL must also include the description of the _workflow_ class.

Create a _`HelloWorld-pipeline-000.cwl`_ file with the following content:

```cwl
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/

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

  requirements:
    DockerRequirement:
      dockerPull: amarooliveira/helloworld:0.0.0

  s:softwareVersion: 0.0.0
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
      dockerPull: amarooliveira/helloworld:0.0.0

  s:softwareVersion: 0.0.0
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

You may have noticed that an Application Package includes all the description of the Tools. The _`HelloWorld-pipeline-000.cwl`_ file contains all the _`HelloWorld-tool-000.cwl`_ file.

## Share the Application Package in the Iliad Registry

Both the Tools and the Pipelines can be share through an Application Package Registry. 

## Execute the Hello World Application Package

To execute the HelloWorld Application Package you need to have an execution environment for CWL installed, [you can find several available](https://www.commonwl.org/implementations/).

For presentation purposes I use [cwltool](https://github.com/common-workflow-language/cwltool) which [has packages for most distributions](https://github.com/common-workflow-language/cwltool#cwltool-packages).

To run the Application Package, all you need to have access is to the CWL file.
Find the CWL file location (not need to download), open a command-line on a system with CWL support, and execute:
```bash
cwltool https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/HelloWorld/files/HelloWorld-pipeline-020.cwl#hello_pipeline --name Marco
``` 
