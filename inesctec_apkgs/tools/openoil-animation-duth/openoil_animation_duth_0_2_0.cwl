cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/

$graph:

- class: CommandLineTool

  id: openoil_animation

  baseCommand: python
  arguments:
  - /opt/animation.py
  - --file
  - valueFrom: $( inputs.file )

  inputs:
    file:
      format: edam:format_3650 # NetCDF
      type: File
      doc: The netcdf file containing the simulation results
  outputs:
    animation:
      format: edam:format_3467 # GIF
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
      dockerPull: iliad-repository.inesctec.pt/openoil-animation-duth:0.2.0

  s:name: openoil_animation
  s:description: Animation of oil spill simulation
  s:keywords:
    - oil spill
    - animation
    - simulation
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/openoil-animation-duth/openoil_animation_duth_0_2_0.cwl
  s:dateCreated: "2025-02-07T17:26:39Z"