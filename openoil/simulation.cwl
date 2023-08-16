cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/

$graph:

- baseCommand: openoil
  class: CommandLineTool

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
  s:softwareVersion: 1.0.12
  s:keywords:
    - oil spill
    - openoil
    - opendrift
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
