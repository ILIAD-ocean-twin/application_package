cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/
$graph:
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
        default: true
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
        run: '#openoil_animation'
        when: $(inputs.animation == true || inputs.animation == "true")
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
      https://pipe-drive.inesctec.pt/application-packages/workflows/openoil-duth/openoil_duth_0_1_0.cwl
    s:dateCreated: '2025-05-26T10:20:55Z'
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
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/openoil-simulation-duth:0.1.0
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
    s:softwareVersion: 0.1.0
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/openoil-simulation-duth/openoil_simulation_duth_0_1_0.cwl
    s:dateCreated: '2025-05-12T12:31:30Z'
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
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/openoil-animation-duth:0.1.0
    s:name: openoil_animation
    s:description: Animation of oil spill simulation
    s:keywords:
      - oil spill
      - animation
      - simulation
      - openoil
      - opendrift
    s:programmingLanguage: python
    s:softwareVersion: 0.1.0
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/openoil-animation-duth/openoil_animation_duth_0_1_0.cwl
    s:dateCreated: '2025-05-12T12:29:29Z'
  - class: CommandLineTool
    id: 2stac2_openoil_pipeline
    baseCommand: python
    arguments:
      - /opt/2stac2.py
      - '--file'
      - valueFrom: $(inputs.simulation)
      - valueFrom: >-
          $( function () { if (inputs.animation) { return ["--file",
          inputs.animation]; } else { return []; } }())
      - '--metadata'
      - valueFrom: $(runtime.outdir + '/multiple_metadata.json')
    inputs:
      simulation:
        format: edam:format_3650
        doc: simulation NetCDF file
        type: File
      animation:
        format: edam:format_3467
        doc: animation Gif file
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
        dockerPull: iliad-repository.inesctec.pt/2stac2:0.1.0
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
    s:softwareVersion: 0.1.0
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
      https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_openoil_pipeline_0_1_0.cwl
    s:dateCreated: '2025-03-15T07:53:14Z'
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/2s3/2s3_0_1_0.cwl
    s:dateCreated: '2025-05-12T11:03:57Z'
