cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: Workflow
  id: helloworld_pipeline
  inputs:
    name:
      type: string
      doc: Some keyword
  steps:
    step_helloworld:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/hello-world/hello_world_0_1_0.cwl#helloworld'
      in:
        name: name
      out:
      - result
    step_simulate_metadata:
      run: '#simulate_metadata_2stac'
      in: []
      out:
      - metadata
    step_2stac:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac/2stac_0_2_0.cwl#2stac'
      in:
        result: step_helloworld/result
        metadata: step_simulate_metadata/metadata
      out:
      - results
  outputs:
  - id: wf_outputs
    outputSource:
    - step_2stac/results
    type:
      Directory
  requirements:
    InlineJavascriptRequirement: {}

  s:name: helloworld_pipeline
  s:description: |
    This pipeline runs the helloworld tool and returns the result.
  s:keywords:
    - helloworld
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/hello-world/hello_world_REF_0_2_0.cwl
  s:dateCreated: "2025-06-05T17:53:26Z"

- class: ExpressionTool
  id: simulate_metadata_2stac
  inputs: []
  outputs:
    metadata:
      type: File
  expression: |
    ${
      return {
        metadata: {
          "class": "File",
          "basename": "metadata.json",
          "nameroot": "metadata",
          "nameext": ".json",
          "format": "http://edamontology.org/format_3464", // JSON
          "contents": JSON.stringify(
            {
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
            }
          )
        }
      }
    }