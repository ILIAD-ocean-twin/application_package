cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: workflow-url-merge

  baseCommand: node
  arguments:
  - /app/index.js
  - valueFrom: $( inputs.cwl_workflow )
#   - valueFrom: $(
#       function () {
#         if (inputs.output_filename) {
#           return [inputs.output_filename];
#         } else {
#           return [];
#         }
#       }())

  inputs:
    cwl_workflow:
      format: edam:format_3857 # CWL
      type: File
      doc: cwl file input
    output_filename:
      type: string?
      doc: output filename

  outputs:
    result:
      format: edam:format_3857 # CWL
      type: File
      outputBinding:
        glob: "workflow_merged.cwl"
      doc: file output

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/workflow-url-merge:0.2.0

  s:name: workflow-url-merge
  s:description: Update a cwl file workflow, with url on steps and merge them into a single file
  s:keywords:
    - workflow
    - merge
  s:programmingLanguage: javascript
  s:softwareVersion: 0.2.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/workflow-url-merge/workflow_url_merge_0_2_0.cwl
  s:dateCreated: "2025-05-12T15:35:51Z"