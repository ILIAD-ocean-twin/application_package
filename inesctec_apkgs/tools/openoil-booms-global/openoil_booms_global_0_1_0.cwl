cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/
$graph:
  - class: CommandLineTool
    id: openoil_booms_global
    baseCommand:
      - python
      - /opt/headless.py
    inputs:
      latitude:
        type: double
        doc: Spill center latitude (WGS-84)
        inputBinding:
          prefix: --lat
      longitude:
        type: double
        doc: Spill center longitude (WGS-84)
        inputBinding:
          prefix: --lon
      radius:
        type: int
        doc: Initial radius of the oil spill on the sea surface
        inputBinding:
          prefix: --radius
      start_time:
        type: string
        doc: Calendar date and time when the spill begins (UTC)
        inputBinding:
          prefix: --start_time
      duration:
        type: int
        doc: Total number of hours to simulate
        inputBinding:
          prefix: --duration_hours
      particles:
        type: int?
        doc: >-
          Number of particles used to represent the oil slick.
          More particles provide higher detail, require more computation time
        inputBinding:
          prefix: --number
      mass:
        type: int?
        doc: Total mass of oil spilled in kilograms
        inputBinding:
          prefix: --total_mass_kg
      reader_ocean:
        type: string?
        doc: THREDDS or OPeNDAP URL for ocean currents data
        inputBinding:
          prefix: --reader_ocean
      reader_wave:
        type: string?
        doc: THREDDS or OPeNDAP URL for wave data
        inputBinding:
          prefix: --reader_wave
      reader_wind:
        type: string?
        doc: THREDDS or OPeNDAP URL for wind data
        inputBinding:
          prefix: --reader_wind
      time_step:
        type: int?
        doc: Model's internal calculation interval
        inputBinding:
          prefix: --time_step
      time_step_output:
        type: int?
        doc: Result interval. Must be greater than time_step
        inputBinding:
          prefix: --time_step_output
      oil_type:
        type: string?
        doc: Type of oil spilled. This determines its physical and chemical properties
        inputBinding:
          prefix: --oil_type
      density:
        type: double?
        doc: Mass per unit volume of the oil
        inputBinding:
          prefix: --density
      viscosity:
        type: double?
        doc: Oil's resistance to flow
        inputBinding:
          prefix: --viscosity
      booms:
        type: string?
        doc: List of containment booms
        inputBinding:
          prefix: --boom
          position: 1
      username:
        type: string
        doc: CMEMS username
        inputBinding:
          prefix: --username
      password:
        type: string
        doc: CMEMS password
        inputBinding:
          prefix: --password

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
        dockerPull: iliad-repository.inesctec.pt/openoil-booms-global:0.1.0
    s:name: openoil_booms_global
    s:description: OpenOil with Booms Global
    s:keywords:
      - opendrift
      - openoil
      - booms
    s:programmingLanguage: python
    s:softwareVersion: "0.1.0"
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
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.correia@inesctec.pt
    s:dateCreated: "2026-02-20T12:12:55Z"