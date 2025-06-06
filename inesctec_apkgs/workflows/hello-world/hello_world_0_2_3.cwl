cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: helloworld_pipeline
    inputs: []
    steps:
      step_2stac:
        run: '#stac_simulation'
        in: []
        out:
          - results
    outputs:
      - id: wf_outputs
        outputSource:
          - step_2stac/results
        type: Directory
    requirements:
      InlineJavascriptRequirement: {}
      MultipleInputFeatureRequirement: {}
    s:name: helloworld_pipeline
    s:description: |
      This pipeline runs the helloworld tool and returns the result.
    s:keywords:
      - helloworld
    s:softwareVersion: 0.2.3
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
      https://pipe-drive.inesctec.pt/application-packages/workflows/hello-world/hello_world_0_2_3.cwl
    s:dateCreated: '2025-06-05T23:12:22Z'
  - class: CommandLineTool
    id: stac_simulation
    baseCommand: python
    arguments:
      - /opt/simulate.py
      - valueFrom: $(inputs.something)
        prefix: '--something'
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/stac-simulation/stac_simulation_0_1_1.cwl
    s:dateCreated: '2025-06-05T23:02:01Z'
