cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: virtual-choreographies-generator

  baseCommand: python
  arguments:
  - /opt/src/vc_generator.py
  - valueFrom: $( inputs.dataset )
  - valueFrom: $( inputs.template || inputs.template_url )

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

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-generator:0.2.0

  s:name: virtual-choreographies-generator
  s:description: Generator of virtual choreographies
  s:keywords:
    - wp6-tools
    - choreographies
    - virtual-choreographies
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
  s:sourceOrganization:
    class: s:Organization
    s:name: INESCTEC
    s:url: https://inesctec.pt
    s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:contributor:
    class: s:Person
    s:name: Miguel Correia
    s:email: miguel.r.correia@inesctec.pt
  s:author:
    class: s:Person
    s:name: Fernando Cassola
    s:email: fernando.c.marques@inesctec.pt
  s:mantainer:
    class: s:Person
    s:name: Vitor Cavaleiro
    s:email: up202004724@edu.fe.up.pt
  s:codeRepository: 
  s:dateCreated: "2025-02-07T17:42:52Z"
