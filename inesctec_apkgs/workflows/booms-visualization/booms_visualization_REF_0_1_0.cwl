
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: Workflow
  id: booms_visualization_pipeline
  doc: This pipeline runs an oil spill simulation pipeline with openoil, and creates visualizations of the simulation results.
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
          Number of particles used to represent the oil slick.
          More particles provide higher detail, require more computation time
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
        doc: Type of oil spilled. This determines its physical and chemical properties
      booms:
        type: string
        doc: List of containment booms
      density:
        type: double?
        doc: Oil density values
      viscosity:
        type: double?
        doc: Oil viscosity values
      # visualization_frames:
      #   type: string?
      #   label: narratives
      #   default: "0,1,2,3,4,5,6,7,8,9,10"
      # visualization_density:
      #   type: string?
      #   label: narratives
      #   default: "0.01, 0.05, 0.10, 0.50, 1.00"
  steps:
    step_simulation:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/openoil-booms/openoil_booms_0_4_0.cwl#openoil_booms'
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
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/netcdf-metadata/netcdf_metadata_0_1_0.cwl#netcdf_metadata'
      in:
        netcdf_file: step_simulation/result
      out:
      - metadata
    # step_extract_particles:
    #   run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-extract-particles/wp6tools_extract_particles_0_2_0.cwl#extract_particles'
    #   in:
    #     input-file: step_simulation/result
    #     output-format:
    #       default: "stac"
    #     projection-function:
    #       default: "none"
    #     projection-resolution:
    #       default: "none"
    #     latitude-variable:
    #       default: "lat"
    #     longitude-variable:
    #       default: "lon"
    #     time-variable:
    #       default: "time"
    #   out:
    #   - result
    # step_crop_frames:
    #   run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-crop-frames/wp6tools_crop_frames_0_2_0.cwl#crop_frames'
    #   in:
    #     particles: step_extract_particles/result
    #     frames: visualization_frames
    #   out:
    #   - result
    # step_generate_contours:
    #   run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-contours/wp6tools_generate_contours_0_2_0.cwl#generate_contours'
    #   in:
    #     cropped: step_crop_frames/result
    #     density: visualization_density
    #     output-format:
    #       default: "json"
    #   out:
    #   - result
    # dir2files:
    #   run: 'https://pipe-drive.inesctec.pt/application-packages/tools/dir2files/dir2files_0_1_0.cwl#dir2files'
    #   in:
    #     input_dir: step_generate_contours/result
    #   out:
    #   - output_files
    # json_append:
    #   run: 'https://pipe-drive.inesctec.pt/application-packages/tools/json-append/json_append_wp6tools_pipeline_0_1_0.cwl#json_append_wp6tools_pipeline'
    #   in:
    #     files: dir2files/output_files
    #   out:
    #   - result

    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_openoil_pipeline_0_3_1.cwl#2stac2_openoil_pipeline'
      in:
        simulation: step_simulation/result
        # contours: json_append/result
        metadata: step_netcdf_metadata/metadata
      out:
      - stac_result

  outputs:
  # - id: wf_outputs1
  #   outputSource:
  #   - step_simulation/map
  #   type:
  #     File
  # - id: wf_outputs2
  #   outputSource:
  #   - step_simulation/result
  #   type:
  #     File
  # - id: wf_outputs3
  #   outputSource:
  #   - step_simulation/simulation
  #   type:
  #     File
  # - id: wf_outputs4
  #   outputSource:
  #   - step_simulation/simulation_currents
  #   type:
  #     File
  - id: wf_outputs
    outputSource:
    - step_2stac2/stac_result
    type:
      Directory

  hints:
    "cwltool:Secrets":
      secrets: [access_key,secret_key,session_token,password]
  requirements:
    InlineJavascriptRequirement: {}
    SubworkflowFeatureRequirement: {}

  s:name: booms_visualization_pipeline
  s:description: |
    This pipeline runs an oil spill pipeline with openoil and creates visualizations of the simulation results.
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
  s:dateCreated: "2025-12-04T10:49:31Z"
