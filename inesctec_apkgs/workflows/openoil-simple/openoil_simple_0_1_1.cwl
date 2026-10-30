cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: openoil_simple_pipeline
    doc: This pipeline runs an oil spill simulation with openoil.
    inputs:
      lat:
        type: float
        doc: The latitude of the study area
        label: openoil
      lon:
        type: float
        doc: The longitude of the study area
        label: openoil
      time:
        type: string
        doc: The start time of the simulation
        label: openoil
      oiltype:
        type: string
        doc: The type of the oil to run the simulation
        label: openoil
      duration:
        type: int
        doc: The simulation duration
        label: openoil
      username:
        type: string
        doc: The CMEMS username
        label: cmems_credentials
      password:
        type: string
        doc: The CMEMS password
        label: cmems_credentials
    steps:
      step_simulation:
        run: '#openoil_global'
        in:
          lat: lat
          lon: lon
          time: time
          oiltype: oiltype
          duration: duration
          username: username
          password: password
        out:
          - simulation
          - metadata
      step_2stac2:
        run: '#2stac2_openoil_pipeline'
        in:
          simulation: step_simulation/simulation
          metadata: step_simulation/metadata
        out:
          - stac_result
    outputs:
      - id: wf_outputs
        outputSource:
          - step_2stac2/stac_result
        type: Directory
    hints:
      cwltool:Secrets:
        secrets:
          - access_key
          - secret_key
          - session_token
          - password
    requirements:
      InlineJavascriptRequirement: {}
    s:name: openoil_simple_pipeline
    s:description: |
      This pipeline runs an oil spill simulation with openoil.
    s:keywords:
      - oil spill
      - openoil
      - opendrift
    s:softwareVersion: 0.1.1
    s:producer:
      class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
    s:sourceOrganization:
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
        s:address:
          class: s:PostalAddress
          s:addressCountry: PT
    s:author:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:dateCreated: '2026-10-30T22:13:31Z'
  - class: CommandLineTool
    id: openoil_global
    baseCommand: python
    arguments:
      - /opt/openoil.py
      - '--lat'
      - valueFrom: $( inputs.lat )
      - '--lon'
      - valueFrom: $( inputs.lon )
      - '--time'
      - valueFrom: $( inputs.time )
      - '--oiltype'
      - valueFrom: $( inputs.oiltype )
      - '--duration'
      - valueFrom: $( inputs.duration )
      - '--username'
      - valueFrom: $( inputs.username )
      - '--password'
      - valueFrom: $( inputs.password )
    inputs:
      lat:
        type: float
        doc: The latitude of the study area
      lon:
        type: float
        doc: The longitude of the study area
      time:
        type: string
        doc: The start time of the simulation
      oiltype:
        type: string
        doc: The type of the oil to run the simulation
      duration:
        type: int
        doc: The simulation duration
      username:
        type: string
        doc: The CMEMS username
      password:
        type: string
        doc: The CMEMS password
    outputs:
      simulation:
        format: edam:format_3650
        type: File
        outputBinding:
          glob: result/simulation.nc
      metadata:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: result/metadata.json
        doc: metadata description
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/openoil-global:0.1.0
    hints:
      cwltool:Secrets:
        secrets:
          - password
    s:name: openoil_global
    s:description: Simulation of oil spill
    s:keywords:
      - oil spill
      - openoil
      - opendrift
    s:programmingLanguage: python
    s:softwareVersion: 0.1.0
    s:producer:
      class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
    s:sourceOrganization:
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
        s:address:
          class: s:PostalAddress
          s:addressCountry: PT
    s:author:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:dateCreated: '2026-10-30T22:09:21Z'
  - class: CommandLineTool
    id: 2stac2_openoil_pipeline
    baseCommand: python
    arguments:
      - /opt/2stac2.py
    inputs:
      simulation:
        format: edam:format_3650
        doc: simulation NetCDF file
        type: File
        inputBinding:
          prefix: '--file'
      animation:
        format: edam:format_3467
        doc: animation Gif file
        type: File?
        inputBinding:
          prefix: '--file'
      metadata:
        format: edam:format_3464
        doc: metadata file description
        type: File
        loadContents: true
        inputBinding:
          prefix: '--metadata'
          valueFrom: $(runtime.outdir + '/multiple_metadata.json')
    outputs:
      stac_result:
        outputBinding:
          glob: stac_result
        type: Directory
        doc: STAC output
    requirements:
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/2stac2:0.3.1
      InplaceUpdateRequirement:
        inplaceUpdate: true
      InitialWorkDirRequirement:
        listing: |
          ${
            const content = JSON.parse(inputs.metadata.contents);
            const metadata = [];
            metadata.push({...content, filename:inputs["simulation"].basename});
            if(inputs["animation"] != null) {
              metadata.push({...content, filename:inputs["animation"].basename , media_type:"image/gif" });
            }
            return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
          }
    s:name: 2stac2_openoil_pipeline
    s:softwareVersion: 0.3.1
    s:description: >-
      2stac2 tool to transform OpenOil simulation and animation files into a
      STAC
    s:keywords:
      - stac
      - metadata
    s:programmingLanguage: python
    s:producer:
      class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
    s:sourceOrganization:
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
        s:address:
          class: s:PostalAddress
          s:addressCountry: PT
    s:author:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:dateCreated: '2026-01-27T16:00:40Z'
