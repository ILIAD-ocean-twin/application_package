cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: helloworld_pipeline
    inputs:
      s3_bucket:
        type: string
        doc: Some keyword
    steps:
      step_helloworld:
        run: '#helloworld'
        in:
          name: s3_bucket
        out:
          - result
      step_2stac:
        run: '#2stac2_simulation'
        in:
          result: step_helloworld/result
        out:
          - stac_result
    outputs:
      - id: wf_outputs
        outputSource:
          - step_2stac/stac_result
        type: Directory
    requirements:
      InlineJavascriptRequirement: {}
    s:name: helloworld_pipeline
    s:description: |
      This pipeline runs the helloworld tool and returns the result.
    s:keywords:
      - helloworld
    s:softwareVersion: 0.3.2
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
      https://pipe-drive.inesctec.pt/application-packages/workflows/hello-world/hello_world_0_3_2.cwl
    s:dateCreated: '2025-06-11T20:09:26Z'
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
    id: 2stac2_simulation
    baseCommand: python
    arguments:
      - /opt/2stac2.py
      - '--file'
      - valueFrom: $( inputs.result )
      - '--metadata'
      - valueFrom: $(runtime.outdir + '/metadata.json')
    inputs:
      result:
        type: File
        doc: The resulting file of the previous model to insert in STAC
    outputs:
      stac_result:
        outputBinding:
          glob: stac_result
        type: Directory
        doc: STAC output
    requirements:
      ResourceRequirement: {}
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/2stac2:0.3.1
      InitialWorkDirRequirement:
        listing: |
          ${

            return [{
              "class": "File",
              "basename": "metadata.json",
              "contents": JSON.stringify([{
                "filename": inputs.result.basename,
                "description": "This is an example metadata file for 2stac2.",
                "keywords": ["example", "metadata", "helloworld"],
                "bbox": [-180, -90, 180, 90],
                "datetime": new Date().toISOString(),
                "media_type": "text/plain",
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
              }])}];
          }
    s:name: 2stac2_simulation
    s:softwareVersion: 0.3.1
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
      https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_simulation_0_3_1.cwl
    s:dateCreated: '2025-06-10T15:27:44Z'
