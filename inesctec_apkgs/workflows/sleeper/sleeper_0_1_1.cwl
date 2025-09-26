cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/
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
        run: '#sleep'
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
        run: '#2stac2_sleeper_pipeline'
        in:
          result: step_sleep/res
          metadata: step_simulate_metadata/metadata
        out:
          - stac_result
    outputs:
      - id: wf_outputs
        outputSource:
          - step_2stac2/stac_result
        type: Directory
    requirements:
      InlineJavascriptRequirement: {}
    s:name: sleeper_pipeline
    s:description: >
      This pipeline sleeps for a given number of seconds and then simulates
      metadata for 2stac.
    s:keywords:
      - sleeper
    s:softwareVersion: 0.1.1
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
      https://pipe-drive.inesctec.pt/application-packages/workflows/sleeper/sleeper_0_1_1.cwl
    s:dateCreated: '2025-06-05T17:40:32Z'
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
  - class: CommandLineTool
    id: sleep
    baseCommand: app-sleep
    arguments:
      - '--seconds'
      - valueFrom: $( inputs.seconds )
    inputs:
      seconds:
        type: int
        doc: seconds to sleep
        default: 12
    outputs:
      res:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: result/res.json
        doc: tree list
    requirements:
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/sleep:0.1.0
    s:name: sleep
    s:description: sleep time in seconds
    s:keywords:
      - sleep
      - simulation
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
      https://pipe-drive.inesctec.pt/application-packages/tools/sleep/sleep_0_1_0.cwl
    s:dateCreated: '2025-05-12T12:39:43Z'
  - class: CommandLineTool
    id: 2stac2_sleeper_pipeline
    baseCommand: python
    arguments:
      - /opt/2stac2.py
      - '--file'
      - valueFrom: $(inputs.result)
      - '--metadata'
      - valueFrom: $(inputs.metadata)
    inputs:
      result:
        format: edam:format_3464
        doc: result
        type: File
      metadata:
        format: edam:format_3464
        doc: metadata file description
        type: File
    outputs:
      stac_result:
        outputBinding:
          glob: stac_result
        type: Directory
        doc: STAC output
    requirements:
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/2stac2:0.2.0
      InplaceUpdateRequirement:
        inplaceUpdate: true
    s:name: 2stac2_sleeper_pipeline
    s:softwareVersion: 0.2.0
    s:description: 2stac2 for the sleeper pipeline
    s:keywords:
      - stac
      - metadata
    s:programmingLanguage: python
    s:sourceOrganization:
      class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
    s:author:
      class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_sleeper_pipeline_0_2_0.cwl
    s:dateCreated: '2025-06-04T17:02:42Z'
