cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: stac_simulation

  baseCommand: python
  arguments:
  - /opt/simulate.py
  - valueFrom: "$(inputs.something)"
    prefix: "--something"
  # - valueFrom: $( inputs.something ? ['--something', inputs.something]:[] )

  inputs:
    something:
      type:
        - File?
        - File[]?
        - string?
  outputs:
    results:
      outputBinding:
        glob: .
      type: Directory
      doc: STAC output

  requirements:
    MultipleInputFeatureRequirement: {}
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/stac-simulation:0.1.1

  s:name: stac_simulation
  s:softwareVersion: 0.1.1
  s:description: Simulates a STAC result
  s:keywords:
    - stac
    - metadata
  s:programmingLanguage: python
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
  s:dateCreated: "2025-11-13T21:55:20Z"
