cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: virtual-choreographies-cesium-plugin
  baseCommand: python
  arguments:
  - /opt/src/converter_cesium.py
  - valueFrom: $( inputs.vc )
  - valueFrom: $( inputs.mappings || inputs.mappings_url )

  inputs:
    vc:
     type: File
    mappings:
     type: File?
    mappings_url:
     type: string?
  outputs:
    platform_choreography:
      format: edam:format_3464 # JSON
      type: File
      outputBinding:
        glob: platform_choreography.json
        outputEval: ${self[0].basename="platform_choreography_cesium.json"; return self;}

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-cesium-plugin:0.1.0

  s:name: virtual-choreographies-cesium-plugin
  s:description: Generator of cesium inputs to virtual choreographies
  s:keywords:
    - wp6-tools
    - choreographies
    - virtual-choreographies
    - cesium
  s:programmingLanguage: python
  s:softwareVersion: 0.1.0
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
  s:codeRepository: 
  s:dateCreated: "2025-05-09T16:01:05Z"
