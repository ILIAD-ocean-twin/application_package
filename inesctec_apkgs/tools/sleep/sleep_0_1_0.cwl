cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: sleep

  baseCommand: app-sleep
  arguments:
  - --seconds
  - valueFrom: $( inputs.seconds )

  inputs:
    seconds:
      type: int
      doc: seconds to sleep

  outputs:
    res:
      format: edam:format_3464 # JSON
      type: File
      outputBinding:
        glob: "result/res.json"
      doc: tree list

  requirements:
    EnvVarRequirement:
      envDef:
        PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/sleep/sleep_0_1_0.cwl
  s:dateCreated: "2025-06-05T21:00:14Z"




