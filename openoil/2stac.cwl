cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/

$graph:

- baseCommand: 2stac
  class: CommandLineTool

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
  s:softwareVersion: 1.0.0
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
