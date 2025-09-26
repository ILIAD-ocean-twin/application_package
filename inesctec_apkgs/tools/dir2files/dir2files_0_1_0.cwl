cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: CommandLineTool

  id: dir2files

  baseCommand: python
  arguments:
  - /opt/dir2files.py
  - --directory
  - valueFrom: $(inputs.input_dir)
  inputs:
    input_dir:
      type: Directory

  outputs:
    output_files:
      type: File[]
      outputBinding:
        glob: ./*

  requirements:
    DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/dir2files:0.1.0
    EnvVarRequirement:
      envDef:
        PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

  s:name: dir2files
  s:description: Converts a directory to a list of files
  s:keywords:
    - directory
    - files
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/dir2files/dir2files_0_1_0.cwl
  s:dateCreated: "2025-05-12T12:12:44Z"