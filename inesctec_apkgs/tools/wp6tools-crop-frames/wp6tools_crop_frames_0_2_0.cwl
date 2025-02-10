cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: CommandLineTool

  id: crop-frames

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
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0

  s:name: crop-frames
  s:description: crop frames from wp6-tools
  s:keywords:
    - wp6-tools
    - crop
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
    s:name: Alexandre Valle
    s:email: alexandre.valle@inesctec.pt
  s:contributor:
    class: s:Person
    s:name: Miguel Correia
    s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-crop-frames/wp6tools_crop_frames_0_2_0.cwl
  s:dateCreated: "2025-02-07T18:04:41Z"