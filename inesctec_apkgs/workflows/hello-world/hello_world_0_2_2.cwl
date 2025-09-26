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
      seconds:
        type: int?
        doc: Seconds to sleep
    steps:
      step_helloworld:
        run: '#helloworld'
        in:
          name: name
        out:
          - result
      step_sleep:
        when: $(inputs.seconds != null)
        run: '#sleep'
        in:
          seconds: seconds
        out:
          - res
      step_2stac:
        run: '#stac_simulation'
        in:
          something:
            source:
              - step_helloworld/result
              - step_sleep/res
            pickValue: first_non_null
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
    s:softwareVersion: 0.2.2
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
      https://pipe-drive.inesctec.pt/application-packages/workflows/hello-world/hello_world_0_2_2.cwl
    s:dateCreated: '2025-06-05T21:28:11Z'
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
    id: sleep
    baseCommand: app-sleep
    arguments:
      - '--seconds'
      - valueFrom: $( inputs.seconds )
    inputs:
      seconds:
        type: int
        doc: seconds to sleep
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
    s:dateCreated: '2025-06-05T21:00:14Z'
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
    s:dateCreated: '2025-06-05T20:05:30Z'
