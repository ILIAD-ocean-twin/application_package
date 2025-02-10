cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/

$graph:

- class: Workflow
  id: bathymetry_pipeline
  inputs:
    lon_min:
      type: float
      label: Minimum Longitude
      doc: The minimum longitude of the study area
    lon_max:
      type: float
      label: Maximum Longitude
      doc: The maximum longitude of the study area
    lat_min:
      type: float
      label: Minimum Latitude
      doc: The minimum latitude of the study area
    lat_max:
      type: float
      label: Maximum Latitude
      doc: The maximum latitude of the study area
    endpoint:
      type: string?
      doc: S3 storage endpoint
    region:
      type: string?
      doc: S3 storage region
    access_key:
      type: string?
      doc: S3 storage access_key
    secret_key:
      type: string?
      doc: S3 storage secret_key
    session_token:
      type: string?
      doc: S3 storage region
    bucket:
      type: string?
      doc: S3 storage bucket
    base_path:
      type: string?
      doc: S3 storage final directory name
      default: "bathymetry_pipeline"
  steps:
    step_bathymetry:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/bathymetry-forth/bathymetry_forth_0_2_0.cwl#bathymetry'
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
    step_2s3:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2s3/2s3_0_2_0.cwl#2s3'
      when: $(inputs.endpoint != null && inputs.endpoint != "")
      in:
        region: region
        endpoint: endpoint
        access_key: access_key
        secret_key: secret_key
        session_token: session_token
        bucket: bucket
        directory: step_2stac/results
        base_path: base_path
      out:
        - base_path

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
    This pipeline crops the bathymetry for a given area, transforms the result to STAC format and stores the results in a S3 bucket.

    The step of saving the results to S3 is optional: if the input endpoint is not set, the S3 step is skipped.

  s:keywords:
    - bathymetry
    - stac
  s:softwareVersion: 0.3.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/bathymetry-pipeline/bathymetry_pipeline_REF_0_3_0.cwl
  s:dateCreated: "2025-02-10T12:24:25Z"