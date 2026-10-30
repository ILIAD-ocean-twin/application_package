cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
$graph:
  - class: CommandLineTool
    id: openoil_booms
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
        doc: Total number of hours to run the simulation for
        inputBinding:
          prefix: --duration_hours
      particles:
        type: int?
        doc: Number of particles used to represent the oil slick. More particles provide higher detail but require more computation time
        inputBinding:
          prefix: --number
      oil_type:
        type: string?
        doc: Type of oil spilled. This determines its physical and chemical properties
        inputBinding:
          prefix: --oil_type
      mass:
        type: int?
        doc: Total mass of oil spilled in kilograms
        inputBinding:
          prefix: --total_mass_kg
      density:
        type: double?
        doc: Mass per unit volume of the oil
        inputBinding:
          prefix: --density
      viscosity:
        type: double?
        doc: Oil's resistance to flow. 1 cSt = 1e-6 m²/s
        inputBinding:
          prefix: --viscosity
      oil_source:
        type: string?
        doc: Pre-defined oil from the NOAA ADIOS database
        inputBinding:
          prefix: --oil_source
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
        doc: Result interval. Cannot be smaller than time step
        inputBinding:
          prefix: --time_step_output
      booms:
        type:
          type: array
          items:
            type: record
            fields:
              coordinates:
                type:
                  type: array
                  items:
                    type: record
                    fields:
                      latitude: double
                      longitude: double
                doc: List of [longitude, latitude] pairs defining the curtain polyline
              type: string
              overrides:
                type:
                  type: record
                  fields:
                    description: string?
                    structural_type: string?
                    freeboard_height_m: double?
                    skirt_depth_m: double?
                    anchor_strength_N: double?
                    critical_froude_number: double?
                    entrainment_coefficient: double?
                    entrainment_critical_velocity_ms: double?
                    viscosity_damping_factor: double?
                    splashover_factor: double?
                    buoyancy_to_weight_ratio: double?
                    drag_coeff: double?
                    wave_force_coeff: double?
                    critical_accumulation_viscosity_cst: double?
                    critical_accumulation_froude: double?
                    absorption_rate: double?
                    capacity_kg_per_m: double?
                    accumulation_factor: double?
                    wave_period_factor: double?
                    accumulation_width_m: double?
                    restoring_force_per_m: double?
                doc: Optional override parameters
        doc: List of containment booms
        inputBinding:
          valueFrom: >
            $(JSON.stringify(self.map(
              function (boom) {
                return { 
                  ...boom,
                  coordinates: boom.coordinates.map(
                    function ({longitude, latitude}) {
                      return [longitude, latitude];
                    }
                  )
                };
              }
            )))
          prefix: --boom
          position: 1
    outputs:
      map:
        type: File
        doc: Map of particles
        outputBinding:
          glob: map.png
      result:
        type: File
        doc: Result NetCDF file
        outputBinding:
          glob: results.nc
      simulation:
        type: File
        doc: Video of particle simulation
        outputBinding:
          glob: simulation.mp4
      simulation_currents:
        type: File?
        doc: Video of particle simulation with currents data
        outputBinding:
          glob: initial_simulation_with_currents.mp4
      statistics:
        type: File
        doc: Extra process data
        outputBinding:
          glob: statistics.json
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/openoil-booms:0.2.0
    s:name: openoil_booms
    s:description: OpenOil with Booms
    s:keywords:
      - opendrift
      - openoil
      - booms
    s:programmingLanguage: python
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
        s:name: Joao Campos
        s:email: joao.campos@inesctec.pt
    s:dateCreated: "2025-11-28T14:28:35Z"
