cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: virtual_choreographies_generator

  baseCommand: python
  arguments:
  - /opt/src/command.py
  - valueFrom: $( inputs.dataset )
  - valueFrom: $( inputs.template || inputs.template_url || '/opt/templates/template.json')

  inputs:
    template:
     type: File?
    template_url:
     type: string?
    dataset:
     type: File
  outputs:
    vc:
      format: edam:format_3464 # JSON
      type: File
      outputBinding:
        glob: vc.json
    recipe:
      format: edam:format_3464 # JSON
      type: File
      outputBinding:
        glob: recipe.json

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-generator:0.3.0

  s:name: virtual_choreographies_generator
  s:description: Generator of virtual choreographies
  s:keywords:
    - wp6-tools
    - choreographies
    - virtual-choreographies
  s:programmingLanguage: python
  s:softwareVersion: 0.3.0
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
      s:name: Fernando Cassola
      s:email: fernando.c.marques@inesctec.pt
    - class: s:Person
      s:name: Vitor Cavaleiro
      s:email: vitor.cavaleiro@inesctec.pt
  s:maintainer:
    - class: s:Person
      s:name: Vitor Cavaleiro
      s:email: vitor.cavaleiro@inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-generator/virtual_choreographies_generator_0_3_0.cwl
  s:dateCreated: "2025-06-10T00:22:25Z"
