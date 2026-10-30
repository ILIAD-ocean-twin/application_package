cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: CommandLineTool

  id: crop_frames

  baseCommand: python
  arguments:
  - /opt/main.py
  - crop-frames
  - --input-url
  - valueFrom: $( inputs['particles'])
  - --input-format
  - stac
  # - valueFrom: $( inputs['input-format'] )
  - --frames
  - valueFrom: $( inputs['frames'] )

  - --output-url
  - output/cropped

  inputs:
    particles:
      type: Directory
    # input-format:
    #   type: string
    frames:
      type: string


  outputs:
    result:
      type: Directory
      outputBinding:
        glob: output/cropped

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

  s:name: crop_frames
  s:description: crop frames from wp6-tools
  s:keywords:
    - wp6-tools
    - crop
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
