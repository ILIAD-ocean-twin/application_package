# Application Packaging HelloWold v0 python example

If you want to see how an application package withouth the _Click_ Package would be like, follow this instruction.

To create an Application Package you will need to have [Docker Engine](https://www.docker.com/) installed in your system. This tutorial is not aimed at teaching Docker, you can consult [Docker Docs](https://docs.docker.com/) if you need further learning materials

## Application package software container
An Application Package refers to a comprehensive collection of software, resources, and specifications bundled together, designed to distribute and execute specific data processing workflows. It ensures the application's easy distribution, installation, and execution across various computing environments. 
Two main building blocks exist in an Application Package: Application Package Document and Application Package Container.
The Application Package leverages on Docker technology for implementing the Application Package Container. A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings.
The Application is executed as a command-line interface (CLI) tool that runs as a non-interactive executable program: it receives input arguments, performs a computation, and terminates after producing some output.

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

I've created a [repository for these HelloWorld container images at DockerHub](https://hub.docker.com/repository/docker/amarooliveira/helloworld/general) so, now I can tag them correctly and update this container image at the repository.

**NOTE:** If you created your own repository at [Docker Hub](https://hub.docker.com/) you may need to [`docker login`](https://docs.docker.com/reference/cli/docker/login/) on the command-line.

To update the image tag to include my repository name (_amarooliveria/helloworld_) I need to execute:
```bash
docker tag helloworld:0.0.0 amarooliveira/helloworld:0.0.0
```

Now that I have the correct name for my image I can update the image in the repository:
```bash
docker push amarooliveira/helloworld:0.0.0
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
>  id: hellowworld
>  ...
>
>- class: CommandLineTool
>  id: helloworld-tool
>  ...

### Application Package Metadata
To provide richer informations on the Application Package we use Schema.org metadata, which is globally defined within the _s:_ namespace tag in the CWL file. Schema.org metadata provides a standardised set of tags used to provide structured information about web content. When applied to CWL, Schema.org metadata serves as a powerful tool for describing and organising various aspects of tools and workflows, making them discoverable, accessible, and understandable. In the examples you can see the metadata elements that are being used.

### Describe the command-line Tool
A command-line tool is a non-interactive executable program that reads some input, performs a computation, and terminates after producing some output.
The _CommandLineTool_ class defines the actual interface of the command-line tool and its arguments according to the CWL _CommandLineTool_ standard.
The CWL explicitly supports the use of software container technologies, such as Docker or Singularity, to enable the portability of the underlying analysis tools. The Application Package needs to explicitly provide for each command-line tool the container requirements defining the container image needed.
The field _DockerRequirement_ indicates that the component should be run in a container and specifies how to fetch the image. InlineJavascriptRequirement is a field that enables the manipulation of input parameters in CWL, which is used in the Inputs & Outputs bullet below.

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
cwltool https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/HelloWorld/files/HelloWorld-pipeline-000.cwl#hello_pipeline --name Marco
``` 
