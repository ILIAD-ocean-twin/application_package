cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: booms_visualization_pipeline
    doc: >-
      This pipeline runs an oil spill simulation pipeline with openoil, and
      creates visualizations of the simulation results.
    inputs:
      latitude:
        type: double
        doc: Spill center latitude (WGS-84)
      longitude:
        type: double
        doc: Spill center longitude (WGS-84)
      radius:
        type: int
        doc: Initial radius of the oil spill on the sea surface
      start_time:
        type: string
        doc: Calendar date and time when the spill begins (UTC)
      duration:
        type: int
        doc: Total number of hours to simulate
      particles:
        type: int?
        doc: >-
          Number of particles used to represent the oil slick. More particles
          provide higher detail, require more computation time
      mass:
        type: int?
        doc: Total mass of oil spilled in kilograms
      reader_ocean:
        type: string?
        doc: THREDDS or OPeNDAP URL for ocean currents data
      reader_wave:
        type: string?
        doc: THREDDS or OPeNDAP URL for wave data
      reader_wind:
        type: string?
        doc: THREDDS or OPeNDAP URL for wind data
      time_step:
        type: int?
        doc: Model's internal calculation interval
      time_step_output:
        type: int?
        doc: Result interval. Must be greater than time_step
      oil_type:
        type: string?
        doc: >-
          Type of oil spilled. This determines its physical and chemical
          properties
      booms:
        type: string?
        doc: List of containment booms
      density:
        type: double?
        doc: Oil density values
      viscosity:
        type: double?
        doc: Oil viscosity values
      visualization_frames:
        type: string?
        label: narratives
        default: 0,1,2,3,4,5,6,7,8,9,10
      visualization_density:
        type: string?
        label: narratives
        default: 0.01, 0.05, 0.10, 0.50, 1.00
    steps:
      step_simulation:
        run: '#openoil_booms'
        in:
          latitude: latitude
          longitude: longitude
          radius: radius
          start_time: start_time
          duration: duration
          particles: particles
          mass: mass
          reader_ocean: reader_ocean
          reader_wave: reader_wave
          reader_wind: reader_wind
          time_step: time_step
          time_step_output: time_step_output
          oil_type: oil_type
          booms: booms
          density: density
          viscosity: viscosity
        out:
          - map
          - result
          - simulation
          - simulation_currents
      step_netcdf_metadata:
        run: '#netcdf_metadata'
        in:
          netcdf_file: step_simulation/result
        out:
          - metadata
      step_extract_particles:
        run: '#extract_particles'
        in:
          input-file: step_simulation/result
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
          frames: visualization_frames
        out:
          - result
      step_generate_contours:
        run: '#generate_contours'
        in:
          cropped: step_crop_frames/result
          density: visualization_density
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
          simulation: step_simulation/result
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
          - password
    requirements:
      InlineJavascriptRequirement: {}
      SubworkflowFeatureRequirement: {}
    s:name: booms_visualization_pipeline
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
    s:dateCreated: '2025-12-05T16:40:11Z'
  - class: CommandLineTool
    id: openoil_booms
    baseCommand:
      - python
      - /opt/headless.py
    inputs:
      latitude:
        type: double
        doc: Spill center latitude (WGS-84)
        inputBinding:
          prefix: '--lat'
      longitude:
        type: double
        doc: Spill center longitude (WGS-84)
        inputBinding:
          prefix: '--lon'
      radius:
        type: int
        doc: Initial radius of the oil spill on the sea surface
        inputBinding:
          prefix: '--radius'
      start_time:
        type: string
        doc: Calendar date and time when the spill begins (UTC)
        inputBinding:
          prefix: '--start_time'
      duration:
        type: int
        doc: Total number of hours to simulate
        inputBinding:
          prefix: '--duration_hours'
      particles:
        type: int?
        doc: >-
          Number of particles used to represent the oil slick. More particles
          provide higher detail, require more computation time
        inputBinding:
          prefix: '--number'
      mass:
        type: int?
        doc: Total mass of oil spilled in kilograms
        inputBinding:
          prefix: '--total_mass_kg'
      reader_ocean:
        type: string?
        doc: THREDDS or OPeNDAP URL for ocean currents data
        inputBinding:
          prefix: '--reader_ocean'
      reader_wave:
        type: string?
        doc: THREDDS or OPeNDAP URL for wave data
        inputBinding:
          prefix: '--reader_wave'
      reader_wind:
        type: string?
        doc: THREDDS or OPeNDAP URL for wind data
        inputBinding:
          prefix: '--reader_wind'
      time_step:
        type: int?
        doc: Model's internal calculation interval
        inputBinding:
          prefix: '--time_step'
      time_step_output:
        type: int?
        doc: Result interval. Must be greater than time_step
        inputBinding:
          prefix: '--time_step_output'
      oil_type:
        type: string?
        doc: >-
          Type of oil spilled. This determines its physical and chemical
          properties
        inputBinding:
          prefix: '--oil_type'
      density:
        type: double?
        doc: Mass per unit volume of the oil
        inputBinding:
          prefix: '--density'
      viscosity:
        type: double?
        doc: Oil's resistance to flow
        inputBinding:
          prefix: '--viscosity'
      booms:
        type: string?
        doc: List of containment booms
        inputBinding:
          prefix: '--boom'
          position: 1
    outputs:
      map:
        type: File
        format: edam:format_3603
        doc: Map of particles
        outputBinding:
          glob: map.png
      result:
        type: File
        format: edam:format_3650
        doc: Result NetCDF file
        outputBinding:
          glob: results.nc
      simulation:
        type: File
        format: edam:format_3997
        doc: Video of particle simulation
        outputBinding:
          glob: simulation.mp4
      simulation_currents:
        type: File?
        format: edam:format_3997
        doc: Video of particle simulation with currents data
        outputBinding:
          glob: initial_simulation_with_currents.mp4
      statistics:
        type: File
        format: edam:format_3464
        doc: Extra process data
        outputBinding:
          glob: statistics.json
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/openoil-booms:0.4.0
    s:name: openoil_booms
    s:description: OpenOil with Booms
    s:keywords:
      - opendrift
      - openoil
      - booms
    s:programmingLanguage: python
    s:softwareVersion: 0.4.0
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
        s:name: Joao Campos
        s:email: joao.campos@inesctec.pt
    s:dateCreated: '2025-12-04T09:02:27Z'
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
