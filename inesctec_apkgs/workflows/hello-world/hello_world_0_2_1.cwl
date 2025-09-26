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
      step_2stac:
        run: '#stac_simulation'
        in:
          something: step_helloworld/result
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
    s:softwareVersion: 0.2.1
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
      https://pipe-drive.inesctec.pt/application-packages/workflows/hello-world/hello_world_0_2_1.cwl
    s:dateCreated: '2025-06-05T19:00:24Z'
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
    id: stac_simulation
    baseCommand: python
    arguments:
      - /opt/simulate.py
      - valueFrom: $( inputs.something ? ['--something', inputs.something]:[] )
    inputs:
      something:
        type:
          - File?
          - string?
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
        dockerPull: iliad-repository.inesctec.pt/stac-simulation:0.1.0
    s:name: stac_simulation
    s:softwareVersion: 0.1.0
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
      https://pipe-drive.inesctec.pt/application-packages/tools/stac-simulation/stac_simulation_0_1_0.cwl
    s:dateCreated: '2025-06-05T18:45:55Z'
