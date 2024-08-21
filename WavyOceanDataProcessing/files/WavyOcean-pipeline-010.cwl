cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: Workflow
  id: filter
  inputs:
    url:
      type: string
      doc: CSV endpoint
    base:
      type: float
      doc: baseline
    op:
      type: string?
      doc: operation
  steps:
    step_1:
      run: '#meloa-filter'
      in:
        url: url
        base: base
        op: op
      out:
      - results
      - metadata
    step_3:
      run: '#2stac'
      in:
        result: step_1/results
        metadata: step_1/metadata
      out:
      - results

  outputs:
  - id: wf_outputs
    outputSource:
    - step_3/results
    type:
      Directory

  s:softwareVersion: 0.1.0
  s:name: WO MELOA csv filter pipeline
  s:description: A pipeline to filter WO data and provide a STAC output
  s:keywords:
    - python
    - MELOA
    - Wavy Ocean
    - example pipeline
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Marco Oliveira
      s:email: marco.a.oliveira@inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/
  s:dateCreated: "2024-08-20"

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

- class: CommandLineTool
  id: 2stac

  baseCommand: python
  arguments:
  - /opt/2stac.py
  - --result
  - valueFrom: $( inputs.result )
  - --metadata
  - valueFrom: $( inputs.metadata )

  inputs:
    result:
      type: File
      doc: The resulting file of the previous model to insert in STAC
      s:name: Input result file
      s:description: The resulting file of the previous model to insert in STAC
      s:keywords:
        - result
        - File
      s:fileFormat: "*/*"
    metadata:
      type: File
      doc: The resulting metadata of the previous model to insert in STAC
      s:name: Input metadata file
      s:description: The resulting metadata of the previous model to insert in STAC
      s:keywords:
        - metadata
        - File
      s:fileFormat: "application/json"

  outputs:
    results:
      outputBinding:
        glob: .
      type: Directory
      doc: STAC output

  requirements:
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac:2.0.0

  s:name: 2Stac
  s:softwareVersion: 2.0.0
  s:description: Transform the result into a STAC
  s:keywords:
    - stac
    - metadata
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository:
  s:dateCreated: "2024-08-20"

s:softwareVersion: 0.1.0
s:name: WO MELOA csv filter
s:description: A pipeline to filter WO data and provide a STAC output