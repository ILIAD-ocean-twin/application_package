cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: 2stac2

  baseCommand: python
  arguments:
  - /opt/2stac2.py
  - valueFrom: $(
      function () {
        var files_array = [];

        Object.keys(inputs).forEach(element => {
          if(element != 'metadata') {
            files_array.push('--file');
            files_array.push(inputs[element]);
          } else {
            files_array.push('--metadata');
            files_array.push(inputs[element]);
          }
        });

        return files_array;
      }())

  inputs:
    file_1:
      doc: file 1
      type: File
    file_2:
      doc: file 2
      type: File
    metadata:
      format: edam:format_3464 # JSON
      doc: metadata file
      type: File

  outputs:
    stac_result:
      outputBinding:
        glob: stac_result
      type: Directory
  requirements:
    EnvVarRequirement:
      envDef:
        PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac2:0.1.2

  s:name: 2stac2
  s:softwareVersion: 0.1.2
  s:description: Transform and array of files into a STAC
  s:keywords:
    - stac
    - metadata
  s:programmingLanguage: python
  s:publisher:
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_0_1_2.cwl
  s:dateCreated: "2025-03-19T11:38:18Z"
