
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: Workflow
  id: mpa_opendrift_pipeline
  doc: This pipeline runs the mpa_opendrift simulation.
  inputs:
    aqua_site_file:
      type: string
      doc: aqua_site_file
    aqua_site_distances_files:
      type: string
      doc: aqua_site_distances_files
    aqua_opendrift_particles_per_site:
      type: int
      doc: aqua_opendrift_particles_per_site
    aqua_opendrift_simulation_duration_hours:
      type: int
      doc: aqua_opendrift_simulation_duration_hours
    aqua_connectivity_number_of_neighbours:
      type: int
      doc: aqua_connectivity_number_of_neighbours
    aqua_connectivity_radius:
      type: int
      doc: aqua_connectivity_radius
    starttime:
      type: string?
      doc: The start time of the simulation
  steps:
    step_simulation:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/mpa-sintef/mpa_sintef_0_2_0.cwl#mpa_sintef'
      in:
        aqua_site_file: aqua_site_file
        aqua_site_distances_files: aqua_site_distances_files
        aqua_opendrift_particles_per_site: aqua_opendrift_particles_per_site
        aqua_opendrift_simulation_duration_hours: aqua_opendrift_simulation_duration_hours
        aqua_connectivity_number_of_neighbours: aqua_connectivity_number_of_neighbours
        aqua_connectivity_radius: aqua_connectivity_radius
        starttime: starttime
      out:
      - simulation
      - connectivity
      - connectivity_with_locality_id
    step_metadata:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/netcdf-metadata/netcdf_metadata_0_1_0.cwl#netcdf_metadata'
      in:
        netcdf_file: step_simulation/simulation
      out:
      - metadata
    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_mpa_pipeline_0_3_1.cwl#2stac2_mpa_pipeline'
      in:
        simulation: step_simulation/simulation
        connectivity: step_simulation/connectivity
        connectivity_with_locality_id: step_simulation/connectivity_with_locality_id
        metadata: step_metadata/metadata
      out:
      - stac_result
  outputs:
  - id: wf_outputs
    outputSource:
    - step_2stac2/stac_result
    type:
      Directory

  requirements:
    InlineJavascriptRequirement: {}

  s:name: mpa_opendrift_pipeline
  s:description: |
    This pipeline runs an mpa simulation with Opendrift.
  s:keywords:
    - mpa
    - opendrift
    - simulation
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
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/tree/main/mpa-norway
  s:dateCreated: "2025-11-25T11:28:32Z"
