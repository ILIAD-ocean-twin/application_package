cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/

$graph:
- class: Workflow
  id: d52_openoil_pipeline
  doc: This pipeline runs an oil spill simulation with openoil.
  inputs:
    lat:
      label: openoil
      type: float
      doc: The latitude of the study area
    lon:
      label: openoil
      type: float
      doc: The longitude of the study area
    time:
      label: openoil
      type: string
      doc: The start time of the simulation
    oiltype:
      label: openoil
      type: string
      doc: The type of the oil to run the simulation
    duration:
      label: openoil
      type: int
      doc: The simulation duration
    username:
      label: cmems
      type: string
      doc: The CMEMS username
    password:
      label: cmems
      type: string
      doc: The CMEMS password

  steps:
    step_simulation:
      run: '#openoil_simulation'
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

    step_2stac:
      run: '#2stac'
      in:
        result: step_simulation/simulation
        metadata: step_simulation/metadata
      out:
      - results

  outputs:
  - id: wf_outputs
    outputSource:
    - step_2stac/results
    type:
      Directory
  hints:
    "cwltool:Secrets":
      secrets: ["password"]

  requirements:
    InlineJavascriptRequirement: {}

  s:identifier: urn:apkg:workflow:d.u.th:gr:d52_openoil_pipeline:0.2.0
  s:name: openOil pipeline
  s:description: |
    This pipeline runs an oil spill simulation with openoil.
  s:keywords:
    - oil spill
    - openoil
    - opendrift
  s:softwareVersion: 0.2.0
  s:programmingLanguage: python
  s:producer:
    class: s:Organization
    s:name: D.U.TH
    s:url: https://env.duth.gr
    s:address:
      class: s:PostalAddress
      s:addressCountry: GR
  s:sourceOrganization:
    - class: s:Organization
      s:name: D.U.TH
      s:url: https://env.duth.gr
      s:address:
        class: s:PostalAddress
        s:addressCountry: GR
  s:author:
    - class: s:Person
      s:name: Georgios Sylaios
      s:email: gsylaios@env.duth.gr
  s:maintainer:
    - class: s:Person
      s:name: Nikolaos Kokkos
      s:email: nikolaoskokkos@gmail.com
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/refs/heads/main/inesctec_apkgs/d52.cwl
  s:license: https://opensource.org/licenses/MIT
  s:temporalCoverage: 2024-01-01T00:00:00Z/2024-12-31T23:59:59Z
  s:spatialCoverage:
    class: s:geo
    s:box: 40.25 23.00 41.0 25.80

- class: CommandLineTool

  id: openoil_simulation

  baseCommand: python
  arguments:
  - /opt/openoil.py
  - --lat
  - valueFrom: $( inputs.lat )
  - --lon
  - valueFrom: $( inputs.lon )
  - --time
  - valueFrom: $( inputs.time )
  - --oiltype
  - valueFrom: $( inputs.oiltype )
  - --duration
  - valueFrom: $( inputs.duration )
  - --username
  - valueFrom: $( inputs.username )
  - --password
  - valueFrom: $( inputs.password )

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

  outputs:
    simulation:
      type: File
      format: edam:format_3650 # NetCDF
      outputBinding:
        glob: "result/simulation.nc"
    metadata:
      type: File
      format: edam:format_3464 # JSON
      outputBinding:
        glob: "result/metadata.json"
      doc: metadata description

  requirements:
    NetworkAccess:
      networkAccess: true
    EnvVarRequirement:
      envDef:
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/openoil-simulation-duth:0.2.0
  hints:
    "cwltool:Secrets":
      secrets: [password]

  s:name: openOil model
  s:description: Simulation of oil spill
  s:keywords:
    - oil spill
    - openoil
    - opendrift
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
  s:producer:
    class: s:Organization
    s:name: D.U.TH
    s:url: https://env.duth.gr
    s:address:
      class: s:PostalAddress
      s:addressCountry: GR
  s:sourceOrganization:
    - class: s:Organization
      s:name: D.U.TH
      s:url: https://env.duth.gr
      s:address:
        class: s:PostalAddress
        s:addressCountry: GR
  s:author:
    - class: s:Person
      s:name: Georgios Sylaios
      s:email: gsylaios@env.duth.gr
  s:maintainer:
    - class: s:Person
      s:name: Nikolaos Kokkos
      s:email: nikolaoskokkos@gmail.com
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:identifier: urn:apkg:tool:d.u.th:gr:openoil_simulation:0.2.0
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/openoil-simulation-duth/openoil_simulation_duth_0_2_0.cwl
  s:dateCreated: "2024-12-02T17:02:10Z"
  s:license: https://opensource.org/licenses/MIT
  s:citation: doi:1-234-5678799.00
  s:temporalCoverage: 2024-01-01T00:00:00Z/2024-12-31T23:59:59Z
  s:spatialCoverage:
    class: s:geo
    s:box: 40.25 23.00 41.0 25.80

- class: CommandLineTool
  id: 2stac

  baseCommand: python
  arguments:
  - /opt/2stac.py
  - --result
  - valueFrom: $( inputs.result )
  - --metadata
  - valueFrom: $( inputs.metadata )

  inputs:
    result:
      type: File
      format: edam:format_3650 # NetCDF
      doc: The resulting file of the previous model to insert in STAC
    metadata:
      type: File
      format: edam:format_3464 # JSON
      doc: The resulting metadata of the previous model to insert in STAC

  outputs:
    results:
      outputBinding:
        glob: .
      type: Directory
      doc: STAC output

  requirements:
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac:0.2.0

  s:name: 2Stac
  s:softwareVersion: 0.2.0
  s:description: Transform the result into a STAC
  s:keywords:
    - stac
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac/2stac_0_2_0.cwl
  s:dateCreated: "2024-11-17T20:07:17Z"