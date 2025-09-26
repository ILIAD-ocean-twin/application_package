cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: CommandLineTool

  id: extract_particles

  baseCommand: python
  arguments:
  - /opt/main.py
  - extract-particles
  - --input-url
  - valueFrom: $( inputs['input-file'] )
  - --output-format
  - valueFrom: $( inputs['output-format'] )
  - --projection-function
  - valueFrom: $( inputs['projection-function'] )
  - --projection-resolution
  - valueFrom: $( inputs['projection-resolution'] )
  - --latitude-variable
  - valueFrom: $( inputs['latitude-variable'] )
  - --longitude-variable
  - valueFrom: $( inputs["longitude-variable"] )
  - --time-variable
  - valueFrom: $( inputs["time-variable"] )

  - --output-url
  - output/particles

  inputs:
    input-file:
      type: File
    output-format:
      type: string
    projection-function:
      type: string
    projection-resolution:
      type: string
    latitude-variable:
      type: string
    longitude-variable:
      type: string
    time-variable:
      type: string

  outputs:
    result:
      type: Directory
      outputBinding:
        glob: output/particles

  requirements:
    NetworkAccess:
      networkAccess: true
    EnvVarRequirement:
      envDef:
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0

  s:name: extract_particles
  s:description: extract particles frames from wp6-tools
  s:keywords:
    - wp6-tools
    - extract
    - particles
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-extract-particles/wp6tools_extract_particles_0_2_0.cwl
  s:dateCreated: "2025-06-10T01:57:48Z"