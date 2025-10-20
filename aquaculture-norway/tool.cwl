cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:

- class: CommandLineTool

  id: aquaculture_sintef

  baseCommand: python
  arguments:
   - /aquaculturedemo/runnorkystforecast.py
  inputs:
    aqua_site_file:
      type: string
      doc: aqua_site_file
      inputBinding:
        prefix: --aqua_site_file
    aqua_site_distances_files:
      type: string
      doc: aqua_site_distances_files
      inputBinding:
        prefix: --aqua_site_distances_files
    aqua_opendrift_particles_per_site:
      type: int
      doc: aqua_opendrift_particles_per_site
      inputBinding:
        prefix: --aqua_opendrift_particles_per_site
    aqua_opendrift_simulation_duration_hours:
      type: int
      doc: aqua_opendrift_simulation_duration_hours
      inputBinding:
        prefix: --aqua_opendrift_simulation_duration_hours
    aqua_connectivity_number_of_neighbours:
      type: int
      doc: aqua_connectivity_number_of_neighbours
      inputBinding:
        prefix: --aqua_connectivity_number_of_neighbours
    aqua_connectivity_radius:
      type: int
      doc: aqua_connectivity_radius
      inputBinding:
        prefix: --aqua_connectivity_radius
    starttime:
      type: string?
      doc: The start time of the simulation
      inputBinding:
        prefix: --starttime

  outputs:
    simulation:
      format: edam:format_3650 # NetCDF
      type: File
      outputBinding:
        glob: "modeloutput/salmon_midnor.nc"
    connectivity:
      format: edam:format_3620 # xlsx
      type: File
      outputBinding:
        glob: "modeloutput/salmon_midnor_connectivity.xlsx"
    connectivity_with_locality_id:
      format: edam:format_3620 # xlsx
      type: File
      outputBinding:
        glob: "modeloutput/salmon_midnor_connectivity_withLocalityId.xlsx"

  requirements:
    NetworkAccess:
      networkAccess: true
    EnvVarRequirement:
      envDef:
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/aquaculture-sintef:0.1.3

  s:name: aquaculture_sintef
  s:description: Runs (i) OpenDrift, and (ii) calculates the connectivity matrix for nearby aquaculture sites. The script outputs trajectories from OpenDrift and the connectivity matrix between sites. OpenDrift uses the Norkyst800 ocean model.
  s:keywords:
    - opendrift
    - aquaculture
    - connectivity
    - norway
    - norkyst800
  s:programmingLanguage: python
  s:softwareVersion: 0.1.3
  s:producer:
    class: s:Organization
    s:name: SINTEF OCEAN
    s:url: https://sintef.no/en/ocean/
    s:address:
        class: s:PostalAddress
        s:addressCountry: "NO"
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
          class: s:PostalAddress
          s:addressCountry: PT
    - class: s:Organization
      s:name: SINTEF OCEAN
      s:url: https://sintef.no/en/ocean/
      s:address:
          class: s:PostalAddress
          s:addressCountry: "NO"
  s:author:
    - class: s:Person
      s:name: Raymond Nepstad
      s:email: raymond.nepstad@sintef.no
    - class: s:Person
      s:name: Volker Hoffmann
      s:email: volker.hoffmann@sintef.no
    - class: s:Person
      s:name: Antoine Pultier
      s:email: antoine.pultier@sintef.no
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/aquaculture-sintef
  s:dateCreated: "2025-10-20T10:43:34Z"
