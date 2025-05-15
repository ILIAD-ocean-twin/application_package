#!/usr/bin/env cwl-runner

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/

$graph:
- class: Workflow

  hints:
    "cwltool:Secrets":
      secrets: [wrf_username, wrf_password, cmems_username, cmems_password]

  inputs:
    wrf_ftpserver:
      doc: FTP Server for WRF Download
      type: string
      s:description: FTP Server for WRF Download
      s:keywords:
      - string
      - ftpserver
      - ip
      - wrf
      s:name: WRF Server
    wrf_password:
      doc: Password for WRF Download
      type: string
      s:description: FTP Password for WRF Download
      s:keywords:
      - string
      - password
      - wrf
      s:name: WRF Password
    wrf_username:
      doc: Username for WRF Download
      type: string
      s:description: Username for WRF Download
      s:keywords:
      - string
      - username
      - wrf
      s:name: WRF Username
    wrf_remotedir:
      doc: Remote dir path from root for WRF Download
      type: string
      s:description: Remote dir path from root for WRF Download
      s:keywords:
      - string
      - username
      - wrf
      s:name: WRF Remote Dir
    vessel_type:
      type: string
      doc: Vessel Type (sail or motor)
      s:description: Vessel Type (sail or motor)
      s:keywords:
      - string
      - vessel
      - type
      s:name: Vessel Type
    cmems_username:
      type: string
      doc: CMEMS Username
      s:description: CMEMS Username
      s:keywords:
      - string
      - username
      - cmems
      s:name: CMEMS Username
    cmems_password:
      type: string
      doc: CMEMS Password
      s:description: CMEMS Password
      s:keywords:
      - string
      - password
      - cmems
      s:name: CMEMS Password
    departure_date:
      type: string
      doc: Departure Date (%Y-%m-%dT%H:%M:00Z)
      s:description: Departure Date (%Y-%m-%dT%H:%M:00Z)
      s:keywords:
      - string
      - departure
      - date
      s:name: Departure Date
    start_lat:
      type: float
      doc: Starting Latitude
      s:description: Starting Latitude
      s:keywords:
      - float
      - latitude
      s:name: Starting Latitude
    start_lon:
      type: float
      doc: Starting Longitude
      s:description: Starting Longitude
      s:keywords:
      - float
      - longitude
      s:name: Starting Longitude
    end_lat:
      type: float
      doc: Ending Latitude
      s:description: Ending Latitude
      s:keywords:
      - float
      - latitude
      s:name: Ending Latitude
    end_lon:
      type: float
      doc: Ending Longitude
      s:description: Ending Longitude
      s:keywords:
      - float
      - longitude
      s:name: Ending Longitude
    maxDraught:
      type: float
      doc: Max Draught
      s:description: Max Draught
      s:keywords:
      - float
      - draught
      s:name: Max Draught
    bathymetry_file:
      type: File?
      doc: Optional Bathymetry File
      s:description: Optional Bathymetry File
      s:keywords:
      - File?
      - bathymetry
      s:name: Bathymetry File

  outputs:
    visir_output:
      type: Directory
      outputSource: running/visir_output

  steps:
    running:
      in:
        wrf_ftpserver: wrf_ftpserver
        wrf_username: wrf_username
        wrf_password: wrf_password
        wrf_remotedir: wrf_remotedir
        vessel_type: vessel_type
        cmems_username: cmems_username
        cmems_password: cmems_password
        departure_date: departure_date
        start_lat: start_lat
        start_lon: start_lon
        end_lat: end_lat
        end_lon: end_lon
        maxDraught: maxDraught
        bathymetry_file: bathymetry_file
      run: '#running'
      out:
      - visir_output

  id: run_visir
  s:author:
  - class: s:Person
    s:email: vasmeth@iacm.forth.gr
    s:name: Vassiliki Metheniti
  - class: s:Person
    s:email: antonisparasyris@iacm.forth.gr
    s:name: Antonios Parasyris
  - class: s:Person
    s:email: joao.ribeiro@hidromod.com
    s:name: João Ribeiro
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
  - class: s:Person
  s:contributor:
  - class: s:Person
    s:email: vasmeth@iacm.forth.gr
    s:name: Vassiliki Metheniti
  - class: s:Person
    s:email: antonisparasyris@iacm.forth.gr
    s:name: Antonios Parasyris
  - class: s:Person
    s:email: joao.ribeiro@hidromod.com
    s:name: João Ribeiro
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
  - class: s:Person
  s:description: |-
    Solving Dijkstra's optimization algorithm to find optimal ship routes that minimize CO2 emissions, trip time and distance. Using VISIR II software (https://zenodo.org/records/10960842 created by CMCC), that runs using forcing from either CMRL's (https://crl.iacm.forth.gr/en/) high resolution models in the southern Greece region forecasting atmospheric state (WRF 3km x 3km), hydrodynamics (NEMO 1km x 1km) and waves (Wavewatch III 1km x 1km), or the GFS/CMEMS lower resolution forecasts to be able to generalize to routes globally.
  s:keywords:
  - hidromod
  - visir
  - VISIR
  - least CO2 emissions
  - optimal ship routes
  - least distance
  - least time
  - regional
  - high resolution
  - global
  - FORTH
  - CMRL
  s:name: Execution of VISIR model
  s:programmingLanguage: python
  s:softwareVersion: 1.0.0
  s:sourceOrganization:
  - class: s:Organization
    s:name: FORTH
    s:url: https://www.iacm.forth.gr/
  - class: s:Organization
    s:name: CMRL
    s:url: https://crl.iacm.forth.gr/en/
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
- class: CommandLineTool

  requirements:
    - class: InlineJavascriptRequirement
    - class: ShellCommandRequirement
    - class: DockerRequirement
      dockerPull: antonisparasyris/iliad:visir-1.0
    - class: NetworkAccess
      networkAccess: true
    - class: LoadListingRequirement
      loadListing: deep_listing
    - class: InitialWorkDirRequirement
      listing:
        - entryname: /VISIR/__data/bathymetry/GEBCO_2024_sub_ice_topo.nc
          entry: $(inputs.bathymetry_file)
          
  hints:
    "cwltool:Secrets":
      secrets: [wrf_username, wrf_password, cmems_username, cmems_password]

  inputs:
    wrf_ftpserver:
      type: string
    wrf_password:
      type: string
    wrf_username:
      type: string
    wrf_remotedir:
      type: string
    vessel_type:
      type: string
    cmems_username:
      type: string
    cmems_password:
      type: string
    departure_date:
      type: string
    start_lat:
      type: float
    start_lon:
      type: float
    end_lat:
      type: float
    end_lon:
      type: float
    maxDraught:
      type: float?
    bathymetry_file:
      type: File?

  outputs:
    visir_output:
      type: Directory
      outputBinding:
        glob: ./OUTPUT

  baseCommand:
  - /bin/bash
  - -c
  arguments:
    - valueFrom: |
        "/VISIR/run.sh '$(inputs.wrf_ftpserver)' '$(inputs.wrf_username)' '$(inputs.wrf_password)' '$(inputs.wrf_remotedir)' \
        '$(inputs.vessel_type)' '$(inputs.cmems_username)' '$(inputs.cmems_password)' '$(inputs.departure_date)' $(inputs.start_lat) \
        $(inputs.start_lon) $(inputs.end_lat) $(inputs.end_lon)$(inputs.maxDraught ? ' ' + inputs.maxDraught : '')"
      shellQuote: false

  id: running
cwlVersion: v1.2
s:author:
- class: s:Person
  s:email: vasmeth@iacm.forth.gr
  s:name: Vassiliki Metheniti
- class: s:Person
  s:email: antonisparasyris@iacm.forth.gr
  s:name: Antonios Parasyris
- class: s:Person
  s:email: joao.ribeiro@hidromod.com
  s:name: João Ribeiro
- class: s:Person
  s:email: miguel.delgado@hidromod.com
  s:name: Miguel Delgado
- class: s:Person
s:contributor:
- class: s:Person
  s:email: vasmeth@iacm.forth.gr
  s:name: Vassiliki Metheniti
- class: s:Person
  s:email: antonisparasyris@iacm.forth.gr
  s:name: Antonios Parasyris
- class: s:Person
  s:email: joao.ribeiro@hidromod.com
  s:name: João Ribeiro
- class: s:Person
  s:email: miguel.delgado@hidromod.com
  s:name: Miguel Delgado
- class: s:Person
s:description: |-
  Solving Dijkstra's optimization algorithm to find optimal ship routes that minimize CO2 emissions, trip time and distance. Using VISIR II software (https://zenodo.org/records/10960842 created by CMCC), that runs using forcing from either CMRL's (https://crl.iacm.forth.gr/en/) high resolution models in the southern Greece region forecasting atmospheric state (WRF 3km x 3km), hydrodynamics (NEMO 1km x 1km) and waves (Wavewatch III 1km x 1km), or the GFS/CMEMS lower resolution forecasts to be able to generalize to routes globally.
s:keywords:
- hidromod
- visir
- VISIR
- least CO2 emissions
- optimal ship routes
- least distance
- least time
- regional
- high resolution
- global
s:name: Execution of VISIR model
s:programmingLanguage: python
s:softwareVersion: 1.0.0
s:sourceOrganization:
- class: s:Organization
  s:name: FORTH
  s:url: https://www.iacm.forth.gr/
- class: s:Organization
  s:name: CMRL
  s:url: https://crl.iacm.forth.gr/en/
- class: s:Organization
  s:name: Hidromod
  s:url: https://hidromod.com/
