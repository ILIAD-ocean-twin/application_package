
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: Workflow
  id: pyopia_pipeline
  doc: This pipeline runs a pyopia
  inputs:
    dir_name:
      type: string?
      doc: Name of the output directory
      default: pyopia_inputs
    directory:
      type:
        - string?
        - Directory?
      doc: URL to download the directory or local path
    s3_endpoint:
      type: string?
      doc: S3 storage endpoint
    s3_region:
      type: string?
      doc: S3 storage region
    s3_access_key:
      type: string?
      doc: S3 storage access_key
    s3_secret_key:
      type: string?
      doc: S3 storage secret_key
    s3_session_token:
      type: string?
      doc: S3 storage region
    s3_bucket_name:
      type: string?
      doc: S3 storage bucket
    s3_path:
      type: string?
      doc: S3 path to the directory

  steps:
    step_get_dir:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/get-dir/get_dir_pyopia_pipeline_0_1_0.cwl#get_dir_pyopia_pipeline'
      in:
        dir_name: dir_name
        directory: directory
        s3_endpoint: s3_endpoint
        s3_region: s3_region
        s3_access_key: s3_access_key
        s3_secret_key: s3_secret_key
        s3_session_token: s3_session_token
        s3_bucket_name: s3_bucket_name
        s3_path: s3_path
      out:
      - images
      - auxiliary_data
      - config
      - metadata
      - model_classifier
    step_pyopia:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/pyopia-sintef/pyopia_sintef_0_1_0.cwl#pyopia_sintef'
      in:
        images: step_get_dir/images
        auxiliary_data: step_get_dir/auxiliary_data
        config: step_get_dir/config
        metadata: step_get_dir/metadata
        model_classifier: step_get_dir/model_classifier
      out:
      - netcdf_statistics
      - particles_figure
      - vd_copepods
      - vd_copepods_per_L
      - metadata
    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_pyopia_pipeline_0_3_1.cwl#2stac2_pyopia_pipeline'
      in:
        simulation: step_pyopia/netcdf_statistics
        particles_figure: step_pyopia/particles_figure
        vd_copepods: step_pyopia/vd_copepods
        vd_copepods_per_L: step_pyopia/vd_copepods_per_L
        metadata: step_pyopia/metadata
      out:
      - stac_result
  outputs:
  - id: wf_outputs
    outputSource:
    - step_2stac2/stac_result
    type:
      Directory

  requirements:
    InlineJavascriptRequirement: {}

  s:name: pyopia_pipeline
  s:description: |
    This pipeline runs a PyOPIA analysis, generating figures and statistics from copepod image data and packaging the results into a STAC output.
  s:keywords:
    - pyopia
    - simulation
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
  s:codeRepository: https://github.com/SINTEF/pyopia/tree/main
  s:dateCreated: "2025-11-24T23:31:23Z"
