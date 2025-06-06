
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: Workflow
  id: openoil_pipeline_animation_2s3
  doc: Animation of an oil spill with openoil and store it in S3
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
    region:
      type: string?
      doc: region
    endpoint:
      type: string
      doc: endpoint
    access_key:
      type: string
      doc: access_key
    secret_key:
      type: string
      doc: secret_key
    bucket:
      type: string
      doc: bucket

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
    step_animation:
      run: '#openoil_animation'
      in:
        file: step_simulation/simulation
      out:
      - animation
    step_stac:
      run: '#2stac2'
      in:
        animation: step_animation/animation
        metadata: step_simulation/metadata
      out:
      - stac_result
    step_2s3:
      run: '#2s3'
      in:
        region: region
        endpoint: endpoint
        access_key: access_key
        secret_key: secret_key
        bucket: bucket
        stac_result: step_stac/stac_result
      out:
        - base_path
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/others/openoil_pipeline_2s3.cwl
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

  id: openoil_animation

  baseCommand: python
  arguments:
  - /opt/animation.py
  - --file
  - valueFrom: $( inputs.file )

  inputs:
    file:
      type: File
      doc: The netcdf file containing the simulation results
  outputs:
    animation:
      type: File
      outputBinding:
        glob: "result/animation.gif"
  requirements:
    NetworkAccess:
      networkAccess: true
    EnvVarRequirement:
      envDef:
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/openoil-animation-duth:0.1.0

  s:name: openOil model animation
  s:description: Animation of oil spill simulation
  s:keywords:
    - oil spill
    - animation
    - simulation
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/openoil-animation-duth/openoil_animation_duth_0_1_0.cwl
  s:dateCreated: "2024-04-01T13:00:00Z"

- class: CommandLineTool

  id: 2stac2

  baseCommand: python
  arguments:
  - /opt/2stac2.py
  - --file
  - valueFrom: $(inputs.animation)
  - --metadata
  - valueFrom: $(runtime.outdir + '/multiple_metadata.json')

  inputs:
    animation:
      doc: animation Gif file
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
          metadata.push({...content, filename:inputs["animation"].basename , media_type:"image/gif" });
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

- class: CommandLineTool

  id: 2s3

  baseCommand: python
  arguments:
  - /opt/2s3.py
  - --endpoint
  - valueFrom: $( inputs.endpoint )
  - --access_key
  - valueFrom: $( inputs.access_key )
  - --secret_key
  - valueFrom: $( inputs.secret_key )
  - --bucket
  - valueFrom: $( inputs.bucket )
  - --endpoint
  - valueFrom: $( inputs.endpoint )
  - valueFrom: $(
      function () {
        if (inputs.region) {
          return ["--region", inputs.region];
        } else {
          return [];
        }
      }())
  - --base_path
  - valueFrom: $(
      function () {
        return "openoil_pipeline_animation_result_" + new Date().toISOString().replace(/:/g, '').replace(/\-/g, '').split('.')[0];
      }())
  - --directory
  - valueFrom: $( inputs.stac_result )

  inputs:
    region:
      type: string?
      doc: region
    endpoint:
      type: string
      doc: endpoint
    access_key:
      type: string
      doc: access_key
    secret_key:
      type: string
      doc: secret_key
    bucket:
      type: string
      doc: bucket
    stac_result:
      type: Directory
      doc: stac result folder

  outputs:
    base_path:
      type: string


  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2s3:0.1.0

  s:name: 2s3
  s:description: Uploads files and/or folders to a S3 bucket storage.
  s:keywords:
    - s3
    - storage
  s:programmingLanguage: python
  s:softwareVersion: 0.1.0
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2s3/2s3_0_1_0.cwl
  s:dateCreated: "2024-04-01T13:00:00Z"