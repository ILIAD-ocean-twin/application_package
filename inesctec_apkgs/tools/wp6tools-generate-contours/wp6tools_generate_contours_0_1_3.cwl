cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: CommandLineTool

  id: generate-contours

  baseCommand: python
  arguments:
  - /opt/main.py
  - generate-contours-at-density
  - --input-url
  - valueFrom: $( inputs['cropped'])
  - --input-format
  - stac
  # - valueFrom: $( inputs['input-format'] )
  - --output-format
  - valueFrom: $( inputs['output-format'] )
  - --density
  - valueFrom: $( inputs['density'] )

  - --output-url
  - output/contours

  inputs:
    cropped:
      type: Directory
    # input-format:
    #   type: string
    output-format:
      type: string
      default: json
    density:
      type: string


  outputs:
    result:
      type: Directory
      outputBinding:
        glob: output/contours

  requirements:
    NetworkAccess:
      networkAccess: true
    EnvVarRequirement:
      envDef:
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.3

  s:name: generate-contours
  s:description: generate contours frames from wp6-tools
  s:keywords:
    - wp6-tools
    - contours
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
      s:name: Alexandre Valle
      s:email: alexandre.valle@inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-contours/wp6tools_generate_contours_0_1_3.cwl
  s:dateCreated: "2025-05-20T17:18:29Z"