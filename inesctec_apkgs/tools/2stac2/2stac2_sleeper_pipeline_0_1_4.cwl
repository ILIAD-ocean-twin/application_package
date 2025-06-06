cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:

- class: CommandLineTool

  id: 2stac2_sleeper_pipeline
  baseCommand: python
  arguments:
  - /opt/2stac2.py
  - --result
  - valueFrom: $(inputs.result)
  - --metadata
  - valueFrom: $(inputs.metadata)

  inputs:
    result:
      format: edam:format_3464 # JSON
      doc: result
      type: File
    metadata:
      format: edam:format_3464 # JSON
      doc: metadata file description
      type: File
      loadContents: true

  outputs:
    stac_result:
      outputBinding:
        glob: stac_result
      type: Directory
      doc: STAC output

  requirements:
    EnvVarRequirement:
      envDef:
        PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac2:0.1.4
    InplaceUpdateRequirement:
      inplaceUpdate: true

  s:name: 2stac2_sleeper_pipeline
  s:softwareVersion: 0.1.4
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_sleeper_pipeline_0_1_4.cwl
  s:dateCreated: "2025-06-03T19:01:09Z"
