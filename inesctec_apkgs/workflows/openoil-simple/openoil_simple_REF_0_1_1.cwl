
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: Workflow
  id: openoil_simple_pipeline
  doc: This pipeline runs an oil spill simulation with openoil.
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
    step_simulation:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/openoil-global/openoil_global_0_1_0.cwl#openoil_global'
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
    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_openoil_pipeline_0_3_1.cwl#2stac2_openoil_pipeline'
      in:
        simulation: step_simulation/simulation
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

  s:name: openoil_simple_pipeline
  s:description: |
    This pipeline runs an oil spill simulation with openoil.
  s:keywords:
    - oil spill
    - openoil
    - opendrift
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
  s:dateCreated: "2026-10-30T22:13:31Z"
