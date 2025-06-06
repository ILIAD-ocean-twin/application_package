cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: CommandLineTool

  id: point2bbox

  baseCommand: python
  arguments:
  - /opt/point2bbox.py
  - --lat
  - valueFrom: $( inputs.lat )
  - --lon
  - valueFrom: $( inputs.lon )
  - --radius
  - valueFrom: $( inputs.radius )

  inputs:
    lat:
      type: float
      doc: Latitude
    lon:
      type: float
      doc: Longitude
    radius:
      type: float
      doc: Radius

  outputs:
    lon_min:
      type: float
    lon_max:
      type: float
    lat_min:
      type: float
    lat_max:
      type: float


  requirements:
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/point2bbox:0.1.0

  s:name: point2bbox
  s:description: Convert a point and radius to a bounding box
  s:keywords:
    - point2bbox
  s:programmingLanguage: python
  s:softwareVersion: 0.1.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/point2bbox/point2bbox_0_1_0.cwl
  s:dateCreated: "2025-05-12T12:37:42Z"