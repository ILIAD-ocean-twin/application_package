cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: CommandLineTool
  baseCommand: fisheries
  id: fisheries

  arguments:
  - --username
  - valueFrom: $( inputs.username )
  - --password
  - valueFrom: $( inputs.password )

  inputs:
    username:
      type: string
      doc: CMEMS username
      s:name: CMEMS username
      s:description: CMEMS username to download datasets
      s:keywords:
        - username
        - CMEMS
    password:
      type: string
      doc: CMEMS password
      s:name: CMEMS password
      s:description: CMEMS password to download datasets
      s:keywords:
        - password
        - CMEMS

  outputs:
    results:
      outputBinding:
        glob: Output
        outputEval: |
          ${self[0].basename=new Date().toISOString(); return self;}
      type: Directory
      doc: The resulting files of the model
      s:name: Result files
      s:description: The resulting files of the model
      s:keywords:
        - result
        - Files
        - Directory
  requirements:
    NetworkAccess:
      networkAccess: true

    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
  
  hints:
    "cwltool:Secrets":
      secrets: [username,password]
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/fisheries:1.0.0


