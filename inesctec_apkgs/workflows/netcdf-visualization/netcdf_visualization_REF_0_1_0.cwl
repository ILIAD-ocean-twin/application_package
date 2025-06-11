cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/

$graph:

- class: Workflow
  id: netcdf_visualization_pipeline
  doc: netcdf visualization pipeline
  inputs:
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
    s3_bucket:
      type: string?
      doc: S3 storage bucket
    s3_path:
      type: string?
      doc: S3 path to file

    netcdf_file:
      type:
        - File?
        - string?
      label: netcdf file
      format: edam:format_3650 # NetCDF
    frames:
      type: string
      label: narratives
    density:
      type: string
      label: narratives

    latitude:
      type: float
    longitude:
      type: float
    radius:
      type: float
    time:
      type: string

  steps:
    step_get_file:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/get-file/get_file_netcdf_visualization_pipeline_0_1_0.cwl#get_file'
      in:
        filename:
          default: "simulation.nc"
        file: netcdf_file
        s3_endpoint: s3_endpoint
        s3_region: s3_region
        s3_access_key: s3_access_key
        s3_secret_key: s3_secret_key
        s3_session_token: s3_session_token
        s3_bucket: s3_bucket
        s3_path: s3_path
      out:
      - file_output
    step_extract_particles:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-extract-particles/wp6tools_extract_particles_0_2_0.cwl#extract_particles'
      in:
        input-file: step_get_file/file_output
        output-format:
          default: "stac"
        projection-function:
          default: "none"
        projection-resolution:
          default: "none"
        latitude-variable:
          default: "latitude"
        longitude-variable:
          default: "longitude"
        time-variable:
          default: "time"
      out:
      - result
    step_crop_frames:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-crop-frames/wp6tools_crop_frames_0_2_0.cwl#crop_frames'
      in:
        particles: step_extract_particles/result
        frames: frames
      out:
      - result
    step_generate_contours:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-contours/wp6tools_generate_contours_0_2_0.cwl#generate_contours'
      in:
        cropped: step_crop_frames/result
        density: density
        output-format:
          default: "json"
      out:
      - result
    dir2files:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/dir2files/dir2files_0_1_0.cwl#dir2files'
      in:
        input_dir: step_generate_contours/result
      out:
      - output_files
    json_append:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/json-append/json_append_wp6tools_pipeline_0_1_0.cwl#json_append_wp6tools_pipeline'
      in:
        files: dir2files/output_files
      out:
      - result
    step_virtual_choreographies_generator:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-generator/virtual_choreographies_generator_0_3_0.cwl#virtual_choreographies_generator'
      in:
        dataset: json_append/result
      out:
      - vc
      - recipe
    step_virtual_choreographies_unity_plugin:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-unity/virtual_choreographies_transformer_plugin_unity_0_3_0.cwl#virtual_choreographies_transformer_plugin_unity'
      in:
        vc: step_virtual_choreographies_generator/vc
        vc_recipe: step_virtual_choreographies_generator/recipe
      out:
      - platform_choreography
    step_virtual_choreographies_cesium_plugin:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-cesium/virtual_choreographies_transformer_plugin_cesium_0_3_0.cwl#virtual_choreographies_transformer_plugin_cesium'
      in:
        vc: step_virtual_choreographies_generator/vc
        vc_recipe: step_virtual_choreographies_generator/recipe
      out:
      - platform_choreography
    step_netcdf_metadata:
      in:
        netcdf_file: step_get_file/file_output
      run: "https://pipe-drive.inesctec.pt/application-packages/tools/netcdf-metadata/netcdf_metadata_0_1_0.cwl#netcdf_metadata"
      out:
        - metadata
    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_wp6tools_pipeline_0_3_1.cwl#2stac2_wp6tools_pipeline'
      in:
        unity_choreography: step_virtual_choreographies_cesium_plugin/platform_choreography
        cesium_choreography: step_virtual_choreographies_unity_plugin/platform_choreography
        simulation: step_get_file/file_output
        metadata: step_netcdf_metadata/metadata
      out:
      - stac_result

  outputs:
  # - id: out_extract_particles
  #   outputSource:
  #   - step_extract_particles/result
  #   type:
  #     Directory
  - id: openoil
    outputSource:
    - step_2stac2/stac_result
    type:
      Directory
  hints:
    "cwltool:Secrets":
      secrets: [access_key,secret_key,session_token]
  requirements:
    InlineJavascriptRequirement: {}

  s:name: netcdf_visualization_pipeline
  s:description: netcdf visualization pipeline
  s:keywords:
    - oil spill
    - opendrift
    - choreographies
    - virtual choreographies
    - wp6
    - tools
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/netcdf-visualization/netcdf_visualization_REF_0_1_0.cwl
  s:dateCreated: "2025-06-10T23:16:01Z"
