cwlVersion: v1.2

$namespaces:
  s: https://schema.org/SoftwareApplication
  edam: http://edamontology.org/

$graph:

- class: CommandLineTool

  id: generate-model

  baseCommand: python
  arguments:
  - /opt/main.py
  - generate-model
  - --type
  - valueFrom: $( inputs.type )
  - --url
  - valueFrom: $( inputs.url )
  - --latitude
  - valueFrom: $( inputs.latitude )
  - --longitude
  - valueFrom: $( inputs.longitude )
  - --radius
  - valueFrom: $( inputs.radius )
  - --samples
  - valueFrom: $( inputs.samples )
  - --time
  - valueFrom: $( inputs.time )
  - --minutes
  - valueFrom: $( inputs.minutes )
  - valueFrom: $(
      function () {
        if (inputs["output-animation"]) {
            return ["--output-animation", "true"];
        } else {
            return [];
        }
      }())
  - valueFrom: $(
      function () {
            return ["--depth", inputs["depth"]];
      }())
  - --output-url
  - output/oceandrift.nc

  inputs:
    type:
      type: string
    url:
      type: string
    latitude:
      type: float
    longitude:
      type: float
    radius:
      type: float
    samples:
      type: string
    time:
      type: string
    minutes:
      type: string
    output-animation:
      type: boolean?
    depth:
      type: float?
      default: 0.0

  outputs:
    result:
      format: edam:format_3650 # NetCDF
      type: File
      outputBinding:
        glob: output/oceandrift.nc
    animation:
      format: edam:format_3467 # GIF
      type: File?
      outputBinding:
        glob: output/animation.gif

  requirements:
    NetworkAccess:
      networkAccess: true
    EnvVarRequirement:
      envDef:
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.2

  s:name: generate-model
  s:description: generate model frames from wp6-tools
  s:keywords:
    - wp6-tools
    - model
  s:programmingLanguage: python
  s:softwareVersion: 0.1.2
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-model/wp6tools_generate_model_0_1_2.cwl
  s:dateCreated: "2025-05-20T17:09:37Z"