#!/usr/bin/env cwl-runner

$graph:
- class: Workflow
  doc: Download of metoceanographic data

  inputs:
    forecast:
      doc: forecast for the model
      type: int
    hindcast:
      doc: Hindcast for the model
      type: int
    roms_password:
      doc: Password for Copernicus Download
      type: string
    roms_username:
      doc: Username for Copernicus Download
      type: string
    timenow:
      doc: Simulation start date. If none is provided, today is used as reference
      type: string

  outputs:
    roms_output:
      type: Directory
      outputSource: run_roms/roms_output

  steps:
    download_data:
      in:
        forecast: forecast
        hindcast: hindcast
        roms_password: roms_password
        roms_username: roms_username
        timenow: timenow
      run: '#download_data'
      out:
      - roms_directory
    run_roms:
      in:
        forecast: forecast
        hindcast: hindcast
        roms_directory: download_data/roms_directory
        timenow: timenow
      run: '#run_roms'
      out:
      - roms_output

  id: download_metoceanographic_data
  s:author:
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
  - class: s:Person
    s:email: joao.ribeiro@hidromod.com
    s:name: João Ribeiro
  s:contributor:
  - class: s:Person
    s:email: joao.ribeiro@hidromod.com
    s:name: João Ribeiro
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
  s:maintainer:
  - class: s:Organization
    s:email: iliad@hidromod.com
    s:name: Hidromod
  s:description: Ocean Digital Twin in Tunisia uses ROMS for precise aquaculture forecasts, enhancing sustainability.
  s:keywords:
  - roms
  - tunisia
  s:name: ROMS Tunisia
  s:programmingLanguage: python
  s:softwareVersion: 1.1.1
  s:producer:
    class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
    s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:sourceOrganization:
    - class: s:Organization
      s:name: Hidromod
      s:url: https://hidromod.com/
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:dateCreated: "2023-12-04"
  s:spatialCoverage:
    class: s:geo
    s:box: 35.503 10.403 36.497 11.397
  s:license: https://creativecommons.org/licenses/by/4.0/

- class: CommandLineTool

  requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: hidromodadmin/iliad_roms_tunisia:1.1.1
  - class: NetworkAccess
    networkAccess: true
  - class: LoadListingRequirement
    loadListing: deep_listing

  inputs:
    forecast:
      type: int
    hindcast:
      type: int
    roms_password:
      type: string
    roms_username:
      type: string
    timenow:
      type: string

  outputs:
    roms_directory:
      type: Directory
      outputBinding:
        glob: $("roms")

  baseCommand:
  - /bin/bash
  - -c
  arguments:
  - valueFrom: |
      "/move_struct.sh $(runtime.outdir)"; python3 /model/RomsOP.py --type preparation --forecast $(inputs.forecast) --hindcast $(inputs.hindcast) \
       --roms_password $(inputs.roms_password) --roms_username $(inputs.roms_username) --timenow $(inputs.timenow);
    shellQuote: false

  id: download_data
  s:author:
  - class: s:Person
    s:email: joao.ribeiro@hidromod.com
    s:name: João Ribeiro
  s:contributor:
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
  s:maintainer:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
  s:codeRepository: https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/ROMS_Tunisia/workflow.cwl
  s:description: Download a preparation of executable to be used when executing ROMS
  s:keywords:
  - roms
  - tunisia
  - preparation
  s:name: Preparation of ROMS Model
  s:programmingLanguage: python
  s:softwareVersion: 1.1.1
  s:producer:
    class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
    s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:sourceOrganization:
    - class: s:Organization
      s:name: Hidromod
      s:url: https://hidromod.com/
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:dateCreated: "2023-12-04"
  s:spatialCoverage:
    class: s:geo
    s:box: 35.503 10.403 36.497 11.397
  s:license: https://creativecommons.org/licenses/by/4.0/


- class: CommandLineTool
  requirements:
  - class: InitialWorkDirRequirement
    listing:
    - entryname: roms
      writable: true
      entry: $(inputs.roms_directory)
  - class: DockerRequirement
    dockerPull: hidromodadmin/iliad_roms_tunisia:1.1.1
  - class: InlineJavascriptRequirement
  - class: NetworkAccess
    networkAccess: true

  inputs:
    forecast:
      type: int
    hindcast:
      type: int
    roms_directory:
      type: Directory
    timenow:
      type: string

  outputs:
    roms_output:
      type: Directory
      outputBinding:
        glob: roms/[0-9]*

  baseCommand:
  - /bin/bash
  - -c
  arguments:
  - valueFrom: |
      python3 /model/RomsOP.py --type execution --forecast $(inputs.forecast) --hindcast $(inputs.hindcast) --timenow $(inputs.timenow);
    shellQuote: false

  id: run_roms
  s:author:
  - class: s:Person
    s:email: joao.ribeiro@hidromod.com
    s:name: João Ribeiro
  s:contributor:
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
  s:maintainer:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
  s:codeRepository: https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/ROMS_Tunisia/workflow.cwl
  s:description: Execution of ROMS model with data from the preparation
  s:keywords:
  - roms
  - tunisia
  - execution
  s:name: Execution of ROMS Model
  s:programmingLanguage: python
  s:softwareVersion: 1.1.1
  s:producer:
    class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
    s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:sourceOrganization:
    - class: s:Organization
      s:name: Hidromod
      s:url: https://hidromod.com/
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:dateCreated: "2023-12-04"
  s:spatialCoverage:
    class: s:geo
    s:box: 35.503 10.403 36.497 11.397
  s:license: https://creativecommons.org/licenses/by/4.0/
$namespaces:
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/
  s: https://schema.org/
cwlVersion: v1.2