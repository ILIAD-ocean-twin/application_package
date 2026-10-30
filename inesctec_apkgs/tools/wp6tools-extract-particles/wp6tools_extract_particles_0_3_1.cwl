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
  - valueFrom: $( inputs["no-invert-longitude"] ? "--no-invert-longitude":[] )
  - --output-url
  - output/particles

  inputs:
    input-file:
      type: File
    output-format:
      type: string
      default: "stac"
    projection-function:
      type: string
      default: "none"
    projection-resolution:
      type: string
      default: "none"
    latitude-variable:
      type: string
      default: "lat"
    longitude-variable:
      type: string
      default: "lon"
    time-variable:
      type: string
      default: "time"
    no-invert-longitude:
      type: boolean
      default: false

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
        PATH: /.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.3.1

  s:name: extract_particles
  s:description: extract particles frames from wp6-tools
  s:keywords:
    - wp6-tools
    - extract
    - particles
  s:programmingLanguage: python
  s:softwareVersion: 0.3.1
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
  s:dateCreated: "2026-04-30T13:42:41Z"
