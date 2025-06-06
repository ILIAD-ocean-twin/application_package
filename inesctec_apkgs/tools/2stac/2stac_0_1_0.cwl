cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

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
    metadata:
      format: edam:format_3464 # JSON
      type: File
      doc: The resulting metadata of the previous model to insert in STAC

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
      dockerPull: iliad-repository.inesctec.pt/2stac:0.1.0

  s:name: 2stac
  s:softwareVersion: 0.1.0
  s:description: Transform the result into a STAC
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac/2stac_0_1_0.cwl
  s:dateCreated: "2025-05-12T11:18:01Z"
