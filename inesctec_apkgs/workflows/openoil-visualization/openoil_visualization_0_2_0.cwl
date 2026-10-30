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
      frames:
        type: string?
        label: narratives
        default: 0,1,2,3,4,5,6,7,8,9,10
      density:
        type: string?
        label: narratives
        default: 0.01, 0.05, 0.10, 0.50, 1.00
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
      step_extract_particles:
        run: '#extract_particles'
        in:
          input-file: step_simulation/simulation
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
      step_2stac2:
        run: '#2stac2_wp6tools_pipeline'
        in:
          simulation: step_simulation/simulation
          contours: json_append/result
          metadata: step_simulation/metadata
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
    s:dateCreated: '2025-11-24T23:30:45Z'
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
