#!/usr/bin/env cwl-runner

$graph:
- class: Workflow
  doc: Execution of SWAN wave model, designed specifically for the Heraklion Port area

  inputs:
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
    copernicus_password:
      doc: Password for Copernicus Download
      type: string
      s:description: Password for Copernicus Download
      s:keywords:
      - string
      - password
      s:name: Copernicus Password
    copernicus_username:
      doc: Username for Copernicus Download
      type: string
      s:description: Username for Copernicus Download
      s:keywords:
      - string
      - username
      s:name: Copernicus Username

  outputs:
    swan_output:
      type: Directory
      outputSource: execution/swan_result

  steps:
    preparation:
      in:
        forecast: forecast
        hindcast: hindcast
        copernicus_password: copernicus_password
        copernicus_username: copernicus_username
      run: '#preparation'
      out:
      - swan_directory
    execution:
      in:
        forecast: forecast
        hindcast: hindcast
        swan_directory: preparation/swan_directory
      run: '#execution'
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
  s:description: "This 500 m resolution SWAN wave model is designed specifically for the Heraklion Port area, spanning a geographical range from West: 25.0 to East: 25.3, and South: 35.32 to North: 35.57. It utilizes ocean boundary conditions derived from the CMEMS Mediterranean Sea Waves Analysis and Forecast model to ensure accurate wave dynamics within the Mediterranean context. Meteorological forcing is provided by the high-resolution ICON 7km dataset, offering detailed and reliable atmospheric inputs."
  s:keywords:
  - swan
  - Heraklion
  - wave
  - hidromod
  s:name: Execution of SWAN wave model
  s:programmingLanguage: python
  s:softwareVersion: 1.0.1
  s:sourceOrganization:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
- class: CommandLineTool

  requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: hidromodadmin/iliad_swan_heraklion:1.0.1
  - class: NetworkAccess
    networkAccess: true
  - class: LoadListingRequirement
    loadListing: deep_listing

  inputs:
    forecast:
      type: int
    hindcast:
      type: int
    copernicus_password:
      type: string
    copernicus_username:
      type: string

  outputs:
    swan_directory:
      type: Directory
      outputBinding:
        glob: $("heraklionport_500m")

  baseCommand:
  - /bin/bash
  - -c
  arguments:
  - valueFrom: |
      "/move_struct.sh $(runtime.outdir)"; python3 heraklionport_500m/heraklionport_500m.py --workingdir $(runtime.outdir)/heraklionport_500m/ --type preparation --forecast $(inputs.forecast) --hindcast $(inputs.hindcast) \
       --copernicus_password $(inputs.copernicus_password) --copernicus_username $(inputs.copernicus_username); 
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
  s:codeRepository: https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/SWAN_Heraklion/workflow.cwl
  s:description: Download and preparation of all the required files to execute SWAN
  s:keywords:
  - swan
  - Heraklion
  - wave
  - hidromod
  - preparation
  s:name: Preparation of SWAN wave Model
  s:programmingLanguage: python
  s:softwareVersion: 1.0.1
  s:spatialCoverage:
    class: s:geo
    s:box: 25.0 35.32 25.3 35.57
  s:sourceOrganization:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
- class: CommandLineTool

  requirements:
  - class: InitialWorkDirRequirement
    listing:
    - entryname: heraklionport_500m
      writable: true
      entry: $(inputs.swan_directory)
  - class: DockerRequirement
    dockerPull: hidromodadmin/iliad_swan_heraklion:1.0.1
  - class: InlineJavascriptRequirement
  - class: NetworkAccess
    networkAccess: true
 
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
        glob: $("heraklionport_500m/results")

  baseCommand:
  - /bin/bash
  - -c
  arguments:
  - valueFrom: |
      python3 heraklionport_500m/heraklionport_500m.py --workingdir $(runtime.outdir)/heraklionport_500m/ --type execution --forecast $(inputs.forecast) --hindcast $(inputs.hindcast); 
    shellQuote: false
  id: execution
  s:author:
  - class: s:Person
    s:email: joao.ribeiro@hidromod.com
    s:name: João Ribeiro
  s:contributor:
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
  s:description: Execution of SWAN wave model with data from the preparation
  s:codeRepository: https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/SWAN_Heraklion/workflow.cwl
  s:keywords:
  - swan
  - Heraklion
  - wave
  - hidromod
  - execution
  s:name: Execution of SWAN wave Model
  s:programmingLanguage: python
  s:softwareVersion: 1.0.1
  s:spatialCoverage:
    class: s:geo
    s:box: 25.0 35.32 25.3 35.57
  s:sourceOrganization:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
$namespaces:
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/
  s: https://schema.org/
cwlVersion: v1.2
s:description: "This 500 m resolution SWAN wave model is designed specifically for the Heraklion Port area, spanning a geographical range from West: 25.0 to East: 25.3, and South: 35.32 to North: 35.57. It utilizes ocean boundary conditions derived from the CMEMS Mediterranean Sea Waves Analysis and Forecast model to ensure accurate wave dynamics within the Mediterranean context. Meteorological forcing is provided by the high-resolution ICON 7km dataset, offering detailed and reliable atmospheric inputs."
s:name: Execution of SWAN wave model
s:softwareVersion: 1.0.1
