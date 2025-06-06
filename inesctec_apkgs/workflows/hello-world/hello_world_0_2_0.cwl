cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: helloworld_pipeline
    inputs:
      name:
        type: string
        doc: Some keyword
    steps:
      step_helloworld:
        run: '#helloworld'
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
        run: '#2stac'
        in:
          result: step_helloworld/result
          metadata: step_simulate_metadata/metadata
        out:
          - results
    outputs:
      - id: wf_outputs
        outputSource:
          - step_2stac/results
        type: Directory
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/workflows/hello-world/hello_world_0_2_0.cwl
    s:dateCreated: '2025-06-05T17:53:26Z'
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
  - class: CommandLineTool
    id: helloworld
    baseCommand: python
    arguments:
      - /opt/helloworld.py
      - valueFrom: $( inputs.name )
    inputs:
      name:
        type: string
        doc: Some keyword
    outputs:
      result:
        type: File
        outputBinding:
          glob: result.txt
        doc: result file
    requirements:
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/hello-world:0.1.0
    s:name: helloworld
    s:description: Hello World example
    s:keywords:
      - helloworld
      - example
      - simple
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/hello-world/hello_world_0_1_0.cwl
    s:dateCreated: '2025-05-12T12:21:05Z'
  - class: CommandLineTool
    id: 2stac
    baseCommand: python
    arguments:
      - /opt/2stac.py
      - '--result'
      - valueFrom: $( inputs.result )
      - '--metadata'
      - valueFrom: $( inputs.metadata )
    inputs:
      result:
        type: File
        doc: The resulting file of the previous model to insert in STAC
      metadata:
        format: edam:format_3464
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
        dockerPull: iliad-repository.inesctec.pt/2stac:0.2.0
    s:name: 2stac
    s:softwareVersion: 0.2.0
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/2stac/2stac_0_2_0.cwl
    s:dateCreated: '2025-06-03T19:37:23Z'
