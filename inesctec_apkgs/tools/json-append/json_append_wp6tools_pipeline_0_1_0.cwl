cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/


$graph:
- class: CommandLineTool

  id: json_append_wp6tools_pipeline

  baseCommand: python
  arguments:
  - /opt/append.py
  - valueFrom: $(
      function () {

        var files_array = [];
        Object.keys(inputs.files).forEach(function (element) {
            console.log(inputs.files[element]);
            if(inputs.files[element].basename !== 'contour-header.json')
            files_array.push('--file');
            files_array.push(inputs.files[element]);
        });
        return files_array;

      }())

  inputs:
    files:
      type: File[]?
      doc: files

  outputs:
    result:
      format: edam:format_3464 # JSON
      type: File
      outputBinding:
        glob: "appended.json"
      doc: json file appended

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/json-append:0.1.0


  s:name: json_append
  s:description: Append json files, objects and array of objects, to an array of objects
  s:keywords:
    - json
    - merge
    - append
    - metadata
  s:programmingLanguage: python
  s:softwareVersion: 0.1.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/json-append/json_append_wp6tools_pipeline_0_1_0.cwl
  s:dateCreated: "2025-05-12T12:23:08Z"