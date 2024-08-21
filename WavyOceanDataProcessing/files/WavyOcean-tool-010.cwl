cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: CommandLineTool
  baseCommand: python
  id: meloa-filter

  arguments:
  - /opt/WavyOcean.py
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
      doc: CSV dataset endpoint
    base:
      type: float
      doc: base value
    op:
      type: string?
      doc: operation to filter
      default: "gt"

  outputs:
    results:
      type: File
      outputBinding:
        glob: "result/result.csv"
      doc: result file
      s:fileFormat: "text/csv"
    metadata:
      type: File
      outputBinding:
        glob: "result/metadata.json"
      doc: metadata description
      s:fileFormat: "application/json"

  requirements:
    ResourceRequirement: {}
    NetworkAccess:
      networkAccess: true
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: meloa-wo-filter:0.1.0

  s:softwareVersion: 0.1.0
  s:name: WO MELOA csv filter
  s:description: A tool to filter WO data
  s:keywords:
    - python
    - wavy
    - meloa
    - ocean
    - data processing
    - example tool
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Marco Oliveira
      s:email: marco.a.oliveira@inesctec.pt
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/
  s:dateCreated: "2024-08-20"

s:softwareVersion: 0.1.0
s:name: WO MELOA csv filter
s:description: A tool to filter WO data