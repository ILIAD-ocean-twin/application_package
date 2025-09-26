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
    step_2stac:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/stac-simulation/stac_simulation_0_1_0.cwl#stac_simulation'
      in:
        something: step_helloworld/result
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/hello-world/hello_world_REF_0_2_1.cwl
  s:dateCreated: "2025-06-05T19:00:24Z"
