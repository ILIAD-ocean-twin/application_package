cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: Workflow
  id: sleeper_pipeline
  inputs:
    seconds:
      type: int
      doc: Seconds to sleep
      default: 60

  steps:
    step_sleep:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/sleep/sleep_0_1_0.cwl#sleep'
      in:
        seconds: seconds
      out:
      - res
    step_simulate_metadata:
      run: '#simulate_metadata_2stac'
      in: []
      out:
      - metadata
    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_sleeper_pipeline_0_3_0.cwl#2stac2_sleeper_pipeline'
      in:
        result: step_sleep/res
        metadata: step_simulate_metadata/metadata
      out:
      - stac_result
  outputs:
  - id: wf_outputs
    outputSource:
    - step_2stac2/stac_result
    type:
      Directory
  requirements:
    InlineJavascriptRequirement: {}

  s:name: sleeper_pipeline
  s:description: |
    This pipeline sleeps for a given number of seconds and then simulates metadata for 2stac.
  s:keywords:
    - sleeper
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/sleeper/sleeper_REF_0_2_0.cwl
  s:dateCreated: "2025-06-10T01:49:38Z"


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
            [{
              "filename": "res.json",
              "description": "This is an example metadata file for 2stac2.",
              "keywords": ["example", "metadata", "sleeper"],
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
            }]
          )
        }
      }
    }