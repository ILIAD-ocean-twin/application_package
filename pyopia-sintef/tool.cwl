cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:

- class: CommandLineTool

  id: pyopia_sintef

  baseCommand: uv
  arguments:
   - run
   - /app/script.py
  inputs:
    images:
      type: Directory
      doc: Input image directory
      inputBinding:
        prefix: --images
    auxiliary_data:
      type: File
      doc: Auxiliary data file
      inputBinding:
        prefix: --auxiliary_data
    config:
      type: File
      doc: Configuration file
      inputBinding:
        prefix: --config
    metadata:
      type: File
      doc: Metadata file
      inputBinding:
        prefix: --metadata
    model_path:
      type: File?
      doc: Model classifier file
      inputBinding:
        prefix: --model_path

  outputs:
    - id: netcdf_statistics
      type: File
      format: edam:format_3650 # NetCDF
      outputBinding:
        glob: results-STATS.nc
    - id: particles_figure
      type: File
      format: edam:format_3603 # png
      outputBinding:
        glob: particles.png
    - id: vd_copepods
      type: File
      format: edam:format_3603 # png
      outputBinding:
        glob: vd_copepods.png
    - id: vd_copepods_per_L
      type: File
      format: edam:format_3603 # png
      outputBinding:
        glob: vd_copepods_per_L.png
    - id: metadata
      type: File
      format: edam:format_3464 # JSON
      outputBinding:
        glob: nc_metadata.json
  requirements:
    NetworkAccess:
      networkAccess: true
    EnvVarRequirement:
      envDef:
        PATH: /app/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/pyopia-sintef:0.1.0

  s:name: pyopia_sintef
  s:description: Analysis of a given image dataset using PyOPIA.
  s:keywords:
    - pyopia
  s:programmingLanguage: python
  s:softwareVersion: 0.1.0
  s:producer:
    class: s:Organization
    s:name: SINTEF OCEAN
    s:url: https://sintef.no/en/ocean/
    s:address:
        class: s:PostalAddress
        s:addressCountry: "NO"
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
          class: s:PostalAddress
          s:addressCountry: PT
    - class: s:Organization
      s:name: SINTEF OCEAN
      s:url: https://sintef.no/en/ocean/
      s:address:
          class: s:PostalAddress
          s:addressCountry: "NO"
  s:author:
    - class: s:Person
      s:name: Raymond Nepstad
      s:email: raymond.nepstad@sintef.no
    - class: s:Person
      s:name: Volker Hoffmann
      s:email: volker.hoffmann@sintef.no
    - class: s:Person
      s:name: Antoine Pultier
      s:email: antoine.pultier@sintef.no
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://github.com/SINTEF/pyopia/tree/main
  s:dateCreated: "2025-11-10T16:29:50Z"
