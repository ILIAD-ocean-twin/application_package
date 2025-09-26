cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:

- class: CommandLineTool

  id: metadata-2stact2

  baseCommand: python
  arguments:
  - /opt/main.py
  - metadata-2stac2
  - --latitude
  - valueFrom: $( inputs.latitude )
  - --longitude
  - valueFrom: $( inputs.longitude )
  - --radius
  - valueFrom: $( inputs.radius )
  - --time
  - valueFrom: $( inputs.time )
  - --frames
  - valueFrom: $( inputs.frames )
  - --output-url
  - output/metadata.json

  inputs:
    latitude:
      type: float
    longitude:
      type: float
    radius:
      type: float
    time:
      type: string
    frames:
      type: string

  outputs:
    result:
      format: edam:format_3464 # JSON
      type: File
      outputBinding:
        glob: output/metadata.json

  requirements:
    EnvVarRequirement:
      envDef:
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.3

  s:name: metadata-2stact2
  s:description: generate metadata from wp6-tools to the 2stac2
  s:keywords:
    - wp6-tools
    - metadata
    - 2stac2
  s:programmingLanguage: python
  s:softwareVersion: 0.1.3
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-metadata-2stac2/wp6tools_metadata_2stac2_0_1_3.cwl
  s:dateCreated: "2025-05-20T17:18:29Z"