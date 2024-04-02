cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/

$graph:

- baseCommand: animation
  class: CommandLineTool

  id: urn:cwl:tool:inesctec:pt:animation

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
