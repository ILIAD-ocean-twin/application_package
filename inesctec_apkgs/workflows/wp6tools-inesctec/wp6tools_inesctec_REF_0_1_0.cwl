cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: Workflow
  id: wp6tools_pipeline
  doc: wp6 workflow
  inputs:
    bathymetry:
        type: boolean?
        doc: If want to generate bathymetry
        label: bathymetry

    latitude:
      type: float
      doc: The latitude of the study area
      label: narratives
    longitude:
      type: float
      doc: The longitude of the study area
      label: narratives
    radius:
      type: float
      doc: The radius of the study area
      label: narratives
    type:
      type: string
      label: narratives
    url:
      type: string
      label: narratives
    samples:
      type: string
      label: narratives
    time:
      type: string
      label: narratives
    minutes:
      type: string
      label: narratives
    frames:
      type: string
      label: narratives
    density:
      type: string
      label: narratives
    output-format:
      type: string?
      default: stac
      label: narratives
    depth:
        type: float?
    output-animation:
      type: boolean?
      label: narratives

    template_file:
      type: string?
      label: virtualc
    cesium_mappings:
      type: string?
      label: virtualc
    unity_mappings:
      type: string?
      label: virtualc

    endpoint:
      type: string?
      doc: S3 storage endpoint
      label: s3storage
    region:
      type: string?
      doc: S3 storage region
      label: s3storage
    access_key:
      type: string?
      doc: S3 storage access_key
      label: s3storage
    secret_key:
      type: string?
      doc: S3 storage secret_key
      label: s3storage
    session_token:
      type: string?
      doc: S3 storage region
      label: s3storage
    bucket:
      type: string?
      doc: S3 storage bucket
      label: s3storage
    base_path:
      type: string?
      doc: S3 storage final directory name
      default: "wp6tools_virtual_choreographies_pipeline"
      label: s3storage

  steps:
    step_point2bbox:
      when: $(inputs.bathymetry == true)
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/point2bbox/point2bbox_0_1_0.cwl#point2bbox'
      in:
        bathymetry: bathymetry
        lat: latitude
        lon: longitude
        radius: radius
      out:
      - lon_min
      - lon_max
      - lat_min
      - lat_max
    step_bathymetry:
      when: $(inputs.bathymetry == true)
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/bathymetry-forth/bathymetry_forth_0_1_0.cwl#bathymetry'
      in:
        bathymetry: bathymetry
        lon_min: step_point2bbox/lon_min
        lon_max: step_point2bbox/lon_max
        lat_min: step_point2bbox/lat_min
        lat_max: step_point2bbox/lat_max
      out:
      - result
      - metadata
    step_generate_model:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-model/wp6tools_generate_model_0_1_2.cwl#generate-model'
      in:
        type: type
        url: url
        latitude: latitude
        longitude: longitude
        radius: radius
        samples: samples
        time: time
        minutes: minutes
        output-animation: output-animation
      out:
      - result
      - animation
    step_extract_particles:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-extract-particles/wp6tools_extract_particles_0_1_2.cwl#extract-particles'
      in:
        input-file: step_generate_model/result
        output-format:
          default: "stac"
        projection-function:
          default: "none"
        projection-resolution:
          default: "none"
        latitude-variable:
          default: "lat"
        longitude-variable:
          default: "lon"
        time-variable:
          default: "time"
      out:
      - result
    step_crop_frames:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-crop-frames/wp6tools_crop_frames_0_1_2.cwl#crop-frames'
      in:
        particles: step_extract_particles/result
        frames: frames
      out:
      - result
    step_generate_contours:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-contours/wp6tools_generate_contours_0_1_2.cwl#generate-contours'
      in:
        cropped: step_crop_frames/result
        density: density
        output-format: output-format
      out:
      - result
    dir2files:
      when: $(inputs.template_file != null && inputs.template_file != "")
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/dir2files/dir2files_0_1_0.cwl#dir2files'
      in:
        input_dir: step_generate_contours/result
      out:
      - output_files
    json_append:
      when: $(inputs.template_file != null && inputs.template_file != "")
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/json-append/json_append_wp6tools_pipeline_0_1_0.cwl#json_append_wp6tools_pipeline'
      in:
        files: dir2files/output_files
      out:
      - result
    step_virtual_choreographies_generator:
      when: $(inputs.template_file != null && inputs.template_file != "")
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-generator/virtual_choreographies_generator_0_1_0.cwl#virtual-choreographies-generator'
      in:
        dataset: json_append/result
        template_url: template_file
      out:
      - vc
    step_virtual_choreographies_unity_plugin:
      when: $(inputs.template_file != null && inputs.template_file != "")
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-unity-plugin/virtual_choreographies_unity_plugin_0_1_0.cwl#virtual-choreographies-unity-plugin'
      in:
        vc: step_virtual_choreographies_generator/vc
        mappings_url: unity_mappings
      out:
      - platform_choreography
    step_virtual_choreographies_cesium_plugin:
      when: $(inputs.template_file != null && inputs.template_file != "")
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-cesium-plugin/virtual_choreographies_cesium_plugin_0_1_0.cwl#virtual-choreographies-cesium-plugin'
      in:
        vc: step_virtual_choreographies_generator/vc
        mappings_url: cesium_mappings
      out:
      - platform_choreography
    step_metadata_2stact2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-metadata-2stac2/wp6tools_metadata_2stac2_0_1_0.cwl#metadata-2stact2'
      in:
        latitude: latitude
        longitude: longitude
        radius: radius
        frames: frames
        time: time
      out:
      - result
    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_wp6tools_pipeline_0_1_1.cwl#2stac2_wp6tools_pipeline'
      in:
        unity_choreography: step_virtual_choreographies_cesium_plugin/platform_choreography
        cesium_choreography: step_virtual_choreographies_unity_plugin/platform_choreography
        simulation: step_generate_model/result
        animation: step_generate_model/animation
        metadata: step_metadata_2stact2/result
        bathymetry: step_bathymetry/result
      out:
      - stac_result
    step_2s3:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2s3/2s3_0_1_0.cwl#2s3'
      when: $(inputs.endpoint != null && inputs.endpoint != "")
      in:
        region: region
        endpoint: endpoint
        access_key: access_key
        secret_key: secret_key
        session_token: session_token
        bucket: bucket
        directory: step_2stac2/stac_result
      out:
        - base_path

  outputs:
  - id: openoil
    outputSource:
    - step_2stac2/stac_result
    type:
      Directory
    "cwltool:Secrets":
  hints:
      secrets: [access_key,secret_key,session_token]
  requirements:
    InlineJavascriptRequirement: {}

  s:name: wp6tools_pipeline
  s:description: wp6 tools workflow to generate contours
  s:keywords:
    - oil spill
    - opendrift
    - choreographies
    - virtual choreographies
    - 2s3
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/wp6tools-inesctec/wp6tools_inesctec_REF_0_1_0.cwl
  s:dateCreated: "2025-05-09T16:32:43Z"
