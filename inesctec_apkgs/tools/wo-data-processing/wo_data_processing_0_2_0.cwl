cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: wo-data-filter

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
      s:fileFormat: "text/csv"
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
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wo-data-processing:0.2.0

  s:name: wo-data-filter
  s:description: WO csv filter
  s:keywords:
    - meloa
    - wavy
    - ocean
    - dataset
    - filter
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
    s:name: Miguel Correia
    s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wo-data-processing/wo_data_processing_0_2_0.cwl
  s:dateCreated: "2025-02-07T17:50:21Z"