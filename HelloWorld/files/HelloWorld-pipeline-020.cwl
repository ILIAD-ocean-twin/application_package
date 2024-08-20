cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: Workflow
  id: hello_pipeline

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
      - result

  outputs:
    - id: results
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
  - --name
  - valueFrom: $( inputs.name )
  
  inputs:
    name:
      type: string
      doc: the name to greet

  outputs:
    result:
      type: File
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