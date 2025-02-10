cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/

$graph:

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
      format: edam:format_3650 # NetCDF
      type: File
      outputBinding:
        glob: "result/simulation.nc"

    metadata:
      format: edam:format_3464 # JSON
      type: File
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
      secrets: [username,password]

  s:name: openoil_simulation
  s:description: Simulation of oil spill
  s:keywords:
    - oil spill
    - openoil
    - opendrift
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
  s:sourceOrganization:
    class: s:Organization
    s:name: D.U.TH
    s:url: https://env.duth.gr
    s:address:
        class: s:PostalAddress
        s:addressCountry: GR
  s:author:
    class: s:Person
    s:name: Georgios Sylaios
    s:email: gsylaios@env.duth.gr
  s:maintainer:
    class: s:Person
    s:name: Nikolaos Kokkos
    s:email: nikolaoskokkos@gmail.com
  s:contributor:
    class: s:Person
    s:name: Miguel Correia
    s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/openoil-simulation-duth/openoil_simulation_duth_0_2_0.cwl
  s:dateCreated: "2025-02-07T17:28:37Z"