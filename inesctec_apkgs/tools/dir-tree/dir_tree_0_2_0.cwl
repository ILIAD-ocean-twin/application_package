cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: CommandLineTool

  id: tree

  baseCommand: python
  arguments:
  - /opt/tree.py
  - --dir
  - valueFrom: $( inputs.dir )

  inputs:
    dir:
      type: Directory
      doc: directory

  outputs:
    file_tree:
      type: File
      outputBinding:
        glob: "result/file_tree.txt"
      doc: tree list

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef:
        PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/dir-tree:0.2.0

  s:name: tree
  s:description: Print the tree of a given directory
  s:keywords:
    - tree
    - print
    - directory
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/dir-tree/dir_tree_0_2_0.cwl
  s:dateCreated: "2025-02-07T17:10:20Z"