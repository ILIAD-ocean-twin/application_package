cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/
schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf

$graph:
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
