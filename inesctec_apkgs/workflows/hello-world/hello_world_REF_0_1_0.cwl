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
  outputs:
  - id: wf_outputs
    outputSource:
    - step_helloworld/result
    type:
      File
  requirements:
    InlineJavascriptRequirement: {}

  s:name: helloworld_pipeline
  s:description: |
    This pipeline runs the helloworld tool and returns the result.
  s:keywords:
    - helloworld
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/hello-world/hello_world_REF_0_1_0.cwl
  s:dateCreated: "2025-05-26T10:36:16Z"
