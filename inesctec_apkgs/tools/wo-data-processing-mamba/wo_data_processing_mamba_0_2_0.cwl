cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: wo_data_filter_mamba

  baseCommand: python
  arguments:
  - /opt/script.py
  - --url
  - valueFrom: $( inputs.url )
  - --base
  - valueFrom: $( inputs.base )
  - valueFrom: $(
      function () {
        if (inputs.op) {
          return ["--op", inputs.op];
        } else {
          return [];
        }
      }())
  inputs:
    url:
      type: string
      doc: CSV endpoint
    base:
      type: float
      doc: baseline
    op:
      type: string?
      doc: operation to apply
      default: "gt"

  outputs:
    results:
      format: edam:format_3752 # CSV
      type: File
      outputBinding:
        glob: "result/result.csv"
      doc: result file
    metadata:
      format: edam:format_3464 # JSON
      type: File
      outputBinding:
        glob: "result/metadata.json"
      doc: metadata description

  requirements:
    ResourceRequirement: {}
    NetworkAccess:
      networkAccess: true
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef:
        PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wo-data-processing-mamba:0.2.0

  s:name: wo_data_filter_mamba
  s:description: WO csv filter
  s:keywords:
    - meloa
    - wavy
    - ocean
    - dataset
    - filter
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
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wo-data-processing-mamba/wo_data_processing_mamba_0_2_0.cwl
  s:dateCreated: "2025-06-09T21:09:34Z"