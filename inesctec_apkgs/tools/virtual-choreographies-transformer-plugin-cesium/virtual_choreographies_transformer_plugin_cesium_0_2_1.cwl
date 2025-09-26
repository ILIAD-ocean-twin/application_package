cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: virtual-choreographies-transformer-plugin-cesium
  baseCommand: python
  arguments:
  - /opt/src/command.py
  - valueFrom: $( inputs.vc )
  - valueFrom: $( inputs.mappings || inputs.mappings_url || '/opt/mappings/cesium.j2' )
  - valueFrom: $( inputs.vc_recipe || inputs.vc_recipe_url)
  - valueFrom: $( inputs.platform_recipe || inputs.platform_recipe_url || '/opt/recipes/platform_recipe_cesium.json')

  inputs:
    vc:
     type: File
    mappings:
     type: File?
    mappings_url:
     type: string?
    vc_recipe:
      type: File?
    vc_recipe_url:
      type: File?
    platform_recipe:
      type: File?
    platform_recipe_url:
      type: File?
  outputs:
    platform_choreography:
      format: edam:format_3464 # JSON
      type: File
      outputBinding:
        glob: result/platform_choreography.json
        outputEval: ${self[0].basename="platform_choreography_cesium.json"; return self;}

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-transformer-plugin:0.2.1

  s:name: virtual-choreographies-transformer-plugin-cesium
  s:description: Generator of platform specific choregoraphies form generic virtual choreographies
  s:keywords:
    - wp6-tools
    - choreographies
    - virtual-choreographies
    - transformer
  s:programmingLanguage: python
  s:softwareVersion: 0.2.1
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-cesium/virtual_choreographies_transformer_plugin_cesium_0_2_1.cwl
  s:dateCreated: "2025-05-26T10:06:27Z"