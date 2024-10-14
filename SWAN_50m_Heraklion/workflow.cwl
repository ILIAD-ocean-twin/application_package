#!/usr/bin/env cwl-runner

$graph:
- class: Workflow
  doc: Execution of SWAN wave model, designed specifically for the Heraklion Port
    area

  inputs:
    cmems_password:
      doc: Password for CMEMS Download
      type: string
      s:description: Password for CMEMS Download
      s:keywords:
      - string
      - password
      s:name: CMEMS Password
    cmems_username:
      doc: Username for CMEMS Download
      type: string
      s:description: Username for CMEMS Download
      s:keywords:
      - string
      - username
      s:name: CMEMS Username
    forecast:
      doc: forecast for the model
      type: int
      s:description: forecast for the model
      s:keywords:
      - int
      - forecast
      s:name: Hindcast
    hindcast:
      doc: Hindcast for the model
      type: int
      s:description: Hindcast for the model
      s:keywords:
      - int
      - Hindcast
      s:name: Hindcast
    wrf_ftpserver:
      doc: Password for WRF Download
      type: string
      s:description: FTP Server for WRF Download
      s:keywords:
      - string
      - password
      s:name: WRF Password
    wrf_password:
      doc: Username for WRF Download
      type: string
      s:description: Username for WRF Download
      s:keywords:
      - string
      - username
      s:name: WRF Username
    wrf_username:
      doc: Username for WRF Download
      type: string
      s:description: Username for WRF Download
      s:keywords:
      - string
      - username
      s:name: WRF Username

  outputs:
    swan_output:
      type: Directory
      outputSource: execution50m/swan_result

  steps:
    preparation:
      in:
        forecast: forecast
        hindcast: hindcast
        cmems_password: cmems_password
        cmems_username: cmems_username
        wrf_ftpserver: wrf_ftpserver
        wrf_username: wrf_username
        wrf_password: wrf_password
      run: '#preparation'
      out:
      - swan_preparation_directory

    execution500m:
      in:
        forecast: forecast
        hindcast: hindcast
        swan_preparation_directory: preparation/swan_preparation_directory
      run: '#execution500m'
      out:
      - swan_execution500m_directory
    execution50m:
      in:
        forecast: forecast
        hindcast: hindcast
        swan_directory: execution500m/swan_execution500m_directory
      run: '#execution50m'
      out:
      - swan_result
  id: run_swan_creta
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
  - class: s:Person
    s:email: vasmeth@iacm.forth.gr
    s:name: Vassiliki Metheniti
  - class: s:Person
    s:email: antonisparasyris@iacm.forth.gr
    s:name: Antonios Parasyris
  s:description: |-
    This 500m and 50m resolution SWAN wave model is designed specifically for the Heraklion Port area, spanning a geographical range from West: 25.0 to East: 25.3, and South: 35.32 to North: 35.57. It utilizes ocean boundary conditions derived from the CMEMS Mediterranean Sea Waves Analysis and Forecast model to ensure accurate wave dynamics within the Mediterranean context. Meteorological forcing is provided by the high-resolution ICON 7km dataset, offering detailed and reliable atmospheric inputs.
  s:keywords:
  - swan
  - Heraklion
  - wave
  - hidromod
  s:name: Execution of SWAN wave model
  s:programmingLanguage: python
  s:softwareVersion: 1.0.0
  s:sourceOrganization:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
- class: CommandLineTool

  requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: hidromodadmin/iliad_heraklion_500m_50m:1.0.0
  - class: NetworkAccess
    networkAccess: true
  - class: LoadListingRequirement
    loadListing: deep_listing

  inputs:
    cmems_password:
      type: string
    cmems_username:
      type: string
    forecast:
      type: int
    hindcast:
      type: int
    wrf_ftpserver:
      type: string
    wrf_password:
      type: string
    wrf_username:
      type: string

  outputs:
    swan_preparation_directory:
      type: Directory
      outputBinding:
        glob: .

  baseCommand:
  - /bin/bash
  - -c
  arguments:
  - valueFrom: |
      "/home/heraklionport_500m/prepare_swan.sh $(runtime.outdir) \
      $(inputs.forecast) \
      $(inputs.hindcast) \
      '$(inputs.cmems_password)' \
      '$(inputs.cmems_username)' \
      '$(inputs.wrf_ftpserver)' \
      '$(inputs.wrf_username)' \
      '$(inputs.wrf_password)'"
    shellQuote: false
  id: preparation
  s:author:
  - class: s:Person
    s:email: joao.ribeiro@hidromod.com
    s:name: João Ribeiro
  s:contributor:
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
  - class: s:Person
    s:email: vasmeth@iacm.forth.gr
    s:name: Vassiliki Metheniti
  - class: s:Person
    s:email: antonisparasyris@iacm.forth.gr
    s:name: Antonios Parasyris
  s:description: Download and preparation of all the required files to execute SWAN
  s:keywords:
  - swan
  - Heraklion
  - wave
  - hidromod
  - preparation
  s:name: Preparation of SWAN wave Model
  s:programmingLanguage: python
  s:softwareVersion: 1.0.0
  s:sourceOrganization:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
- class: CommandLineTool

  requirements:
  - class: InitialWorkDirRequirement
    listing: |-
      $(inputs.swan_preparation_directory.listing.map(function(item) { return {entry: item, writable: true}; }))
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: hidromodadmin/iliad_heraklion_500m_50m:1.0.0
  - class: NetworkAccess
    networkAccess: true
  - class: LoadListingRequirement
    loadListing: deep_listing

  inputs:
    forecast:
      type: int
    hindcast:
      type: int
    swan_preparation_directory:
      type: Directory

  outputs:
    swan_execution500m_directory:
      type: Directory
      outputBinding:
        glob: .

  baseCommand:
  - /bin/bash
  - -c
  arguments:
  - valueFrom: |
      "/home/heraklionport_500m/500m.sh $(runtime.outdir) $(inputs.forecast) $(inputs.hindcast)"
    shellQuote: false
  id: execution500m
  s:author:
  - class: s:Person
    s:email: joao.ribeiro@hidromod.com
    s:name: João Ribeiro
  s:contributor:
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
  - class: s:Person
    s:email: vasmeth@iacm.forth.gr
    s:name: Vassiliki Metheniti
  - class: s:Person
    s:email: antonisparasyris@iacm.forth.gr
    s:name: Antonios Parasyris
  s:description: Execution of SWAN 500m wave model with data from the preparation
  s:keywords:
  - swan
  - Heraklion
  - wave
  - hidromod
  - execution
  s:name: Execution of SWAN wave Model
  s:programmingLanguage: python
  s:softwareVersion: 1.0.0
  s:sourceOrganization:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
- class: CommandLineTool

  requirements:
  - class: InitialWorkDirRequirement
    listing: |-
      $(inputs.swan_directory.listing.map(function(item) { return {entry: item, writable: true}; }))
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: hidromodadmin/iliad_heraklion_500m_50m:1.0.0
  - class: NetworkAccess
    networkAccess: true
  - class: LoadListingRequirement
    loadListing: deep_listing

  inputs:
    forecast:
      type: int
    hindcast:
      type: int
    swan_directory:
      type: Directory

  outputs:
    swan_result:
      type: Directory
      outputBinding:
        glob: $("results")

  baseCommand:
  - /bin/bash
  - -c
  arguments:
  - valueFrom: |
      "/home/heraklionport_500m/50m.sh $(runtime.outdir) $(inputs.forecast) $(inputs.hindcast)"
    shellQuote: false
  id: execution50m
  s:author:
  - class: s:Person
    s:email: joao.ribeiro@hidromod.com
    s:name: João Ribeiro
  s:contributor:
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
  - class: s:Person
    s:email: vasmeth@iacm.forth.gr
    s:name: Vassiliki Metheniti
  - class: s:Person
    s:email: antonisparasyris@iacm.forth.gr
    s:name: Antonios Parasyris
  s:description: Execution of SWAN 50m wave model with data from the preparation and the execution of 500m
  s:keywords:
  - swan
  - Heraklion
  - wave
  - hidromod
  - execution
  s:name: Execution of SWAN wave Model
  s:programmingLanguage: python
  s:softwareVersion: 1.0.0
  s:sourceOrganization:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
$namespaces:
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/
  s: https://schema.org/
cwlVersion: v1.2
s:description: |-
  This 500m and 50m resolution SWAN wave model is designed specifically for the Heraklion Port area, spanning a geographical range from West: 25.0 to East: 25.3, and South: 35.32 to North: 35.57. It utilizes ocean boundary conditions derived from the CMEMS Mediterranean Sea Waves Analysis and Forecast model to ensure accurate wave dynamics within the Mediterranean context. Meteorological forcing is provided by the high-resolution ICON 7km dataset, offering detailed and reliable atmospheric inputs.
s:name: Execution of SWAN wave model
s:softwareVersion: 1.0.0
