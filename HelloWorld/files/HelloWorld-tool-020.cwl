cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

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
      format: edam:data_3671 # Plain text
      type: File
      outputBinding:
        glob: "result.txt"
      doc: result file

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
  s:contributor:
    - class: s:Person
      s:name: Marco Oliveira
      s:email: marco.a.oliveira@inesctec.pt
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/
  s:dateCreated: "2024-08-20"

s:softwareVersion: 0.2.0
s:name: Hello World Example Tool
s:description: A python hello world example application package tool