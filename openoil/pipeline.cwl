cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/

$graph:

- class: Workflow
  id: 'http://cwl.workflow.duth.gr.pipeline'
  doc: Animation of an oil spill with openoil
  inputs:
    lat:
      type: float
      doc: The latitude of the study area
      s:name: Input lat float
      s:description: The latitude of the study area
      s:keywords:
        - lat
        - float
    lon:
      type: float
      doc: The longitude of the study area
      s:name: Input lon float
      s:description: The longitude of the study area
      s:keywords:
        - lon
        - float
    time:
      type: string
      doc: The start time of the simulation
      s:name: Input time string
      s:description: The start time of the simulation. Type dd-mm-yyyy
      s:keywords:
        - time
        - string
      # %d-%m-%Y %H:%M:%S
      # https://strftime.org/
    oiltype:
      type: string
      doc: The type of the oil to run the simulation
      s:name: Input oiltype string
      s:description: The type of the oil to run the simulation
      s:keywords:
        - oiltype
        - string

    duration:
      type: int
      doc: The simulation duration
      s:name: Input duration int
      s:description: The simulation duration
      s:keywords:
        - duration
        - int
  steps:
    step_1:
      run: '#openoil'
      in:
        lat: lat
        lon: lon
        time: time
        oiltype: oiltype
        duration: duration
      out:
      - simulation
      - metadata
    step_2:
      run: '#http://cwl.tool.inesctec.pt/animation'
      in:
        file: step_1/simulation
      out:
      - animation
    step_3:
      run: '#2stac'
      in:
        result: step_2/animation
        metadata: step_1/metadata
      out:
      - results
    
  outputs:
  - id: wf_outputs
    outputSource:
    - step_3/results
    type:
      Directory
  
  # class metadata
  s:name: openOil pipeline 
  s:description: Simulation and animation of oil spill
  s:keywords:
    - oil spill
    - openoil
    - opendrift
    - animation
  s:programmingLanguage: python
  s:softwareVersion: 1.0.10
  s:spatialCoverage:
    class: s:geo
    s:box: 40.25 23.00 41.0 25.80 
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


- class: CommandLineTool
  baseCommand: openoil
  id: openoil

  arguments:
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
  
  inputs:
    lat:
      type: float
      doc: The latitude of the study area
      s:name: Input lat float
      s:description: The latitude of the study area
      s:keywords:
        - lat
        - float
    lon:
      type: float
      doc: The longitude of the study area
      s:name: Input lon float
      s:description: The longitude of the study area
      s:keywords:
        - lon
        - float
    time:
      type: string
      doc: The start time of the simulation
      s:name: Input time string
      s:description: The start time of the simulation. Type dd-mm-yyyy
      s:keywords:
        - time
        - string
      # %d-%m-%Y %H:%M:%S
      # https://strftime.org/
    oiltype:
      type: string
      doc: The type of the oil to run the simulation
      s:name: Input oiltype string
      s:description: The type of the oil to run the simulation
      s:keywords:
        - oiltype
        - string
    duration:
      type: int
      doc: The simulation duration
      s:name: Input duration int
      s:description: The simulation duration
      s:keywords:
        - duration
        - int
  outputs:
    simulation:
      format: ogc:netcdf
      type: File
      outputBinding:
        glob: "result/simulation.nc"
      s:fileFormat: "application/x-netcdf; format=CF-1.4"
    metadata:
      type: File
      outputBinding:
        glob: "result/metadata.json"
      doc: metadata description
      s:fileFormat: "application/json"
      
  requirements:
    NetworkAccess:
      networkAccess: true

    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/openoil_simulation:1.0.11
  
  s:name: openOil model 
  s:description: Simulation of oil spill
  s:keywords:
    - oil spill
    - openoil
    - opendrift
  s:programmingLanguage: python
  s:softwareVersion: 1.0.11
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
  s:codeRepository: https://pipe-drive.inesctec.pt/cwl/openoil_attached/simulation.cwl
  s:dateCreated: "2023-04-21"

- class: CommandLineTool
  baseCommand: animation
  id: 'http://urn.cwl.tool.inesctec.pt/animation'

  arguments:
  - --file
  - valueFrom: $( inputs.file )
  inputs:
    file:
      type: File
      doc: NetCDF file that contains the simulation
      s:name: Input simulation File
      s:description: NetCDF file that contains the simulation
      s:keywords:
        - simulation
        - File
      s:fileFormat: "application/x-netcdf; format=CF-1.4"
  outputs:
    animation:
      type: File
      doc: The animation from the openoil simulation
      outputBinding:
        glob: "result/animation.gif"
      s:fileFormat: "image/gif"
      
  requirements:
    NetworkAccess:
      networkAccess: true
    # EnvVarRequirement:
    #   envDef:
    #     # PATH: /srv/conda/envs/openoil/bin:/srv/conda/bin:/srv/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    #     HOME: /tmp
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/openoil_animation:1.0.2

  s:name: openOil animation 
  s:description: Animation of oil spill
  s:keywords:
    - oil spill
    - openoil
    - opendrift
  s:programmingLanguage: python
  s:softwareVersion: 1.0.2
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
  s:codeRepository: https://pipe-drive.inesctec.pt/cwl/openoil_attached/animation.cwl
  s:dateCreated: "2023-04-21"

- class: CommandLineTool
  baseCommand: 2stac
  id: 2stac

  arguments:
  - --result
  - valueFrom: $( inputs.result )
  - --metadata
  - valueFrom: $( inputs.metadata )
  
  inputs:
    result:
      type: File
      doc: The resulting file of the previous model to insert in STAC 
      s:name: Input result file
      s:description: The resulting file of the previous model to insert in STAC 
      s:keywords:
        - result
        - File
      s:fileFormat: "*/*"
    metadata:
      type: File
      doc: The resulting metadata of the previous model to insert in STAC 
      s:name: Input metadata file
      s:description: The resulting metadata of the previous model to insert in STAC 
      s:keywords:
        - metadata
        - File
      s:fileFormat: "application/json"

  outputs:
    results:
      outputBinding:
        glob: .
      type: Directory
      doc: STAC output

  requirements:
    EnvVarRequirement:
      envDef:
        PATH: /srv/conda/envs/model-env/bin:/srv/conda/bin:/srv/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac:1.0.0

  s:name: 2Stac
  s:description: Transform the result into a STAC
  s:keywords:
    - stac
    - metadata
  s:programmingLanguage: python
  s:softwareVersion: 1.0.10
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
  s:codeRepository: https://pipe-drive.inesctec.pt/cwl/openoil_attached/2stac.cwl
  s:dateCreated: "2023-04-21"

s:softwareVersion: 1.0.10
s:name: openOil model 
s:description: Simulation of oil spill
