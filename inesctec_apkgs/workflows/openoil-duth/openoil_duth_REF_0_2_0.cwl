
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/

$graph:

- class: Workflow
  id: openoil_pipeline
  doc: This pipeline runs an oil spill simulation with openoil, creates an animation of the simulation and stores it in S3.
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
    animation:
      default: true
      type: boolean?
      doc: Run (or not) the animation step
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
      default: "openoil_pipeline"

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
    step_animation:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/openoil-animation-duth/openoil_animation_duth_0_2_0.cwl#openoil_animation'
      when: $(inputs.animation == true || inputs.animation == "true")
      in:
        file: step_simulation/simulation
        animation: animation
      out:
      - animation
    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_openoil_pipeline_0_2_0.cwl#2stac2_openoil_pipeline'
      in:
        animation: step_animation/animation
        simulation: step_simulation/simulation
        metadata: step_simulation/metadata
      out:
      - stac_result
    step_2s3:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2s3/2s3_0_2_0.cwl#2s3'
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
    type:
      Directory

  hints:
    "cwltool:Secrets":
      secrets: [username,password]
  requirements:
    InlineJavascriptRequirement: {}

  s:name: openoil_pipeline
  s:description: |
    This pipeline runs an oil spill simulation with openoil, creates an animation of the simulation and stores it in S3.

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
  s:softwareVersion: 0.2.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/openoil-duth/openoil_duth_REF_0_2_0.cwl
  s:dateCreated: "2025-02-10T11:20:53Z"