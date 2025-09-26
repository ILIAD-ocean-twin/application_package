cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: medslik_visualization_pipeline_0_0_1
    doc: medslik with wp6 visualization tools
    inputs:
      use_case_directory:
        doc: >-
          Path to directory as a string where to find input files and where to
          store outputs
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
        default: 'NO'
      sat:
        type: string
        default: 'NO'
      use_high_res:
        type: string
        default: 'NO'
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
        default: '2024-11-07T06:22:00Z'
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
        run: '#oilspill_pipeline_medslik_156'
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
        run: '#extract-particles'
        in:
          input-file: step_extract_file_from_directory/extracted_file
          output-format:
            default: stac
          projection-function:
            default: none
          projection-resolution:
            default: none
          latitude-variable:
            default: latitude
          longitude-variable:
            default: longitude
          time-variable:
            default: time
        out:
          - result
      step_crop_frames:
        run: '#crop-frames'
        in:
          particles: step_extract_particles/result
          frames: frames
        out:
          - result
      step_generate_contours:
        run: '#generate-contours'
        in:
          cropped: step_crop_frames/result
          density: density
          output-format:
            default: json
        out:
          - result
      dir2files:
        run: '#dir2files'
        in:
          input_dir: step_generate_contours/result
        out:
          - output_files
      json_append:
        run: '#json_append_wp6tools_pipeline'
        in:
          files: dir2files/output_files
        out:
          - result
      step_virtual_choreographies_generator:
        run: '#virtual-choreographies-generator'
        in:
          dataset: json_append/result
        out:
          - vc
          - recipe
      step_virtual_choreographies_unity_plugin:
        run: '#virtual-choreographies-transformer-plugin-unity'
        in:
          vc: step_virtual_choreographies_generator/vc
          vc_recipe: step_virtual_choreographies_generator/recipe
        out:
          - platform_choreography
      step_virtual_choreographies_cesium_plugin:
        run: '#virtual-choreographies-transformer-plugin-cesium'
        in:
          vc: step_virtual_choreographies_generator/vc
          vc_recipe: step_virtual_choreographies_generator/recipe
        out:
          - platform_choreography
      step_metadata_2stact2:
        run: '#metadata-2stact2'
        in:
          latitude: lat_point
          longitude: lon_point
          radius:
            valueFrom: $( function () { return parseFloat(self); }())
            source: spill_res
          frames: frames
          time: date_spill
        out:
          - result
      step_2stac2:
        run: '#2stac2_wp6tools_pipeline'
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
        type: Directory
    hints:
      cwltool:Secrets:
        secrets:
          - asf_password
          - password
          - ftp_password
          - cds_token
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
    s:softwareVersion: 0.0.1
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/workflows/medslik-visualization/medslik_visualization_0_1_0.cwl
    s:dateCreated: '2025-05-26T10:29:14Z'
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
  - class: Workflow
    id: oilspill_pipeline_medslik_156
    doc: Oil Spill Detection and Analysis Pipeline 1-2-3-5, Medslik forecasting
    inputs:
      use_case_directory:
        doc: >-
          Path to directory as a string where to find input files and where to
          store outputs
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
        default: 'NO'
      sat:
        type: string
        default: 'NO'
      use_high_res:
        type: string
        default: 'NO'
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
        default: '2024-11-07T06:22:00Z'
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
    steps:
      step_data_search:
        in:
          bbox: bbox
          use_case_directory: use_case_directory
          start_date: start_date
          time_interval: time_interval
          end_date: end_date
          verbose: verbose
          debug: debug
          asf_username: asf_username
          asf_password: asf_password
        run: '#datasearch_tool'
        out:
          - results
          - sentinel_list
      step_preprocessing:
        in:
          use_case_directory: step_data_search/results
          sentinel_list: step_data_search/sentinel_list
          verbose: verbose
          debug: debug
        run: '#preprocessing_tool'
        out:
          - results
          - db_list
      step_object_detection:
        in:
          use_case_directory: step_preprocessing/results
          db_list: step_preprocessing/db_list
          verbose: verbose
          debug: debug
        run: '#object_detection_tool'
        out:
          - results
          - png_output_path
          - csv_output_path
      step_segmentation:
        in:
          use_case_directory: step_object_detection/results
          sentinel_list: step_data_search/sentinel_list
          png_output_path: step_object_detection/png_output_path
          csv_output_path: step_object_detection/csv_output_path
          verbose: verbose
          debug: debug
        run: '#segmentation_tool'
        out:
          - results
      step_medslik:
        in:
          use_case_directory: step_segmentation/results
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
          ftp_password: ftp_password
          ftp_user: ftp_user
          remote_dir: remote_dir
          cds_token: cds_token
          results: step_segmentation/results
        run: '#medslik_tool'
        out:
          - results
    outputs:
      pipeline_output:
        type: Directory
        outputSource: step_medslik/results
    s:name: Sentinel-1 Oil Spill Object Detection Pipeline 1-2-3-5
    s:description: >-
      Sentinel-1 Oil Spill Object Detection Pipeline using Deep Learning
      tecniques
    s:keywords:
      - oil spill
      - SAR
      - Sentinel-1
      - deep learning
      - object detection
    s:programmingLanguage: python
    s:softwareVersion: 1.0.0
    s:sourceOrganization:
      - class: s:Organization
        s:name: MEEO SRL
        s:url: https://meeo.it/
      - class: s:Organization
        s:name: FORTH
        s:url: https://www.forth.gr/
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
    s:author:
      - class: s:Person
        s:email: outmani@meeo.it
        s:name: Sabrina Outmani
      - class: s:Person
        s:email: fazzini@meeo.it
        s:name: Noemi Fazzini
    s:dateCreated: '2024-12-01'
    s:temporalCoverage: 2014-01-01T00:00:00Z/
    s:spatialCoverage:
      class: s:GeoShape
      s:box: '-90 -180 90 180'
    s:license: https://opensource.org/licenses/MIT
    s:citation: ''
  - class: CommandLineTool
    id: datasearch_tool
    baseCommand:
      - /srv/miniconda3/envs/oilspill001/bin/python
      - '-m'
      - oilspill001.main
    arguments:
      - valueFrom: $(inputs.bbox)
        prefix: '--bbox'
      - '--use-case-directory'
      - valueFrom: $(inputs.use_case_directory)
      - '--start-date'
      - valueFrom: $(inputs.start_date)
      - valueFrom: $(inputs.time_interval)
        prefix: '--time-interval'
      - valueFrom: |
          ${ return inputs.end_date ? '--end-date ' + inputs.end_date : '' }
      - valueFrom: |
          ${ return inputs.verbose ? '--verbose' : '' }
      - valueFrom: |
          ${ return inputs.debug ? '--debug' : '' }
      - '--asf-username'
      - valueFrom: $(inputs.asf_username)
      - '--asf-password'
      - valueFrom: $(inputs.asf_password)
    inputs:
      bbox:
        type: string?
        doc: Bounding box for image search
        s:name: Bounding Box
        s:description: Optional bounding box to restrict the image search.
      use_case_directory:
        type: string
        doc: Directory where to find input files and store outputs
        s:name: Use Case Directory
        s:description: Directory to store input and output files.
      start_date:
        type: string?
        doc: Start date for data search
        s:name: Start Date
        s:description: The start date to search for data.
      time_interval:
        type: int?
        doc: Time interval (n of days) for data search
        s:name: Time Interval
        s:description: Number of days for the data search interval.
      end_date:
        type: string?
        doc: End date for data search
        s:name: End Date
        s:description: The end date for data search (optional).
      verbose:
        type: int?
        doc: Enable verbose logging
        s:name: Verbose Logging
        s:description: Flag to enable verbose logging.
      debug:
        type: int?
        doc: Enable debug mode
        s:name: Debug Mode
        s:description: Flag to enable debug mode for additional logging.
      asf_username:
        type: string
        doc: Username for ASF
        s:name: ASF Username
        s:description: Username for the ASF platform authentication.
      asf_password:
        type: string
        doc: Password for ASF
        s:name: ASF Password
        s:description: Password for the ASF platform authentication.
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: $(inputs.use_case_directory)
      sentinel_list:
        type: File
        outputBinding:
          glob: $(inputs.use_case_directory)/raw_sentinel/sentinel_paths.txt
    requirements:
      - class: DockerRequirement
        dockerPull: >-
          iliad-repository.inesctec.pt/meeo-oilspill001:1.0.0
      - class: NetworkAccess
        networkAccess: true
      - class: InlineJavascriptRequirement
    s:name: Sentinel-1 Oil Spill Detection Data Search
    s:description: ASF search for SAR images from Sentinel-1
    s:keywords:
      - oil spill
      - SAR
      - Sentinel-1
      - ASF
    s:programmingLanguage: python
    s:softwareVersion: 1.0.0
    s:sourceOrganization:
      - class: s:Organization
        s:name: MEEO SRL
        s:url: https://meeo.it/
      - class: s:Organization
        s:name: FORTH
        s:url: https://www.forth.gr/
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
    s:author:
      - class: s:Person
        s:name: Sabrina Outmani
        s:email: outmani@meeo.it
      - class: s:Person
        s:name: Noemi Fazzini
        s:email: fazzini@meeo.it
    s:dateCreated: '2024-12-01'
    s:temporalCoverage: 2014-01-01T00:00:00Z/
    s:spatialCoverage:
      class: s:GeoShape
      s:box: '-90 -180 90 180'
    s:codeRepository: null
    s:license: https://opensource.org/licenses/MIT
    s:citation: ''
  - class: CommandLineTool
    id: preprocessing_tool
    baseCommand:
      - /srv/miniconda3/envs/oilspill002/bin/python
      - '-m'
      - oilspill002.main
    arguments:
      - '--use-case-directory'
      - valueFrom: $(inputs.use_case_directory.path)
      - '--sentinel-list'
      - valueFrom: $(inputs.sentinel_list.path)
      - valueFrom: |
          ${ return inputs.verbose ? '--verbose' : '' }
      - valueFrom: |
          ${ return inputs.debug ? '--debug' : '' }
    inputs:
      use_case_directory:
        type: Directory
        doc: Directory where to find input files and store outputs
        s:name: Use Case Directory
        s:description: Directory to store input and output files.
      sentinel_list:
        type: File
        doc: >-
          .txt file containing sentinel data paths (output from application
          package 1) - sentinel_paths.txt
        s:name: Sentinel list file
        s:description: >-
          Text file containing sentinel data paths (output from application
          package 1) - sentinel_paths.txt
      verbose:
        type: int?
        doc: Enable verbose logging
        s:name: Verbose Logging
        s:description: Flag to enable verbose logging.
      debug:
        type: int?
        doc: Enable debug mode
        s:name: Debug Mode
        s:description: Flag to enable debug mode for additional logging.
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: $(inputs.use_case_directory.path)
      db_list:
        type: File
        outputBinding:
          glob: $(inputs.use_case_directory.path)/intermediate_dir/db_paths.txt
    requirements:
      - class: InitialWorkDirRequirement
        listing:
          - entryname: $(inputs.use_case_directory.basename)
            entry: $(inputs.use_case_directory)
            writable: true
      - class: DockerRequirement
        dockerPull: >-
          iliad-repository.inesctec.pt/meeo-oilspill002:1.0.0
      - class: NetworkAccess
        networkAccess: true
      - class: InlineJavascriptRequirement
    s:name: Sentinel-1 Oil Spill Detection Pipeline Preprocessing Tool
    s:description: Pre-processing of SAR images from Sentinel-1
    s:keywords:
      - oil spill
      - SAR
      - Sentinel-1
      - snappy
    s:programmingLanguage: python
    s:softwareVersion: 1.0.0
    s:sourceOrganization:
      - class: s:Organization
        s:name: MEEO SRL
        s:url: https://meeo.it/
      - class: s:Organization
        s:name: FORTH
        s:url: https://www.forth.gr/
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
    s:author:
      - class: s:Person
        s:email: outmani@meeo.it
        s:name: Sabrina Outmani
      - class: s:Person
        s:email: fazzini@meeo.it
        s:name: Noemi Fazzini
    s:dateCreated: '2024-12-01'
    s:temporalCoverage: 2014-01-01T00:00:00Z/
    s:spatialCoverage:
      class: s:GeoShape
      s:box: '-90 -180 90 180'
    s:license: https://opensource.org/licenses/MIT
    s:citation: ''
  - class: CommandLineTool
    id: object_detection_tool
    baseCommand:
      - /srv/miniconda3/envs/oilspill003/bin/python
      - '-m'
      - oilspill003.main
    arguments:
      - '--use-case-directory'
      - valueFrom: $(inputs.use_case_directory.path)
      - '--db-list'
      - valueFrom: $(inputs.db_list.path)
      - valueFrom: |
          ${ return inputs.range ? '--range' : ''; }
        shellQuote: false
      - valueFrom: |
          ${ return inputs.verbose ? '--verbose' : '' }
      - valueFrom: |
          ${ return inputs.debug ? '--debug' : '' }
    inputs:
      use_case_directory:
        type: Directory
        doc: Directory where to find input files and store outputs
        s:name: Use Case Directory
        s:description: Directory to store input and output files.
      db_list:
        type: File
        doc: >-
          .txt file containing paths of preprocessed sentinel-1 images (output
          from application package 2) - db_paths.txt
        s:name: Db list file
        s:description: >-
          .txt file containing paths of preprocessed sentinel-1 images (output
          from application package 2) - db_paths.txt
      range:
        type: string?
        doc: optional range 0-100 for image contrast enhancement
        s:name: Range
        s:description: optional range 0-100 for image contrast enhancement
      verbose:
        type: int?
        doc: Enable verbose logging
        s:name: Verbose Logging
        s:description: Flag to enable verbose logging.
      debug:
        type: int?
        doc: Enable debug mode
        s:name: Debug Mode
        s:description: Flag to enable debug mode for additional logging.
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: $(inputs.use_case_directory.path)
      png_output_path:
        type: File
        outputBinding:
          glob: $(inputs.use_case_directory.path)/intermediate_dir/png_paths.txt
      csv_output_path:
        type: File
        outputBinding:
          glob: $(inputs.use_case_directory.path)/intermediate_dir/csv_paths.txt
    requirements:
      - class: InitialWorkDirRequirement
        listing:
          - entryname: $(inputs.use_case_directory.basename)
            entry: $(inputs.use_case_directory)
            writable: true
      - class: DockerRequirement
        dockerPull: >-
          iliad-repository.inesctec.pt/meeo-oilspill003:2.0.0
      - class: NetworkAccess
        networkAccess: true
      - class: InlineJavascriptRequirement
    s:name: Sentinel-1 Oil Spill Object Detection Pipeline
    s:description: >-
      Deep learning model designed for detecting oil spill signals globally from
      pre-processedSAR images from Sentinel-1.
    s:keywords:
      - oil spill
      - SAR
      - Sentinel-1
      - deep learning
      - object detection
    s:programmingLanguage: python
    s:softwareVersion: 1.0.0
    s:sourceOrganization:
      - class: s:Organization
        s:name: MEEO SRL
        s:url: https://meeo.it/
      - class: s:Organization
        s:name: FORTH
        s:url: https://www.forth.gr/
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
    s:author:
      - class: s:Person
        s:email: outmani@meeo.it
        s:name: Sabrina Outmani
      - class: s:Person
        s:email: fazzini@meeo.it
        s:name: Noemi Fazzini
    s:dateCreated: '2024-12-01'
    s:temporalCoverage: 2014-01-01T00:00:00Z/
    s:spatialCoverage:
      class: s:GeoShape
      s:box: '-90 -180 90 180'
    s:license: https://opensource.org/licenses/MIT
    s:citation: ''
  - class: CommandLineTool
    id: segmentation_tool
    baseCommand:
      - /srv/miniconda3/envs/oilspill005/bin/python
      - '-m'
      - oilspill005.main
    arguments:
      - '--use-case-directory'
      - valueFrom: $(inputs.use_case_directory.path)
      - '--sentinel-list'
      - valueFrom: $(inputs.sentinel_list.path)
      - '--png-output-path'
      - valueFrom: $(inputs.png_output_path.path)
      - '--csv-output-path'
      - valueFrom: $(inputs.csv_output_path.path)
      - valueFrom: |
          ${ return inputs.delete ? '--delete' : ''; }
        shellQuote: false
      - valueFrom: |
          ${ return inputs.verbose ? '--verbose' : '' }
      - valueFrom: |
          ${ return inputs.debug ? '--debug' : '' }
    inputs:
      use_case_directory:
        type: Directory
        doc: Directory where to find input files and store outputs
        s:name: Use Case Directory
        s:description: Directory to store input and output files.
      sentinel_list:
        type: File
        doc: >-
          .txt file containing sentinel data paths (output from application
          package 1) - sentinel_paths.txt
        s:name: Sentinel list file
        s:description: >-
          Text file containing sentinel data paths (output from application
          package 1) - sentinel_paths.txt
      png_output_path:
        type: File
        doc: >-
          .txt file containing png data paths (output from application package
          3) - png_paths.txt
        s:name: Png list file
        s:description: >-
          Text file containing sentinel data paths (output from application
          package 3) - png_paths.txt
      csv_output_path:
        type: File
        doc: >-
          .txt file containing csv data paths (output from application package
          3) - csv_paths.txt
        s:name: Csv list file
        s:description: >-
          Text file containing sentinel data paths (output from application
          package 3) - csv_paths.txt
      delete:
        type: int?
        doc: Enable deletion of generated auxiliary files
        s:name: null
        s:description: Enable deletion of generated auxiliary files
      verbose:
        type: int?
        doc: Enable verbose logging
        s:name: Verbose Logging
        s:description: Flag to enable verbose logging.
      debug:
        type: int?
        doc: Enable debug mode
        s:name: Debug Mode
        s:description: Flag to enable debug mode for additional logging.
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: $(inputs.use_case_directory.path)
    requirements:
      - class: InitialWorkDirRequirement
        listing:
          - entryname: $(inputs.use_case_directory.basename)
            entry: $(inputs.use_case_directory)
            writable: true
      - class: DockerRequirement
        dockerPull: >-
          iliad-repository.inesctec.pt/meeo-oilspill005:2.0.0
      - class: NetworkAccess
        networkAccess: true
      - class: InlineJavascriptRequirement
    s:name: Sentinel-1 Oil Spill Detection and Segmentation Pipeline
    s:description: >-
      Deep learning model for detection and segmentation oil spills in
      Sentinel-1 SAR images.
    s:keywords:
      - oil spill
      - SAR
      - Sentinel-1
      - deep learning
      - segmentation
    s:programmingLanguage: python
    s:softwareVersion: 1.0.0
    s:sourceOrganization:
      - class: s:Organization
        s:name: MEEO SRL
        s:url: https://meeo.it/
      - class: s:Organization
        s:name: FORTH
        s:url: https://www.forth.gr/
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
    s:author:
      - class: s:Person
        s:email: outmani@meeo.it
        s:name: Sabrina Outmani
      - class: s:Person
        s:email: fazzini@meeo.it
        s:name: Noemi Fazzini
    s:dateCreated: '2024-12-01'
    s:temporalCoverage: 2014-01-01T00:00:00Z/
    s:spatialCoverage:
      class: s:GeoShape
      s:box: '-90 -180 90 180'
    s:license: https://opensource.org/licenses/MIT
    s:citation: ''
  - class: CommandLineTool
    id: medslik_tool
    baseCommand:
      - /opt/miniconda3/envs/application/bin/python
      - /opt/MEDSLIK/RUN_medslik.py
    arguments:
      - '--use_case_directory'
      - valueFrom: $(inputs.use_case_directory.path)
      - '--cont_slick'
      - $(inputs.cont_slick)
      - '--sat'
      - $(inputs.sat)
      - '--use_high_res'
      - $(inputs.use_high_res)
      - '--min_lon'
      - $(inputs.min_lon)
      - '--max_lon'
      - $(inputs.max_lon)
      - '--min_lat'
      - $(inputs.min_lat)
      - '--max_lat'
      - $(inputs.max_lat)
      - '--lat_point'
      - $(inputs.lat_point)
      - '--lon_point'
      - $(inputs.lon_point)
      - '--date_spill'
      - $(inputs.date_spill)
      - '--spill_dur'
      - $(inputs.spill_dur)
      - '--spill_res'
      - $(inputs.spill_res)
      - '--spill_tons'
      - $(inputs.spill_tons)
      - '--username'
      - $(inputs.username)
      - '--password'
      - $(inputs.password)
      - '--ftp_server'
      - $(inputs.ftp_server)
      - '--ftp_user'
      - $(inputs.ftp_user)
      - '--ftp_password'
      - $(inputs.ftp_password)
      - '--remote_dir'
      - $(inputs.remote_dir)
      - '--cds_token'
      - $(inputs.cds_token)
    inputs:
      use_case_directory:
        type: Directory
        doc: Directory where to find input files and store outputs
        s:name: Use Case Directory
        s:description: Directory to store input and output files.
      cont_slick:
        type: string
        default: 'NO'
      sat:
        type: string
        default: 'NO'
      use_high_res:
        type: string
        default: 'NO'
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
        default: '2024-11-07T06:22:00Z'
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
      results:
        type: Directory
        inputBinding:
          position: 1
    outputs:
      results:
        outputBinding:
          glob: $(runtime.outdir)/OUT/
        type: Directory
        doc: All results
    requirements:
      - class: InlineJavascriptRequirement
      - class: DockerRequirement
        dockerPull: iliad-repository.inesctec.pt/forth-medslik-1.0
      - class: EnvVarRequirement
        envDef:
          PATH: >-
            /opt/miniconda3/envs/application/bin:/opt/conda/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      - class: NetworkAccess
        networkAccess: true
    hints:
      cwltool:Secrets:
        secrets:
          - username
          - password
          - ftp_server
          - ftp_password
    s:name: medslik
    s:softwareVersion: 0.1.0
    s:description: medslik
    s:keywords:
      - medslik
      - oil spill
    s:programmingLanguage: python
    s:sourceOrganization:
      - class: s:Organization
        s:name: FORTH
        s:url: https://forth.gr
    s:author:
      - class: s:Person
        s:email: antonisparasyris@iacm.forth.gr
        s:name: Antonios Parasyris
    s:mantainer:
      - class: s:Person
        s:email: vasmeth@iacm.forth.gr
        s:name: Vassiliki Metheniti
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: null
    s:dateCreated: '2025-01-27T16:00:00Z'
  - class: CommandLineTool
    id: extract-particles
    baseCommand: python
    arguments:
      - /opt/main.py
      - extract-particles
      - '--input-url'
      - valueFrom: $( inputs['input-file'] )
      - '--output-format'
      - valueFrom: $( inputs['output-format'] )
      - '--projection-function'
      - valueFrom: $( inputs['projection-function'] )
      - '--projection-resolution'
      - valueFrom: $( inputs['projection-resolution'] )
      - '--latitude-variable'
      - valueFrom: $( inputs['latitude-variable'] )
      - '--longitude-variable'
      - valueFrom: $( inputs["longitude-variable"] )
      - '--time-variable'
      - valueFrom: $( inputs["time-variable"] )
      - '--output-url'
      - output/particles
    inputs:
      input-file:
        type: File
      output-format:
        type: string
      projection-function:
        type: string
      projection-resolution:
        type: string
      latitude-variable:
        type: string
      longitude-variable:
        type: string
      time-variable:
        type: string
    outputs:
      result:
        type: Directory
        outputBinding:
          glob: output/particles
    requirements:
      NetworkAccess:
        networkAccess: true
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.3
    s:name: extract-particles
    s:description: extract particles frames from wp6-tools
    s:keywords:
      - wp6-tools
      - extract
      - particles
    s:programmingLanguage: python
    s:softwareVersion: 0.1.3
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
        s:name: Alexandre Valle
        s:email: alexandre.valle@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-extract-particles/wp6tools_extract_particles_0_1_3.cwl
    s:dateCreated: '2025-05-20T17:18:29Z'
  - class: CommandLineTool
    id: crop-frames
    baseCommand: python
    arguments:
      - /opt/main.py
      - crop-frames
      - '--input-url'
      - valueFrom: $( inputs['particles'])
      - '--input-format'
      - stac
      - '--frames'
      - valueFrom: $( inputs['frames'] )
      - '--output-url'
      - output/cropped
    inputs:
      particles:
        type: Directory
      frames:
        type: string
    outputs:
      result:
        type: Directory
        outputBinding:
          glob: output/cropped
    requirements:
      NetworkAccess:
        networkAccess: true
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.3
    s:name: crop-frames
    s:description: crop frames from wp6-tools
    s:keywords:
      - wp6-tools
      - crop
    s:programmingLanguage: python
    s:softwareVersion: 0.1.3
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
        s:name: Alexandre Valle
        s:email: alexandre.valle@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-crop-frames/wp6tools_crop_frames_0_1_3.cwl
    s:dateCreated: '2025-05-20T17:18:29Z'
  - class: CommandLineTool
    id: generate-contours
    baseCommand: python
    arguments:
      - /opt/main.py
      - generate-contours-at-density
      - '--input-url'
      - valueFrom: $( inputs['cropped'])
      - '--input-format'
      - stac
      - '--output-format'
      - valueFrom: $( inputs['output-format'] )
      - '--density'
      - valueFrom: $( inputs['density'] )
      - '--output-url'
      - output/contours
    inputs:
      cropped:
        type: Directory
      output-format:
        type: string
        default: json
      density:
        type: string
    outputs:
      result:
        type: Directory
        outputBinding:
          glob: output/contours
    requirements:
      NetworkAccess:
        networkAccess: true
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.3
    s:name: generate-contours
    s:description: generate contours frames from wp6-tools
    s:keywords:
      - wp6-tools
      - contours
    s:programmingLanguage: python
    s:softwareVersion: 0.1.3
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
        s:name: Alexandre Valle
        s:email: alexandre.valle@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-contours/wp6tools_generate_contours_0_1_3.cwl
    s:dateCreated: '2025-05-20T17:18:29Z'
  - class: CommandLineTool
    id: dir2files
    baseCommand: python
    arguments:
      - /opt/dir2files.py
      - '--directory'
      - valueFrom: $(inputs.input_dir)
    inputs:
      input_dir:
        type: Directory
    outputs:
      output_files:
        type: File[]
        outputBinding:
          glob: ./*
    requirements:
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/dir2files:0.1.0
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    s:name: dir2files
    s:description: Converts a directory to a list of files
    s:keywords:
      - directory
      - files
    s:programmingLanguage: python
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/dir2files/dir2files_0_1_0.cwl
    s:dateCreated: '2025-05-12T12:12:44Z'
  - class: CommandLineTool
    id: json_append_wp6tools_pipeline
    baseCommand: python
    arguments:
      - /opt/append.py
      - valueFrom: >-
          $( function () {
          var files_array = []; Object.keys(inputs.files).forEach(function
          (element) { console.log(inputs.files[element]);
          if(inputs.files[element].basename !== 'contour-header.json')
          files_array.push('--file'); files_array.push(inputs.files[element]);
          }); return files_array;
          }())
    inputs:
      files:
        type: File[]?
        doc: files
    outputs:
      result:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: appended.json
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/json-append/json_append_wp6tools_pipeline_0_1_0.cwl
    s:dateCreated: '2025-05-12T12:23:08Z'
  - class: CommandLineTool
    id: virtual-choreographies-generator
    baseCommand: python
    arguments:
      - /opt/src/command.py
      - valueFrom: $( inputs.dataset )
      - valueFrom: >-
          $( inputs.template || inputs.template_url ||
          '/opt/templates/template.json')
    inputs:
      template:
        type: File?
      template_url:
        type: string?
      dataset:
        type: File
    outputs:
      vc:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: vc.json
      recipe:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: recipe.json
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-generator:0.2.1
    s:name: virtual-choreographies-generator
    s:description: Generator of virtual choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
    s:programmingLanguage: python
    s:softwareVersion: 0.2.1
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
        s:name: Fernando Cassola
        s:email: fernando.c.marques@inesctec.pt
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:maintainer:
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-generator/virtual_choreographies_generator_0_2_1.cwl
    s:dateCreated: '2025-05-26T10:06:27Z'
  - class: CommandLineTool
    id: virtual-choreographies-transformer-plugin-unity
    baseCommand: python
    arguments:
      - /opt/src/command.py
      - valueFrom: $( inputs.vc )
      - valueFrom: >-
          $( inputs.mappings || inputs.mappings_url || '/opt/mappings/unity.j2'
          )
      - valueFrom: $( inputs.vc_recipe || inputs.vc_recipe_url )
      - valueFrom: >-
          $( inputs.platform_recipe || inputs.platform_recipe_url ||
          '/opt/recipes/platform_recipe_unity.json')
    inputs:
      vc:
        type: File
      mappings:
        type: File?
      mappings_url:
        type: string?
      vc_recipe:
        type: File?
      vc_recipe_url:
        type: File?
      platform_recipe:
        type: File?
      platform_recipe_url:
        type: File?
    outputs:
      platform_choreography:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: result/platform_choreography.json
          outputEval: ${self[0].basename="platform_choreography_unity.json"; return self;}
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: >-
          iliad-repository.inesctec.pt/virtual-choreographies-transformer-plugin:0.2.1
    s:name: virtual-choreographies-transformer-plugin-unity
    s:description: >-
      Generator of platform specific choregoraphies form generic virtual
      choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
      - transformer
    s:programmingLanguage: python
    s:softwareVersion: 0.2.1
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
        s:name: Fernando Cassola
        s:email: fernando.c.marques@inesctec.pt
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:maintainer:
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-unity/virtual_choreographies_transformer_plugin_unity_0_2_1.cwl
    s:dateCreated: '2025-05-26T10:06:27Z'
  - class: CommandLineTool
    id: virtual-choreographies-transformer-plugin-cesium
    baseCommand: python
    arguments:
      - /opt/src/command.py
      - valueFrom: $( inputs.vc )
      - valueFrom: >-
          $( inputs.mappings || inputs.mappings_url || '/opt/mappings/cesium.j2'
          )
      - valueFrom: $( inputs.vc_recipe || inputs.vc_recipe_url)
      - valueFrom: >-
          $( inputs.platform_recipe || inputs.platform_recipe_url ||
          '/opt/recipes/platform_recipe_cesium.json')
    inputs:
      vc:
        type: File
      mappings:
        type: File?
      mappings_url:
        type: string?
      vc_recipe:
        type: File?
      vc_recipe_url:
        type: File?
      platform_recipe:
        type: File?
      platform_recipe_url:
        type: File?
    outputs:
      platform_choreography:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: result/platform_choreography.json
          outputEval: >-
            ${self[0].basename="platform_choreography_cesium.json"; return
            self;}
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: >-
          iliad-repository.inesctec.pt/virtual-choreographies-transformer-plugin:0.2.1
    s:name: virtual-choreographies-transformer-plugin-cesium
    s:description: >-
      Generator of platform specific choregoraphies form generic virtual
      choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
      - transformer
    s:programmingLanguage: python
    s:softwareVersion: 0.2.1
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
        s:name: Fernando Cassola
        s:email: fernando.c.marques@inesctec.pt
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:maintainer:
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-cesium/virtual_choreographies_transformer_plugin_cesium_0_2_1.cwl
    s:dateCreated: '2025-05-26T10:06:27Z'
  - class: CommandLineTool
    id: metadata-2stact2
    baseCommand: python
    arguments:
      - /opt/main.py
      - metadata-2stac2
      - '--latitude'
      - valueFrom: $( inputs.latitude )
      - '--longitude'
      - valueFrom: $( inputs.longitude )
      - '--radius'
      - valueFrom: $( inputs.radius )
      - '--time'
      - valueFrom: $( inputs.time )
      - '--frames'
      - valueFrom: $( inputs.frames )
      - '--output-url'
      - output/metadata.json
    inputs:
      latitude:
        type: float
      longitude:
        type: float
      radius:
        type: float
      time:
        type: string
      frames:
        type: string
    outputs:
      result:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: output/metadata.json
    requirements:
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.3
    s:name: metadata-2stact2
    s:description: generate metadata from wp6-tools to the 2stac2
    s:keywords:
      - wp6-tools
      - metadata
      - 2stac2
    s:programmingLanguage: python
    s:softwareVersion: 0.1.3
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-metadata-2stac2/wp6tools_metadata_2stac2_0_1_3.cwl
    s:dateCreated: '2025-05-20T17:18:29Z'
  - class: CommandLineTool
    id: 2stac2_wp6tools_pipeline
    baseCommand: python
    arguments:
      - /opt/2stac2.py
      - valueFrom: >-
          $( function () { if (inputs["unity_choreography"]) { return ["--file",
          inputs["unity_choreography"]]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs["cesium_choreography"]) { return
          ["--file", inputs["cesium_choreography"]]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs["simulation"]) { return ["--file",
          inputs["simulation"]]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs["animation"]) { return ["--file",
          inputs["animation"]]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs["bathymetry"]) { return ["--file",
          inputs["bathymetry"]]; } else { return []; } }())
      - '--metadata'
      - valueFrom: $(runtime.outdir + '/multiple_metadata.json')
    inputs:
      unity_choreography:
        format: edam:format_3464
        doc: unity choreography json file
        type: File?
      cesium_choreography:
        format: edam:format_3464
        doc: cesium choreography json file
        type: File?
      simulation:
        format: edam:format_3650
        doc: NetCDF simulation file
        type: File?
      animation:
        format: edam:format_3467
        doc: Animation GIF file
        type: File?
      bathymetry:
        format: edam:format_3650
        doc: Bathymetry NetCDF file
        type: File?
      metadata:
        format: edam:format_3464
        doc: metadata file description
        type: File
        loadContents: true
    outputs:
      stac_result:
        outputBinding:
          glob: stac_result
        type: Directory
        doc: STAC output
    requirements:
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/2stac2:0.1.3
      InplaceUpdateRequirement:
        inplaceUpdate: true
      InitialWorkDirRequirement:
        listing: |
          ${
            const content = JSON.parse(inputs.metadata.contents);
            const metadata = [];
            if(inputs.unity_choreography) metadata.push({...content, filename: inputs.unity_choreography.basename});
            if(inputs.cesium_choreography) metadata.push({...content, filename: inputs.cesium_choreography.basename});
            if(inputs.simulation) metadata.push({...content, filename: inputs.simulation.basename});
            if(inputs.animation) metadata.push({...content, filename: inputs.animation.basename});
            if(inputs.bathymetry) metadata.push({...content, filename: inputs.bathymetry.basename});
            return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
          }
    s:name: 2stac2_wp6tools_pipeline
    s:softwareVersion: 0.1.3
    s:description: Transform and array of files into a STAC
    s:keywords:
      - stac
      - metadata
    s:programmingLanguage: python
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_wp6tools_pipeline_0_1_3.cwl
    s:dateCreated: '2025-05-21T15:08:53Z'