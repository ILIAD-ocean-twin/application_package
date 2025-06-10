cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: Workflow
  id: bathymetry_pipeline
  inputs:
    lon_min:
      type: float
      doc: The minimum longitude of the study area
      label: area
    lon_max:
      type: float
      doc: The maximum longitude of the study area
      label: area
    lat_min:
      type: float
      doc: The minimum latitude of the study area
      label: area
    lat_max:
      type: float
      doc: The maximum latitude of the study area
      label: area

  steps:
    step_bathymetry:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/bathymetry-forth/bathymetry_forth_0_1_0.cwl#bathymetry'
      in:
        lon_min: lon_min
        lon_max: lon_max
        lat_min: lat_min
        lat_max: lat_max
      out:
      - result
      - metadata
    step_2stac:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac/2stac_0_2_0.cwl#2stac'
      in:
        result: step_bathymetry/result
        metadata: step_bathymetry/metadata
      out:
      - results

  outputs:
  - id: wf_outputs
    outputSource:
    - step_2stac/results
    type:
      Directory
  hints:
    "cwltool:Secrets":
      secrets: [access_key,secret_key,session_token]
  requirements:
    InlineJavascriptRequirement: {}

  s:name: bathymetry_pipeline
  s:description: |
    This pipeline crops the bathymetry for a given area, transforms the result to STAC format.

  s:keywords:
    - bathymetry
    - stac
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/bathymetry-pipeline/bathymetry_pipeline_REF_0_2_0.cwl
  s:dateCreated: "2025-06-10T01:30:32Z"
