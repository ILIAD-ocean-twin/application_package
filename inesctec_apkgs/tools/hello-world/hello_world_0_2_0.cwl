cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: CommandLineTool

  id: helloworld

  baseCommand: python
  arguments:
  - /opt/helloworld.py
  - valueFrom: $( inputs.name )

  inputs:
    name:
      type: string
      doc: Some keyword

  outputs:
    result:
      type: File
      outputBinding:
        glob: "result.txt"
      doc: result file

  requirements:
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/hello-world:0.2.0

  s:name: helloworld
  s:description: Hello World example
  s:keywords:
    - helloworld
    - example
    - simple
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
  s:sourceOrganization:
    class: s:Organization
    s:name: INESCTEC
    s:url: https://inesctec.pt
    s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:author:
    class: s:Person
    s:name: Miguel Correia
    s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/hello-world/hello_world_0_2_0.cwl
  s:dateCreated: "2025-02-07T18:24:16Z"
