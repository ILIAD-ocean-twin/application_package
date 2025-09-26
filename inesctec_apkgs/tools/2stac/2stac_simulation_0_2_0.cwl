cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:

- class: CommandLineTool

  id: 2stac_simulation

  baseCommand: python
  arguments:
  - /opt/2stac.py
  - --result
  - valueFrom: $( inputs.result )
  - --metadata
  - valueFrom: $(runtime.outdir + '/metadata.json')

  inputs:
    result:
      type: File
      doc: The resulting file of the previous model to insert in STAC

  outputs:
    results:
      outputBinding:
        glob: .
      type: Directory
      doc: STAC output
    InitialWorkDirRequirement:
      listing: |
        ${

          return [{
            "class": "File",
            "basename": "metadata.json",
            "contents": JSON.stringify({
              "description": "This is an example metadata file for 2stac2.",
              "keywords": ["example", "metadata", "helloworld"],
              "bbox": [-180, -90, 180, 90],
              "datetime": new Date().toISOString(),
              "media_type": "application/json",
              "geometry": {
                "type": "Polygon",
                "coordinates": [
                  [
                    [-180, -90],
                    [-180, 90],
                    [180, 90],
                    [180, -90],
                    [-180, -90]
                  ]
                ]
              },
            })}];
        }
  requirements:
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac:0.2.0

  s:name: 2stac_simulation
  s:softwareVersion: 0.2.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac/2stac_simulation_0_2_0.cwl
  s:dateCreated: "2025-06-10T00:51:03Z"