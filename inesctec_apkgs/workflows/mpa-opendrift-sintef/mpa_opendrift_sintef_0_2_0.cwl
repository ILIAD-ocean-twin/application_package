cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/
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
        run: '#mpa_sintef'
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
        run: '#netcdf_metadata'
        in:
          netcdf_file: step_simulation/simulation
        out:
          - metadata
      step_2stac2:
        run: '#2stac2_mpa_pipeline'
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
        type: Directory
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
    s:codeRepository: >-
      https://github.com/ILIAD-ocean-twin/application_package/tree/main/mpa-norway
    s:dateCreated: '2025-11-25T11:28:32Z'
  - class: CommandLineTool
    id: mpa_sintef
    baseCommand: python
    arguments:
      - /mpa/runnorkystforecast.py
    inputs:
      aqua_site_file:
        type: string
        doc: aqua_site_file
        inputBinding:
          prefix: '--aqua_site_file'
      aqua_site_distances_files:
        type: string
        doc: aqua_site_distances_files
        inputBinding:
          prefix: '--aqua_site_distances_files'
      aqua_opendrift_particles_per_site:
        type: int
        doc: aqua_opendrift_particles_per_site
        inputBinding:
          prefix: '--aqua_opendrift_particles_per_site'
      aqua_opendrift_simulation_duration_hours:
        type: int
        doc: aqua_opendrift_simulation_duration_hours
        inputBinding:
          prefix: '--aqua_opendrift_simulation_duration_hours'
      aqua_connectivity_number_of_neighbours:
        type: int
        doc: aqua_connectivity_number_of_neighbours
        inputBinding:
          prefix: '--aqua_connectivity_number_of_neighbours'
      aqua_connectivity_radius:
        type: int
        doc: aqua_connectivity_radius
        inputBinding:
          prefix: '--aqua_connectivity_radius'
      starttime:
        type: string?
        doc: The start time of the simulation
        inputBinding:
          prefix: '--starttime'
    outputs:
      simulation:
        format: edam:format_3650
        type: File
        outputBinding:
          glob: modeloutput/salmon_midnor.nc
      connectivity:
        format: edam:format_3620
        type: File
        outputBinding:
          glob: modeloutput/salmon_midnor_connectivity.xlsx
      connectivity_with_locality_id:
        format: edam:format_3620
        type: File
        outputBinding:
          glob: modeloutput/salmon_midnor_connectivity_withLocalityId.xlsx
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/mpa-sintef:0.2.0
    s:name: mpa_sintef
    s:description: >-
      Runs (i) OpenDrift, and (ii) the connectivity analysis for aquaculture
      sites in Norway using the NorKyst800 model data, for Marine Protected
      Areas (MPAs).
    s:keywords:
      - opendrift
      - mpa
      - aquaculture
      - connectivity
      - norway
      - norkyst800
    s:programmingLanguage: python
    s:softwareVersion: 0.2.0
    s:producer:
      class: s:Organization
      s:name: SINTEF OCEAN
      s:url: https://sintef.no/en/ocean/
      s:address:
        class: s:PostalAddress
        s:addressCountry: 'NO'
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
          s:addressCountry: 'NO'
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
    s:codeRepository: >-
      https://github.com/ILIAD-ocean-twin/application_package/tree/main/mpa-norway
    s:dateCreated: '2025-11-25T11:24:32Z'
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
    id: 2stac2_mpa_pipeline
    baseCommand: python
    arguments:
      - /opt/2stac2.py
    inputs:
      simulation:
        format: edam:format_3650
        doc: simulation NetCDF file
        type: File
        inputBinding:
          prefix: '--file'
      connectivity:
        format: edam:format_3620
        doc: connectivity file
        type: File?
        inputBinding:
          prefix: '--file'
      connectivity_with_locality_id:
        format: edam:format_3620
        doc: connectivity with locality id
        type: File?
        inputBinding:
          prefix: '--file'
      metadata:
        format: edam:format_3464
        doc: metadata file description
        type: File
        loadContents: true
        inputBinding:
          prefix: '--metadata'
          valueFrom: $(runtime.outdir + '/multiple_metadata.json')
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
            metadata.push({...content, filename:inputs["simulation"].basename});
            metadata.push({...content, filename:inputs["connectivity"].basename , media_type:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"});
            metadata.push({...content, filename:inputs["connectivity_with_locality_id"].basename , media_type:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"});
            return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
          }
    s:name: 2stac2_mpa_pipeline
    s:softwareVersion: 0.3.1
    s:description: 2stac2 tool to transform MPA simulation files into a STAC
    s:keywords:
      - stac
      - metadata
      - mpa
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
