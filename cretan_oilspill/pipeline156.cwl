cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool

$graph:

- class: Workflow
  id: oilspill_pipeline_medslik_156
  doc: Oil Spill Detection and Analysis Pipeline 1-2-3-4, Medslik forecasting

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
      type: boolean?
    debug:
      doc: Enable debug mode
      type: boolean?
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
      run: "#datasearch_tool"
      out:
        - results
        - sentinel_list

    step_preprocessing:
      in:
        use_case_directory: step_data_search/results
        sentinel_list: step_data_search/sentinel_list  
        verbose: verbose
        debug: debug
      run: "#preprocessing_tool"
      out:
        - results
        - db_list

    step_object_detection:
      in:
        use_case_directory: step_preprocessing/results
        db_list: step_preprocessing/db_list
        verbose: verbose
        debug: debug
      run: "#object_detection_tool"
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
      run: "#segmentation_tool"
      out:
        - results # This contains the .tif file in SAT/

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
      run: "#medslik_tool"
      out:
        - results
        
  outputs:
    pipeline_output:
      type: Directory
      outputSource: step_medslik/results
  
  s:name: Sentinel-1 Oil Spill Object Detection Pipeline 1-2-3-4
  s:description: Sentinel-1 Oil Spill Object Detection Pipeline using Deep Learning tecniques
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
  s:dateCreated: "2024-12-01"
  s:temporalCoverage: "2014-01-01T00:00:00Z/"
  s:spatialCoverage:
    class: s:GeoShape
    s:box: "-90 -180 90 180"
  s:license: https://opensource.org/licenses/MIT
  s:citation: ""


- class: CommandLineTool
  
  id: datasearch_tool

  baseCommand:
    - /srv/miniconda3/envs/oilspill001/bin/python
    - -m
    - oilspill001.main
  
  arguments:
    - valueFrom: "$(inputs.bbox)"
      prefix: "--bbox"
    - --use-case-directory
    - valueFrom: "$(inputs.use_case_directory)"
    - --start-date
    - valueFrom: "$(inputs.start_date)"
    - valueFrom: "$(inputs.time_interval)"
      prefix: "--time-interval"
    - valueFrom: "$(inputs.end_date)"
      prefix: "--end-date"
    - valueFrom: "$(inputs.verbose)"
      prefix: "--verbose"
    - valueFrom: "$(inputs.debug)"
      prefix: "--debug"
    - --asf-username
    - valueFrom: "$(inputs.asf_username)"
    - --asf-password
    - valueFrom: "$(inputs.asf_password)"

  
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
      type: boolean?
      doc: Enable verbose logging
      s:name: Verbose Logging
      s:description: Flag to enable verbose logging.
    debug:
      type: boolean?
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
      dockerPull:  registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill001:1.0.0 
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
  s:dateCreated: "2024-12-01"
  s:temporalCoverage: "2014-01-01T00:00:00Z/"
  s:spatialCoverage:
    class: s:GeoShape
    s:box: "-90 -180 90 180"
  s:codeRepository: 
  s:license: https://opensource.org/licenses/MIT
  s:citation: ""

- class: CommandLineTool
  
  id: preprocessing_tool

  baseCommand:
    - /srv/miniconda3/envs/oilspill002/bin/python
    - -m
    - oilspill002.main
  arguments:
  - --use-case-directory
  - valueFrom: "$(inputs.use_case_directory.path)"
  - --sentinel-list
  - valueFrom: "$(inputs.sentinel_list.path)"
  - valueFrom: |
      ${ return inputs.verbose ? '--verbose' : ''; }
    shellQuote: false
  - valueFrom: |
      ${ return inputs.debug ? '--debug' : ''; }
    shellQuote: false

  inputs:
    use_case_directory:
      type: Directory
      doc: Directory where to find input files and store outputs
      s:name: Use Case Directory
      s:description: Directory to store input and output files.
    sentinel_list:
      type: File
      doc: .txt file containing sentinel data paths (output from application package 1) - sentinel_paths.txt
      s:name: Sentinel list file
      s:description: Text file containing sentinel data paths (output from application package 1) - sentinel_paths.txt
    verbose:
      type: boolean?
      doc: Enable verbose logging
      s:name: Verbose Logging
      s:description: Flag to enable verbose logging.
    debug:
      type: boolean?
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
      dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill002:1.0.0
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
  s:dateCreated: "2024-12-01"
  s:temporalCoverage: "2014-01-01T00:00:00Z/"
  s:spatialCoverage:
    class: s:GeoShape
    s:box: "-90 -180 90 180"
  s:license: https://opensource.org/licenses/MIT
  s:citation: ""
  
- class: CommandLineTool
  
  id: object_detection_tool
  
  baseCommand:
    - /srv/miniconda3/envs/oilspill003/bin/python
    - -m
    - oilspill003.main

  arguments:
  - --use-case-directory
  - valueFrom: "$(inputs.use_case_directory.path)"
  - --db-list
  - valueFrom: "$(inputs.db_list.path)"
  - valueFrom: |
      ${ return inputs.range ? '--range' : ''; }
    shellQuote: false
  - valueFrom: |
      ${ return inputs.verbose ? '--verbose' : ''; }
    shellQuote: false
  - valueFrom: |
      ${ return inputs.debug ? '--debug' : ''; }
    shellQuote: false

  inputs:
    use_case_directory:
      type: Directory
      doc: Directory where to find input files and store outputs
      s:name: Use Case Directory
      s:description: Directory to store input and output files.
    db_list:
      type: File
      doc: .txt file containing paths of preprocessed sentinel-1 images (output from application package 2) - db_paths.txt
      s:name: Db list file
      s:description: .txt file containing paths of preprocessed sentinel-1 images (output from application package 2) - db_paths.txt
    range:
      type: string?
      doc: optional range 0-100 for image contrast enhancement
      s:name: Range
      s:description: optional range 0-100 for image contrast enhancement
    verbose:
      type: boolean?
      doc: Enable verbose logging
      s:name: Verbose Logging
      s:description: Flag to enable verbose logging.
    debug:
      type: boolean?
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
      dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill003:2.0.0
    - class: NetworkAccess
      networkAccess: true
    - class: InlineJavascriptRequirement

  s:name: Sentinel-1 Oil Spill Object Detection Pipeline
  s:description: Deep learning model designed for detecting oil spill signals globally from pre-processedSAR images from Sentinel-1.
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
  s:dateCreated: "2024-12-01"
  s:temporalCoverage: "2014-01-01T00:00:00Z/"
  s:spatialCoverage:
    class: s:GeoShape
    s:box: "-90 -180 90 180"
  s:license: https://opensource.org/licenses/MIT
  s:citation: ""



- class: CommandLineTool
  
  id: segmentation_tool

  baseCommand:
    - /srv/miniconda3/envs/oilspill005/bin/python
    - -m
    - oilspill005.main
  
  arguments:
  - --use-case-directory
  - valueFrom: "$(inputs.use_case_directory.path)"
  - --sentinel-list
  - valueFrom: "$(inputs.sentinel_list.path)"
  - --png-output-path
  - valueFrom: "$(inputs.png_output_path.path)"
  - --csv-output-path
  - valueFrom: "$(inputs.csv_output_path.path)"
  - valueFrom: |
      ${ return inputs.delete ? '--delete' : ''; }
    shellQuote: false
  - valueFrom: |
      ${ return inputs.verbose ? '--verbose' : ''; }
    shellQuote: false
  - valueFrom: |
      ${ return inputs.debug ? '--debug' : ''; }
    shellQuote: false

  inputs:
    use_case_directory:
      type: Directory
      doc: Directory where to find input files and store outputs
      s:name: Use Case Directory
      s:description: Directory to store input and output files.
    sentinel_list:
      type: File
      doc: .txt file containing sentinel data paths (output from application package 1) - sentinel_paths.txt
      s:name: Sentinel list file
      s:description: Text file containing sentinel data paths (output from application package 1) - sentinel_paths.txt
    png_output_path:
      type: File
      doc: .txt file containing png data paths (output from application package 3) - png_paths.txt
      s:name: Png list file
      s:description: Text file containing sentinel data paths (output from application package 3) - png_paths.txt
    csv_output_path:
      type: File
      doc: .txt file containing csv data paths (output from application package 3) - csv_paths.txt
      s:name: Csv list file
      s:description: Text file containing sentinel data paths (output from application package 3) - csv_paths.txt
    delete:
      type: boolean?
      doc: Enable deletion of generated auxiliary files
      s:name:
      s:description: Enable deletion of generated auxiliary files
    verbose:
      type: boolean?
      doc: Enable verbose logging
      s:name: Verbose Logging
      s:description: Flag to enable verbose logging.
    debug:
      type: boolean?
      doc: Enable debug mode
      s:name: Debug Mode
      s:description: Flag to enable debug mode for additional logging.
  
  outputs:
    results:
      type: Directory
      outputBinding:
        glob: "$(inputs.use_case_directory.path)"

  requirements:
    - class: InitialWorkDirRequirement
      listing:
        - entryname: $(inputs.use_case_directory.basename)
          entry: $(inputs.use_case_directory)
          writable: true
    - class: DockerRequirement
      dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill005:1.0.0
    - class: NetworkAccess
      networkAccess: true
    - class: InlineJavascriptRequirement

  s:name: Sentinel-1 Oil Spill Detection and Segmentation Pipeline 
  s:description: Deep learning model for detection and segmentation oil spills in Sentinel-1 SAR images.
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
  s:dateCreated: "2024-12-01"
  s:temporalCoverage: "2014-01-01T00:00:00Z/"
  s:spatialCoverage:
    class: s:GeoShape
    s:box: "-90 -180 90 180"
  s:license: https://opensource.org/licenses/MIT
  s:citation: ""

- class: CommandLineTool

  id: medslik_tool

  baseCommand:
    - /opt/miniconda3/envs/application/bin/python
    - /opt/MEDSLIK/RUN_medslik.py

  arguments:
  - --use_case_directory
  - valueFrom: "$(inputs.use_case_directory.path)"
  - --cont_slick
  - $(inputs.cont_slick)
  - --sat
  - $(inputs.sat)
  - --use_high_res
  - $(inputs.use_high_res)
  - --min_lon
  - $(inputs.min_lon)
  - --max_lon
  - $(inputs.max_lon)
  - --min_lat
  - $(inputs.min_lat)
  - --max_lat
  - $(inputs.max_lat)
  - --lat_point
  - $(inputs.lat_point)
  - --lon_point
  - $(inputs.lon_point)
  - --date_spill
  - $(inputs.date_spill)
  - --spill_dur
  - $(inputs.spill_dur)
  - --spill_res
  - $(inputs.spill_res)
  - --spill_tons
  - $(inputs.spill_tons)
  - --username
  - $(inputs.username)
  - --password
  - $(inputs.password)
  - --ftp_server
  - $(inputs.ftp_server)
  - --ftp_user
  - $(inputs.ftp_user)
  - --ftp_password
  - $(inputs.ftp_password)
  - --remote_dir
  - $(inputs.remote_dir)
  - --cds_token
  - $(inputs.cds_token)

  inputs:
    use_case_directory:
      type: Directory
      doc: Directory where to find input files and store outputs
      s:name: Use Case Directory
      s:description: Directory to store input and output files.
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
    results:
      type: Directory
      inputBinding:
        position: 1
      
  outputs:
    results:
      outputBinding:
        glob: "$(runtime.outdir)/OUT/"
      type: Directory
      doc: All results
      
  requirements:
    - class: InlineJavascriptRequirement
    - class: DockerRequirement
      dockerPull: antonisparasyris/iliad:medslik-1.0
    - class: EnvVarRequirement
      envDef:
        PATH: /opt/miniconda3/envs/application/bin:/opt/conda/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    - class: NetworkAccess
      networkAccess: true
  hints:
    "cwltool:Secrets":
      secrets: [username, password, ftp_server, ftp_password]

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
  s:codeRepository: 
  s:dateCreated: "2025-01-27T16:00:00Z"
