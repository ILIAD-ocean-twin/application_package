
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: Workflow
  id: mpa_ditto_summit_lundy_pipeline
  doc: This pipeline runs the mpa simulation.
  inputs:
    startdate:
      type: string
      doc: The start time of the simulation
    duration:
      type: int
      doc: The duration of the simulation
    username:
      type: string
      doc: The CMEMS username
    password:
      type: string
      doc: The CMEMS password
  steps:
    step_simulation:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/mpa-ditto-summit-lundy/mpa_ditto_summit_lundy_0_1_1.cwl#mpa_ditto_summit_lundy'
      in:
        startdate: startdate
        duration: duration
        username: username
        password: password
      out:
      - simulation
    step_metadata:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/netcdf-metadata/netcdf_metadata_0_1_0.cwl#netcdf_metadata'
      in:
        netcdf_file: step_simulation/simulation
      out:
      - metadata
    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_mpa_pipeline_0_3_2.cwl#2stac2_mpa_pipeline'
      in:
        simulation: step_simulation/simulation
        metadata: step_metadata/metadata
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
      secrets: [password]
  requirements:
    InlineJavascriptRequirement: {}

  s:name: mpa_ditto_summit_lundy_pipeline
  s:description: |
    This pipeline runs an mpa simulation with Opendrift.
  s:keywords:
    - mpa
    - opendrift
    - simulation
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
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/tree/main/mpa-norway
  s:dateCreated: "2026-10-31T03:04:54Z"
