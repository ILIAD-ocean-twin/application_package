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
      step_2stac:
        run: '#2stac'
        in:
          result: step_sleep/res
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
    s:name: sleeper_pipeline
    s:description: >
      This pipeline sleeps for a given number of seconds and then simulates
      metadata for 2stac.
    s:keywords:
      - sleeper
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
      https://pipe-drive.inesctec.pt/application-packages/workflows/sleeper/sleeper_0_1_0.cwl
    s:dateCreated: '2025-06-03T19:54:58Z'
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
                "keywords": ["example", "metadata", "sleeper"],
                "bbox": [-180, -90, 180, 90],
                "datetime": new Date().toISOString(),
                "media_type": "JSON"
              }
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
