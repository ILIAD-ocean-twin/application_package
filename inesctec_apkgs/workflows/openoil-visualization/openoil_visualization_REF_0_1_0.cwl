
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

  steps:
    step_openoil:
      run: 'https://pipe-drive.inesctec.pt/application-packages/workflows/openoil-duth/openoil_duth_REF_0_3_0.cwl#openoil_pipeline'
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
      run: 'https://pipe-drive.inesctec.pt/application-packages/workflows/netcdf-visualization/netcdf_visualization_REF_0_1_1.cwl#netcdf_visualization_pipeline'
      in:
        netcdf_file: step_select_nc_file/extracted_file
        frames:
          default: "0,1,2,3,4,5,6,7,8,9,10"
        density:
          default: "0.01, 0.05, 0.10, 0.50, 1.00"

      out:
      - wf_outputs
  outputs:
  - id: wf_outputs
    outputSource:
    - step_netcdf_visualization/wf_outputs
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
  s:dateCreated: "2025-11-18T15:50:05Z"


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