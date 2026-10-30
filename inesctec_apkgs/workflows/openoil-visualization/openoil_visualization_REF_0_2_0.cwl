
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: Workflow
  id: openoil_visualization_pipeline
  doc: This pipeline runs an oil spill simulation pipeline with openoil, and creates visualizations of the simulation results.
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
      default: "0,1,2,3,4,5,6,7,8,9,10"
    density:
      type: string?
      label: narratives
      default: "0.01, 0.05, 0.10, 0.50, 1.00"
  steps:
    step_simulation:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/openoil-simulation-duth/openoil_simulation_duth_0_2_0.cwl#openoil_simulation'
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
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-extract-particles/wp6tools_extract_particles_0_2_0.cwl#extract_particles'
      in:
        input-file: step_simulation/simulation
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

    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_wp6tools_pipeline_0_3_1.cwl#2stac2_wp6tools_pipeline'
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
    type:
      Directory

  hints:
    "cwltool:Secrets":
      secrets: [access_key,secret_key,session_token,password]
  requirements:
    InlineJavascriptRequirement: {}
    SubworkflowFeatureRequirement: {}

  s:name: openoil_visualization_pipeline
  s:description: |
    This pipeline runs an oil spill pipeline with openoil and creates visualizations of the simulation results.
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
  s:dateCreated: "2025-11-24T23:30:45Z"
