cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/

$graph:

- class: Workflow
  id: medslik_visualization_pipeline
  doc: medslik with wp6 visualization tools
  inputs:
    use_case_directory:
      doc: Path to directory as a string where to find input files and where to store outputs
      type: string
    bbox:
      doc: Bounding box for image search
      type: string?
    start_date:
      doc: Start date for data search
      type: string?
    time_interval:
      doc: Time interval (n of days) for data search
      type: int?
    end_date:
      doc: End date for data search
      type: string?
    verbose:
      doc: Enable verbose logging
      type: int?
    debug:
      doc: Enable debug mode
      type: int?
    asf_username:
      type: string
    asf_password:
      type: string
    cont_slick:
      type: string
      default: "NO"
    sat:
      type: string
      default: "NO"
    use_high_res:
      type: string
      default: "NO"
    min_lon:
      type: float?
      default: 24.069118741783797
    max_lon:
      type: float?
      default: 24.990341065648366
    min_lat:
      type: float?
      default: 35.09663196120557
    max_lat:
      type: float?
      default: 35.990635331961315
    lat_point:
      type: float?
      default: 35.496
    lon_point:
      type: float?
      default: -15.7433
    date_spill:
      type: string?
      default: "2024-11-07T06:22:00Z"
    spill_dur:
      type: string
    spill_res:
      type: string
    spill_tons:
      type: float
      default: 1.4
    username:
      type: string
    password:
      type: string
    ftp_server:
      type: string
    ftp_user:
      type: string
    ftp_password:
      type: string
    remote_dir:
      type: string
    cds_token:
      type: string?

    frames:
      type: string
      label: narratives
    density:
      type: string
      label: narratives

  steps:
    step_medslik:
      run: 'https://pipe-drive.inesctec.pt/cwl/medslik_v/medslik.cwl#oilspill_pipeline_medslik_157'
      in:
        use_case_directory: use_case_directory
        bbox: bbox
        start_date: start_date
        time_interval: time_interval
        end_date: end_date
        verbose: verbose
        debug: debug
        asf_username: asf_username
        asf_password: asf_password
        cont_slick: cont_slick
        sat: sat
        use_high_res: use_high_res
        min_lon: min_lon
        max_lon: max_lon
        min_lat: min_lat
        max_lat: max_lat
        lat_point: lat_point
        lon_point: lon_point
        date_spill: date_spill
        spill_dur: spill_dur
        spill_res: spill_res
        spill_tons: spill_tons
        username: username
        password: password
        ftp_server: ftp_server
        ftp_user: ftp_user
        ftp_password: ftp_password
        remote_dir: remote_dir
        cds_token: cds_token
      out:
      - pipeline_output
    step_extract_file_from_directory:
      run: '#extract_file_from_directory'
      in:
        dir: step_medslik/pipeline_output
      out:
        - extracted_file
    step_extract_particles:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-extract-particles/wp6tools_extract_particles_0_1_3.cwl#extract-particles'
      in:
        input-file: step_extract_file_from_directory/extracted_file

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
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-crop-frames/wp6tools_crop_frames_0_1_3.cwl#crop-frames'
      in:
        particles: step_extract_particles/result
        frames: frames
      out:
      - result
    step_generate_contours:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-contours/wp6tools_generate_contours_0_1_3.cwl#generate-contours'
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
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-generator/virtual_choreographies_generator_0_2_1.cwl#virtual-choreographies-generator'
      in:
        dataset: json_append/result
      out:
      - vc
      - recipe
    step_virtual_choreographies_unity_plugin:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-unity/virtual_choreographies_transformer_plugin_unity_0_2_1.cwl#virtual-choreographies-transformer-plugin-unity'
      in:
        vc: step_virtual_choreographies_generator/vc
        vc_recipe: step_virtual_choreographies_generator/recipe
      out:
      - platform_choreography
    step_virtual_choreographies_cesium_plugin:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-cesium/virtual_choreographies_transformer_plugin_cesium_0_2_1.cwl#virtual-choreographies-transformer-plugin-cesium'
      in:
        vc: step_virtual_choreographies_generator/vc
        vc_recipe: step_virtual_choreographies_generator/recipe
      out:
      - platform_choreography
    step_metadata_2stact2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-metadata-2stac2/wp6tools_metadata_2stac2_0_1_3.cwl#metadata-2stact2'
      in:
        latitude: lat_point
        longitude: lon_point
        radius:
            valueFrom: $(
                function () {
                    return parseFloat(self);
                }())
            source: spill_res
        frames: frames
        time: date_spill
      out:
      - result
    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_wp6tools_pipeline_0_1_3.cwl#2stac2_wp6tools_pipeline'
      in:
        unity_choreography: step_virtual_choreographies_cesium_plugin/platform_choreography
        cesium_choreography: step_virtual_choreographies_unity_plugin/platform_choreography
        simulation: step_extract_file_from_directory/extracted_file
        metadata: step_metadata_2stact2/result
      out:
      - stac_result

  outputs:
  - id: wf_outputs
    outputSource:
    - step_2stac2/stac_result
    type:
      Directory
  hints:
    "cwltool:Secrets":
      secrets: [asf_password,password,ftp_password,cds_token]


  requirements:
    InlineJavascriptRequirement: {}
    SubworkflowFeatureRequirement: {}
    StepInputExpressionRequirement: {}

  s:name: medslik_visualization_pipeline
  s:description: medslik with wp6 visualization tools
  s:keywords:
    - oil spill
    - medslik
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/medslik-visualization/medslik_visualization_REF_0_1_0.cwl
  s:dateCreated: "2025-05-29T17:11:40Z"


- class: ExpressionTool
  id: extract_file_from_directory
  inputs:
    dir:
      type: Directory
      loadListing: deep_listing
  outputs:
    extracted_file:
      type: File
  expression: |
    ${
        const dir = inputs.dir.listing.find(f => f.class && f.class === "Directory");
        // const ncFile = dir.listing.find(f => f.nameroot === "spill_properties" && f.nameext === ".nc");
        const ncFile = dir.listing.find(f => f.basename === "spill_properties.nc");
        // inject required format file
        ncFile.format = "http://edamontology.org/format_3650";
        return { extracted_file: ncFile };
    }