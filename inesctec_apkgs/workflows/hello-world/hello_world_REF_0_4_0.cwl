cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: Workflow
  id: helloworld_pipeline
  inputs:
    seconds:
      type: int?
      doc: number of seconds
    name:
      type: string
      doc: Some keyword
  steps:
    step_sleep:
      when: $(inputs.seconds != null)
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/sleep/sleep_0_1_0.cwl#sleep'
      in:
        seconds: seconds
      out:
      - res
    step_helloworld:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/hello-world/hello_world_0_1_0.cwl#helloworld'
      in:
        name: name
        # sleep_result: step_sleep/result
      out:
      - result
    step_2stac:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_simulation_0_3_1.cwl#2stac2_simulation'
      in:
        result: step_helloworld/result
      out:
      - stac_result
  outputs:
  - id: wf_outputs
    outputSource:
    - step_2stac/stac_result
    type:
      Directory
  requirements:
    InlineJavascriptRequirement: {}

  s:name: helloworld_pipeline
  s:description: |
    This pipeline runs the helloworld tool and returns the result.
  s:keywords:
    - helloworld
  s:softwareVersion: 0.4.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/hello-world/hello_world_REF_0_4_0.cwl
  s:dateCreated: "2025-07-21T17:23:40Z"
