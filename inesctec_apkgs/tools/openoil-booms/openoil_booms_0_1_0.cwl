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
      lat:
        type: float
        doc:
        inputBinding:
          prefix: --lat
      lon:
        type: float
        doc:
        inputBinding:
          prefix: --lon
      radius:
        type: int
        doc:
        inputBinding:
          prefix: --radius
      start_time:
        type: string
        doc:
        inputBinding:
          prefix: --start_time
      duration_hours:
        type: int
        doc:
        inputBinding:
          prefix: --duration_hours
      number:
        type: int?
        doc:
        inputBinding:
          prefix: --number
      oil_type:
        type: string?
        doc:
        inputBinding:
          prefix: --oil_type
      total_mass_kg:
        type: int?
        doc:
        inputBinding:
          prefix: --total_mass_kg
      density:
        type: float?
        doc:
        inputBinding:
          prefix: --density
      viscosity:
        type: float?
        doc:
        inputBinding:
          prefix: --viscosity
      oil_source:
        type: string?
        doc:
        inputBinding:
          prefix: --oil_source
      reader_ocean:
        type: string?
        doc:
        inputBinding:
          prefix: --reader_ocean
      reader_wave:
        type: string?
        doc:
        inputBinding:
          prefix: --reader_wave
      reader_wind:
        type: string?
        doc:
        inputBinding:
          prefix: --reader_wind
      time_step:
        type: int?
        doc:
        inputBinding:
          prefix: --time_step
      time_step_output:
        type: int?
        doc:
        inputBinding:
          prefix: --time_step_output
      boom:
        type: string[]?
        doc:
        inputBinding:
          prefix: --boom
    outputs:
      map:
        type: File
        doc:
        outputBinding:
          glob: map.png
      result:
        type: File
        doc:
        outputBinding:
          glob: results.nc
      simulation:
        type: File
        doc:
        outputBinding:
          glob: simulation.mp4
      simulation_currents:
        type: File
        doc:
        outputBinding:
          glob: initial_simulation_with_currents.mp4
      statistics:
        type: File
        doc:
        outputBinding:
          glob: statistics.json
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/openoil-booms:0.1.0
    s:name: openoil_booms
    s:description: OpenOil with Booms
    s:keywords:
      - opendrift
      - openoil
      - booms
    s:programmingLanguage: python
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
        s:name: Joao Campos
        s:email: joao.campos@inesctec.pt
    s:dateCreated: "2025-11-26T15:20:09Z"
