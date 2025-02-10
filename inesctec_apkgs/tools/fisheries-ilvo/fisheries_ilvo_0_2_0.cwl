cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: CommandLineTool

  id: fisheries

  baseCommand: fisheries
  arguments:
  - --username
  - valueFrom: $( inputs.username )
  - --password
  - valueFrom: $( inputs.password )

  inputs:
    username:
      type: string
      doc: CMEMS username
    password:
      type: string
      doc: CMEMS password

  outputs:
    results:
      outputBinding:
        glob: Output
        outputEval: |
          ${self[0].basename=new Date().toISOString(); return self;}
      type: Directory
      doc: The resulting files of the model
  requirements:
    NetworkAccess:
      networkAccess: true

    ResourceRequirement: {}
    InlineJavascriptRequirement: {}

  hints:
    "cwltool:Secrets":
      secrets: [username,password]
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/fisheries-ilvo:0.2.0

  s:name: fisheries
  s:description: fisheries description
  s:keywords:
    - fisheries
    - ILVO
  s:programmingLanguage: R
  s:softwareVersion: 0.2.0
  s:sourceOrganization:
    class: s:Organization
    s:name: ILVO
    s:url: https://ilvo.vlaanderen.be/en/
    s:address:
        class: s:PostalAddress
        s:addressCountry: BE
  s:author:
    class: s:Person
    s:name: Clyde
    s:email: clyde@example.com
  s:contributor:
    class: s:Person
    s:name: Miguel Correia
    s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/fisheries-ilvo/fisheries_ilvo_0_2_0.cwl
  s:dateCreated: "2025-02-07T17:18:26Z"