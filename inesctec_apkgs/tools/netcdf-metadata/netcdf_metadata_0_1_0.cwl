cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: netcdf_metadata

  baseCommand: python
  arguments:
  - /opt/parse.py
  - --netcdf_file
  - valueFrom: $(inputs.netcdf_file)
  - valueFrom: $(inputs.extra_props ? ['--extra_props', inputs.extra_props] :[])

  inputs:
    netcdf_file:
      type: File
    extra_props:
      type: File?
  outputs:
    metadata:
      outputBinding:
        glob: ./metadata.json
      type: File
      format: edam:format_3464 # JSON

  requirements:
    MultipleInputFeatureRequirement: {}
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/netcdf-metadata:0.1.0

  s:name: netcdf_metadata
  s:softwareVersion: 0.1.0
  s:description: Extract metadata from NetCDF file
  s:keywords:
    - netcdf
    - metadata
  s:programmingLanguage: python
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/netcdf-metadata/netcdf_metadata_0_1_0.cwl
  s:dateCreated: "2025-06-10T01:07:05Z"
