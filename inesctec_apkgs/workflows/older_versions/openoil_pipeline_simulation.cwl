
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: Workflow
  id: openoil_pipeline_simulation
  doc: Simulation of an oil spill with openoil
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
    step_stac:
      run: '#2stac2'
      in:
        simulation: step_simulation/simulation
        metadata: step_simulation/metadata
      out:
      - stac_result

  outputs:
  - id: wf_outputs
    outputSource:
    - step_stac/stac_result
    type:
      Directory
  hints:
    "cwltool:Secrets":
      secrets: [username,password]

  s:name: openOil pipeline
  s:description: Simulation and animation of oil spill
  s:keywords:
    - oil spill
    - openoil
    - opendrift
    - animation
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
    - class: s:Organization
      s:name: D.U.TH
      s:url: https://env.duth.gr
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Georgios Sylaios
      s:email: gsylaios@env.duth.gr
    - class: s:Person
      s:name: Nikolaos Kokkos
      s:email: nikolaoskokkos@gmail.com
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/others/openoil_pipeline_simulation.cwl
  s:dateCreated: "2024-04-01T13:00:00Z"
  s:license: https://opensource.org/licenses/MIT

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
      format: ogc:netcdf
      type: File
      outputBinding:
        glob: "result/simulation.nc"

    metadata:
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
      dockerPull: iliad-repository.inesctec.pt/openoil-simulation-duth:0.1.0
  hints:
    "cwltool:Secrets":
      secrets: [username,password]

  s:name: openOil model
  s:description: Simulation of oil spill
  s:keywords:
    - oil spill
    - openoil
    - opendrift
  s:programmingLanguage: python
  s:softwareVersion: 0.1.0
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
    - class: s:Organization
      s:name: D.U.TH
      s:url: https://env.duth.gr
  s:author:
    - class: s:Person
      s:name: Georgios Sylaios
      s:email: gsylaios@env.duth.gr
    - class: s:Person
      s:name: Nikolaos Kokkos
      s:email: nikolaoskokkos@gmail.com
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/openoil-simulation-duth/openoil_simulation_duth_0_1_0.cwl
  s:dateCreated: "2024-04-01T13:00:00Z"

- class: CommandLineTool

  id: 2stac2

  baseCommand: python
  arguments:
  - /opt/2stac2.py
  - --file
  - valueFrom: $(inputs.simulation)
  - --metadata
  - valueFrom: $(runtime.outdir + '/multiple_metadata.json')

  inputs:
    simulation:
      doc: simulation NetCDF file
      type: File
    metadata:
      type: File
      loadContents: true

  outputs:
    stac_result:
      outputBinding:
        glob: stac_result
      type: Directory
      doc: STAC output

  requirements:
    EnvVarRequirement:
      envDef:
        PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac2:0.1.0
    InplaceUpdateRequirement:
      inplaceUpdate: true
    InitialWorkDirRequirement:
      listing: |
        ${
          const content = JSON.parse(inputs.metadata.contents);
          const metadata = [];
          metadata.push({...content, filename:inputs["simulation"].basename});
          return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
        }

  s:name: 2Stac2
  s:softwareVersion: 0.1.0
  s:description: Transform and array of files into a STAC
  s:keywords:
    - stac
    - metadata
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_0_1_0.cwl
  s:dateCreated: "2024-04-01T13:00:00Z"
