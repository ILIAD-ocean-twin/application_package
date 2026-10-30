cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: openoil_visualization_pipeline
    doc: >-
      This pipeline runs an oil spill simulation pipeline with openoil, and
      creates visualizations of the simulation results.
    inputs:
      lat:
        type: float
        doc: The latitude of the study area
        label: openoil
      lon:
        type: float
        doc: The longitude of the study area
        label: openoil
      time:
        type: string
        doc: The start time of the simulation
        label: openoil
      oiltype:
        type: string
        doc: The type of the oil to run the simulation
        label: openoil
      duration:
        type: int
        doc: The simulation duration
        label: openoil
      username:
        type: string
        doc: The CMEMS username
        label: cmems_credentials
      password:
        type: string
        doc: The CMEMS password
        label: cmems_credentials
    steps:
      step_openoil:
        run: '#openoil_pipeline'
        in:
          lat: lat
          lon: lon
          time: time
          oiltype: oiltype
          duration: duration
          username: username
          password: password
        out:
          - wf_outputs
      step_select_nc_file:
        run: '#step_select_nc_file'
        in:
          dir: step_openoil/wf_outputs
        out:
          - extracted_file
      step_netcdf_visualization:
        run: '#netcdf_visualization_pipeline'
        in:
          netcdf_file: step_select_nc_file/extracted_file
          frames:
            default: 0,1,2,3,4,5,6,7,8,9,10
          density:
            default: 0.01, 0.05, 0.10, 0.50, 1.00
        out:
          - wf_outputs
    outputs:
      - id: wf_outputs
        outputSource:
          - step_netcdf_visualization/wf_outputs
        type: Directory
    hints:
      cwltool:Secrets:
        secrets:
          - access_key
          - secret_key
          - session_token
          - password
    requirements:
      InlineJavascriptRequirement: {}
      SubworkflowFeatureRequirement: {}
    s:name: openoil_visualization_pipeline
    s:description: >
      This pipeline runs an oil spill pipeline with openoil and creates
      visualizations of the simulation results.
    s:keywords:
      - oil spill
      - openoil
      - opendrift
      - visualization
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
    s:dateCreated: '2025-11-18T15:50:05Z'
  - class: ExpressionTool
    id: step_select_nc_file
    inputs:
      dir:
        type: Directory
        loadListing: deep_listing
    outputs:
      extracted_file:
        type: File
    expression: |
      ${
          const dir = inputs.dir.listing.find(f => f.basename && f.basename === "item_simulation");
          const ncFile = dir.listing.find(f => f.nameroot === "simulation" && f.nameext === ".nc");
          ncFile.format = "http://edamontology.org/format_3650";
          return { extracted_file: ncFile };
      }
  - class: Workflow
    id: openoil_pipeline
    doc: >-
      This pipeline runs an oil spill simulation with openoil, creates an
      animation of the simulation and stores it in S3.
    inputs:
      lat:
        type: float
        doc: The latitude of the study area
        label: openoil
      lon:
        type: float
        doc: The longitude of the study area
        label: openoil
      time:
        type: string
        doc: The start time of the simulation
        label: openoil
      oiltype:
        type: string
        doc: The type of the oil to run the simulation
        label: openoil
      duration:
        type: int
        doc: The simulation duration
        label: openoil
      username:
        type: string
        doc: The CMEMS username
        label: cmems_credentials
      password:
        type: string
        doc: The CMEMS password
        label: cmems_credentials
      animation:
        type: boolean?
        doc: Run (or not) the animation step
        label: openoil
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
        default: openoil_pipeline
        label: s3storage
    steps:
      step_simulation:
        run: '#openoil_simulation'
        in:
          lat: lat
          lon: lon
          time: time
          oiltype: oiltype
          duration: duration
          username: username
          password: password
        out:
          - simulation
          - metadata
      step_animation:
        when: $(inputs.animation == true || inputs.animation == "true")
        run: '#openoil_animation'
        in:
          file: step_simulation/simulation
          animation: animation
        out:
          - animation
      step_2stac2:
        run: '#2stac2_openoil_pipeline'
        in:
          animation: step_animation/animation
          simulation: step_simulation/simulation
          metadata: step_simulation/metadata
        out:
          - stac_result
      step_2s3:
        run: '#2s3'
        when: $(inputs.endpoint != null && inputs.endpoint != "")
        in:
          region: region
          endpoint: endpoint
          access_key: access_key
          secret_key: secret_key
          session_token: session_token
          bucket: bucket
          directory: step_2stac2/stac_result
          base_path: base_path
        out:
          - base_path
    outputs:
      - id: wf_outputs
        outputSource:
          - step_2stac2/stac_result
        type: Directory
    hints:
      cwltool:Secrets:
        secrets:
          - access_key
          - secret_key
          - session_token
          - password
    requirements:
      InlineJavascriptRequirement: {}
    s:name: openoil_pipeline
    s:description: >
      This pipeline runs an oil spill simulation with openoil, creates an
      animation of the simulation and stores it in S3.


      The animation step is optional:
          - If the input animation is set to false, the animation step is skipped.
          - The default value is true (run the animation step).

      The step of saving the results to S3 is optional:
          - if the input endpoint is not set, the S3 step is skipped.
    s:keywords:
      - oil spill
      - openoil
      - opendrift
      - animation
    s:softwareVersion: 0.3.0
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
    s:dateCreated: '2025-11-18T12:53:35Z'
  - class: CommandLineTool
    id: openoil_simulation
    baseCommand: python
    arguments:
      - /opt/openoil.py
      - '--lat'
      - valueFrom: $( inputs.lat )
      - '--lon'
      - valueFrom: $( inputs.lon )
      - '--time'
      - valueFrom: $( inputs.time )
      - '--oiltype'
      - valueFrom: $( inputs.oiltype )
      - '--duration'
      - valueFrom: $( inputs.duration )
      - '--username'
      - valueFrom: $( inputs.username )
      - '--password'
      - valueFrom: $( inputs.password )
    inputs:
      lat:
        type: float
        doc: The latitude of the study area
      lon:
        type: float
        doc: The longitude of the study area
      time:
        type: string
        doc: The start time of the simulation
      oiltype:
        type: string
        doc: The type of the oil to run the simulation
      duration:
        type: int
        doc: The simulation duration
      username:
        type: string
        doc: The CMEMS username
      password:
        type: string
        doc: The CMEMS password
    outputs:
      simulation:
        format: edam:format_3650
        type: File
        outputBinding:
          glob: result/simulation.nc
      metadata:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: result/metadata.json
        doc: metadata description
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/openoil-simulation-duth:0.2.0
    hints:
      cwltool:Secrets:
        secrets:
          - password
    s:name: openoil_simulation
    s:description: Simulation of oil spill
    s:keywords:
      - oil spill
      - openoil
      - opendrift
    s:programmingLanguage: python
    s:softwareVersion: 0.2.0
    s:producer:
      class: s:Organization
      s:name: D.U.TH
      s:url: https://env.duth.gr
      s:address:
        class: s:PostalAddress
        s:addressCountry: GR
    s:sourceOrganization:
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
        s:address:
          class: s:PostalAddress
          s:addressCountry: PT
      - class: s:Organization
        s:name: D.U.TH
        s:url: https://env.duth.gr
        s:address:
          class: s:PostalAddress
          s:addressCountry: GR
    s:author:
      - class: s:Person
        s:name: Georgios Sylaios
        s:email: gsylaios@env.duth.gr
      - class: s:Person
        s:name: Nikolaos Kokkos
        s:email: nikolaoskokkos@gmail.com
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:dateCreated: '2025-11-17T11:38:11Z'
  - class: CommandLineTool
    id: openoil_animation
    baseCommand: python
    arguments:
      - /opt/animation.py
      - '--file'
      - valueFrom: $( inputs.file )
    inputs:
      file:
        format: edam:format_3650
        type: File
        doc: The netcdf file containing the simulation results
    outputs:
      animation:
        format: edam:format_3467
        type: File
        outputBinding:
          glob: result/animation.gif
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/openoil-animation-duth:0.2.0
    s:name: openoil_animation
    s:description: Animation of oil spill simulation
    s:keywords:
      - oil spill
      - animation
      - simulation
      - openoil
      - opendrift
    s:programmingLanguage: python
    s:softwareVersion: 0.2.0
    s:producer:
      class: s:Organization
      s:name: D.U.TH
      s:url: https://env.duth.gr
      s:address:
        class: s:PostalAddress
        s:addressCountry: GR
    s:sourceOrganization:
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
        s:address:
          class: s:PostalAddress
          s:addressCountry: PT
      - class: s:Organization
        s:name: D.U.TH
        s:url: https://env.duth.gr
        s:address:
          class: s:PostalAddress
          s:addressCountry: GR
    s:author:
      - class: s:Person
        s:name: Georgios Sylaios
        s:email: gsylaios@env.duth.gr
      - class: s:Person
        s:name: Nikolaos Kokkos
        s:email: nikolaoskokkos@gmail.com
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:dateCreated: '2025-11-13T15:38:01Z'
  - class: CommandLineTool
    id: 2stac2_openoil_pipeline
    baseCommand: python
    arguments:
      - /opt/2stac2.py
    inputs:
      simulation:
        format: edam:format_3650
        doc: simulation NetCDF file
        type: File
        inputBinding:
          prefix: '--file'
      animation:
        format: edam:format_3467
        doc: animation Gif file
        type: File?
        inputBinding:
          prefix: '--file'
      metadata:
        format: edam:format_3464
        doc: metadata file description
        type: File
        loadContents: true
        inputBinding:
          prefix: '--metadata'
          valueFrom: $(runtime.outdir + '/multiple_metadata.json')
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
        dockerPull: iliad-repository.inesctec.pt/2stac2:0.3.1
      InplaceUpdateRequirement:
        inplaceUpdate: true
      InitialWorkDirRequirement:
        listing: |
          ${
            const content = JSON.parse(inputs.metadata.contents);
            const metadata = [];
            metadata.push({...content, filename:inputs["simulation"].basename});
            if(inputs["animation"] != null) {
              metadata.push({...content, filename:inputs["animation"].basename , media_type:"image/gif" });
            }
            return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
          }
    s:name: 2stac2_openoil_pipeline
    s:softwareVersion: 0.3.1
    s:description: >-
      2stac2 tool to transform OpenOil simulation and animation files into a
      STAC
    s:keywords:
      - stac
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
    s:dateCreated: '2025-11-17T16:08:31Z'
  - class: CommandLineTool
    id: 2s3
    baseCommand: python
    arguments:
      - /opt/2s3.py
      - '--endpoint'
      - valueFrom: $( inputs.endpoint )
      - '--access_key'
      - valueFrom: $( inputs.access_key )
      - '--secret_key'
      - valueFrom: $( inputs.secret_key )
      - '--bucket'
      - valueFrom: $( inputs.bucket )
      - '--endpoint'
      - valueFrom: $( inputs.endpoint )
      - valueFrom: >-
          $( function () { if (inputs.region) { return ["--region",
          inputs.region]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs.base_path) { return ["--base_path",
          `${inputs.base_path}_${new Date().toISOString().replace(/:/g,
          '').replace(/\-/g, '').split('.')[0]}`]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs.session_token) { return
          ["--session_token", inputs.session_token]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if(inputs.files) { var files_array = [];

          Object.keys(inputs.files).forEach(function (element) {
          files_array.push('--file'); files_array.push(inputs.files[element]);
          });

          return files_array; } else { return []; } }())
      - valueFrom: >-
          $( function () { if(inputs.directories) { var directories_array = [];

          Object.keys(inputs.directories).forEach(function (element) {
          directories_array.push('--directory');
          directories_array.push(inputs.directories[element]); });

          return directories_array; } else { return []; } }())
      - valueFrom: >-
          $( function () { if(inputs.file) { return ['--file', inputs.file]; }
          else { return []; } }())
      - valueFrom: >-
          $( function () { if(inputs.directory) { return ['--directory',
          inputs.directory]; } else { return []; } }())
    inputs:
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
      files:
        type: File[]?
        doc: Multiple files to upload
      directories:
        type: Directory[]?
        doc: Multiple directories to upload
      directory:
        type: Directory?
        doc: Single directory to upload
      file:
        type: File?
        doc: Single file to upload
    outputs:
      base_path:
        type: string
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/2s3:0.1.0
    hints:
      cwltool:Secrets:
        secrets:
          - access_key
          - secret_key
          - session_token
    s:name: 2s3
    s:description: Uploads files and/or folders to a S3 bucket storage.
    s:keywords:
      - s3
      - storage
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
    s:dateCreated: '2025-11-13T16:51:16Z'
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
      s3_bucket_name:
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
        format: edam:format_3650
      frames:
        type: string
        label: narratives
      density:
        type: string
        label: narratives
    steps:
      step_get_file:
        run: '#get_netcdf_file'
        in:
          filename:
            default: simulation.nc
          file: netcdf_file
          s3_endpoint: s3_endpoint
          s3_region: s3_region
          s3_access_key: s3_access_key
          s3_secret_key: s3_secret_key
          s3_session_token: s3_session_token
          s3_bucket_name: s3_bucket_name
          s3_path: s3_path
        out:
          - file_output
      step_extract_particles:
        run: '#extract_particles'
        in:
          input-file: step_get_file/file_output
          output-format:
            default: stac
          projection-function:
            default: none
          projection-resolution:
            default: none
          latitude-variable:
            default: lat
          longitude-variable:
            default: lon
          time-variable:
            default: time
        out:
          - result
      step_crop_frames:
        run: '#crop_frames'
        in:
          particles: step_extract_particles/result
          frames: frames
        out:
          - result
      step_generate_contours:
        run: '#generate_contours'
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
        run: '#virtual_choreographies_generator'
        in:
          dataset: json_append/result
        out:
          - vc
          - recipe
      step_virtual_choreographies_unity_plugin:
        run: '#virtual_choreographies_transformer_plugin_unity'
        in:
          vc: step_virtual_choreographies_generator/vc
          vc_recipe: step_virtual_choreographies_generator/recipe
        out:
          - platform_choreography
      step_virtual_choreographies_cesium_plugin:
        run: '#virtual_choreographies_transformer_plugin_cesium'
        in:
          vc: step_virtual_choreographies_generator/vc
          vc_recipe: step_virtual_choreographies_generator/recipe
        out:
          - platform_choreography
      step_netcdf_metadata:
        in:
          netcdf_file: step_get_file/file_output
        run: '#netcdf_metadata'
        out:
          - metadata
      step_2stac2:
        run: '#2stac2_wp6tools_pipeline'
        in:
          unity_choreography: step_virtual_choreographies_cesium_plugin/platform_choreography
          cesium_choreography: step_virtual_choreographies_unity_plugin/platform_choreography
          simulation: step_get_file/file_output
          contours: json_append/result
          metadata: step_netcdf_metadata/metadata
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
          - access_key
          - secret_key
          - session_token
    requirements:
      InlineJavascriptRequirement: {}
    s:name: netcdf_visualization_pipeline
    s:description: netcdf visualization pipeline
    s:keywords:
      - oil spill
      - netcdf
      - choreographies
      - virtual choreographies
      - wp6
      - tools
    s:softwareVersion: 0.1.1
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
    s:dateCreated: '2025-11-18T12:52:56Z'
  - class: CommandLineTool
    id: get_netcdf_file
    baseCommand: python
    arguments:
      - /opt/get-file.py
      - '--filename'
      - valueFrom: $( inputs.filename )
      - valueFrom: |
          ${ return inputs.file ? ["--file", inputs.file] : [] }
      - valueFrom: >
          ${ return inputs.s3_endpoint ? ["--s3_endpoint", inputs.s3_endpoint] :
          [] }
      - valueFrom: |
          ${ return inputs.s3_region ? ["--s3_region", inputs.s3_region] : [] }
      - valueFrom: >
          ${ return inputs.s3_access_key ? ["--s3_access_key",
          inputs.s3_access_key] : [] }
      - valueFrom: >
          ${ return inputs.s3_secret_key ? ["--s3_secret_key",
          inputs.s3_secret_key] : [] }
      - valueFrom: >
          ${ return inputs.s3_session_token ? ["--s3_session_token",
          inputs.s3_session_token] : [] }
      - valueFrom: >
          ${ return inputs.s3_bucket_name ? ["--s3_bucket",
          inputs.s3_bucket_name] : [] }
      - valueFrom: |
          ${ return inputs.s3_path ? ["--s3_path", inputs.s3_path] : [] }
    inputs:
      filename:
        type: string
        doc: Name of the output file
      file:
        type:
          - string?
          - File?
        doc: URL to download the file or local path
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
        doc: S3 path to file
    outputs:
      file_output:
        format: edam:format_3650
        type: File
        outputBinding:
          glob: $(inputs.filename)
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/get-file:0.1.1
    s:name: get_netcdf_file
    s:description: Tool to download a NetCDF file from a URL or S3 storage
    s:keywords:
      - s3
      - netcdf
      - storage
    s:programmingLanguage: python
    s:softwareVersion: 0.1.1
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
    s:dateCreated: '2025-11-17T17:28:44Z'
  - class: CommandLineTool
    id: extract_particles
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
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0
    s:name: extract_particles
    s:description: extract particles frames from wp6-tools
    s:keywords:
      - wp6-tools
      - extract
      - particles
    s:programmingLanguage: python
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
        s:name: Alexandre Valle
        s:email: alexandre.valle@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:dateCreated: '2025-10-29T22:16:49Z'
  - class: CommandLineTool
    id: crop_frames
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
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0
    s:name: crop_frames
    s:description: crop frames from wp6-tools
    s:keywords:
      - wp6-tools
      - crop
    s:programmingLanguage: python
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
        s:name: Alexandre Valle
        s:email: alexandre.valle@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:dateCreated: '2025-10-29T22:16:49Z'
  - class: CommandLineTool
    id: generate_contours
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
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0
    s:name: generate_contours
    s:description: generate contours frames from wp6-tools
    s:keywords:
      - wp6-tools
      - contours
    s:programmingLanguage: python
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
        s:name: Alexandre Valle
        s:email: alexandre.valle@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:dateCreated: '2025-10-29T22:16:49Z'
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
    s:dateCreated: '2025-11-13T17:08:43Z'
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
    s:dateCreated: '2025-11-13T17:32:08Z'
  - class: CommandLineTool
    id: virtual_choreographies_generator
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
        dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-generator:0.3.0
    s:name: virtual_choreographies_generator
    s:description: Generator of virtual choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
    s:programmingLanguage: python
    s:softwareVersion: 0.3.0
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
    s:codeRepository: https://iliad.inesctec.pt/mite/
    s:dateCreated: '2025-11-13T21:55:58Z'
  - class: CommandLineTool
    id: virtual_choreographies_transformer_plugin_unity
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
          iliad-repository.inesctec.pt/virtual-choreographies-transformer-plugin:0.3.0
    s:name: virtual_choreographies_transformer_plugin_unity
    s:description: >-
      Generator of platform specific choregoraphies form generic virtual
      choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
      - transformer
    s:programmingLanguage: python
    s:softwareVersion: 0.3.0
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
    s:codeRepository: https://iliad.inesctec.pt/mite/
    s:dateCreated: '2025-11-13T21:55:58Z'
  - class: CommandLineTool
    id: virtual_choreographies_transformer_plugin_cesium
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
          iliad-repository.inesctec.pt/virtual-choreographies-transformer-plugin:0.3.0
    s:name: virtual_choreographies_transformer_plugin_cesium
    s:description: >-
      Generator of platform specific choregoraphies form generic virtual
      choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
      - transformer
    s:programmingLanguage: python
    s:softwareVersion: 0.3.0
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
    s:codeRepository: https://iliad.inesctec.pt/mite/
    s:dateCreated: '2025-11-13T21:55:58Z'
  - class: CommandLineTool
    id: netcdf_metadata
    baseCommand: python
    arguments:
      - /opt/parse.py
      - '--netcdf_file'
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
        format: edam:format_3464
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
    s:dateCreated: '2025-11-13T17:39:29Z'
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
      - valueFrom: >-
          $( function () { if (inputs["contours"]) { return ["--file",
          inputs["contours"]]; } else { return []; } }())
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
      contours:
        format: edam:format_3464
        doc: Contours file
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
        dockerPull: iliad-repository.inesctec.pt/2stac2:0.3.1
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
            if(inputs.contours) metadata.push({...content, filename: inputs.contours.basename});
            return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
          }
    s:name: 2stac2_wp6tools_pipeline
    s:softwareVersion: 0.3.1
    s:description: 2stac2 for WP6 tools pipeline
    s:keywords:
      - stac
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
    s:dateCreated: '2025-11-17T16:08:31Z'
