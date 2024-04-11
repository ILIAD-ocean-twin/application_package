#!/usr/bin/env cwl-runner

$graph:
- class: Workflow
  doc: TSSM Scotland

  inputs:
    duration:
      doc: |-
        Duration length of simulation, number and units\ne.g. "30d", "120h", "14c" (here "c" is semi-diurnal cycle)
      type: string
      s:description: |-
        Duration length of simulation, number and units\ne.g. "30d", "120h", "14c" (here "c" is semi-diurnal cycle)
      s:keywords:
      - string
      - duration
      s:name: Input duration string
    num_proc:
      doc: Number of processes used in parallel simulation
      type: int
      s:description: Number of processes used in parallel simulation
      s:keywords:
      - string
      - processes
      s:name: Input processes int
    ramp_duration:
      doc: |-
        Duration length of ramp-up, number and units\ne.g. "2d", "24", "4c" (default unit "h")
      type: string
      s:description: |-
        Duration length of ramp-up, number and units\ne.g. "2d", "24", "4c" (default unit "h")
      s:keywords:
      - string
      - duration
      s:name: Input duration string
    start:
      doc: Start date time (YYYY-MM-DDTHH:MM) of simulation
      type: string
      s:description: Start date time (YYYY-MM-DDTHH:MM) of simulation
      s:keywords:
      - string
      - date
      s:name: Input date string

  outputs:
    tssm_directory:
      type: Directory
      outputSource: run_tssm/tssm_directory

  steps:
    run_tssm:
      in:
        duration: duration
        num_proc: num_proc
        ramp_duration: ramp_duration
        start: start
      run: '#run_tssm'
      out:
      - tssm_directory
      
  id: tssm_scotland
  s:author:
  - class: s:Person
    s:email: miguel.delgado@hidromod.com
    s:name: Miguel Delgado
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
  s:description: TSSM Ocean Digital Twin in Scotland optimizes tidal energy production, enhancing sustainability.
  s:keywords:
  - tssm
  - scotland
  s:name: TSSM Scotland
  s:programmingLanguage: python
  s:softwareVersion: 1.0.1
  s:sourceOrganization:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
  s:dateCreated: "2023-12-04"
  s:spatialCoverage:
    class: s:geo
    s:box: -4.6378229814743257 57.4956623498785504 -1.3752521579482344 59.8568146455774368
  s:license: https://creativecommons.org/licenses/by/4.0/
  
- class: CommandLineTool

  requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: hidromodadmin/iliad_tssm_scotland:1.0.1
  - class: NetworkAccess
    networkAccess: true
  - class: LoadListingRequirement
    loadListing: deep_listing

  inputs:
    duration:
      type: string
    num_proc:
      type: int
    ramp_duration:
      type: string
    start:
      doc: Start date time (YYYY-MM-DDTHH:MM) of simulation
      type: string
      s:description: Start date time (YYYY-MM-DDTHH:MM) of simulation
      s:keywords:
      - string
      - date
      s:name: Input date string

  outputs:
    tssm_directory:
      type: Directory
      outputBinding:
        glob: $("out_DT/")

  baseCommand:
  - /bin/bash
  - -c
  arguments:
  - valueFrom: |
      "/move_struct.sh $(runtime.outdir)"; set -e; . /home/firedrake/firedrake/bin/activate; pip3 install -r requirements.txt; python sim.py --start "$(inputs.start)" --duration "$(inputs.duration)" --ramp-duration $(inputs.ramp_duration) --num-proc $(inputs.num_proc)
    shellQuote: false
  id: run_tssm
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
  s:codeRepository: https://raw.githubusercontent.com/ILIAD-ocean-twin/application_package/main/TSSM_Scotland/workflow.cwl
  s:description: Running TSSM Scotland
  s:keywords:
  - tssm
  - scotland
  s:name: TSSM Scotland
  s:programmingLanguage: python
  s:softwareVersion: 1.0.1
  s:sourceOrganization:
  - class: s:Organization
    s:name: Hidromod
    s:url: https://hidromod.com/
  s:dateCreated: "2023-12-04"
  s:spatialCoverage:
    class: s:geo
    s:box: -4.6378229814743257 57.4956623498785504 -1.3752521579482344 59.8568146455774368
  s:license: https://creativecommons.org/licenses/by/4.0/

$namespaces:
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/
  s: https://schema.org/
cwlVersion: v1.2
s:description: TSSM Scotland
s:name: TSSM Scotland
s:softwareVersion: 1.0.1
