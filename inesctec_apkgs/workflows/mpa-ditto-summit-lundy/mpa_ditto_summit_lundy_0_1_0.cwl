cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: mpa_ditto_summit_lundy_pipeline
    doc: This pipeline runs the mpa simulation.
    inputs:
      startdate:
        type: string
        doc: The start time of the simulation
      duration:
        type: int
        doc: The duration of the simulation
      username:
        type: string
        doc: The CMEMS username
      password:
        type: string
        doc: The CMEMS password
    steps:
      step_simulation:
        run: '#mpa_ditto_summit_lundy'
        in:
          startdate: startdate
          duration: duration
          username: username
          password: password
        out:
          - simulation
      step_metadata:
        run: '#netcdf_metadata'
        in:
          netcdf_file: step_simulation/simulation
        out:
          - metadata
      step_2stac2:
        run: '#2stac2_mpa_pipeline'
        in:
          simulation: step_simulation/simulation
          metadata: step_metadata/metadata
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
          - password
    requirements:
      InlineJavascriptRequirement: {}
    s:name: mpa_ditto_summit_lundy_pipeline
    s:description: |
      This pipeline runs an mpa simulation with Opendrift.
    s:keywords:
      - mpa
      - opendrift
      - simulation
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
    s:codeRepository: >-
      https://github.com/ILIAD-ocean-twin/application_package/tree/main/mpa-norway
    s:dateCreated: '2026-10-31T03:04:54Z'
  - class: CommandLineTool
    id: mpa_ditto_summit_lundy
    baseCommand: python
    arguments:
      - /simulation/mpa.py
      - '--startdate'
      - valueFrom: $( inputs.startdate )
      - '--duration'
      - valueFrom: $( inputs.duration )
      - '--username'
      - valueFrom: $( inputs.username )
      - '--password'
      - valueFrom: $( inputs.password )
    inputs:
      startdate:
        type: string
        doc: The start time of the simulation
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
          glob: modeloutput/result.nc
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/mpa-ditto-summit-lundy:0.1.1
    hints:
      cwltool:Secrets:
        secrets:
          - password
    s:name: mpa_ditto_summit_lundy
    s:description: Runs (i) OpenDrift for Marine Protected Areas (MPAs).
    s:keywords:
      - opendrift
      - mpa
    s:programmingLanguage: python
    s:softwareVersion: 0.1.1
    s:producer:
      class: s:Organization
      s:name: SINTEF OCEAN
      s:url: https://sintef.no/en/ocean/
      s:address:
        class: s:PostalAddress
        s:addressCountry: 'NO'
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
          s:addressCountry: 'NO'
    s:author:
      - class: s:Person
        s:name: Arne Berre
        s:email: arne.j.berre@sintef.no
      - class: s:Person
        s:name: Volker Hoffmann
        s:email: volker.hoffmann@sintef.no
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://github.com/ILIAD-ocean-twin/application_package/tree/main/ditto-summut/mpa
    s:dateCreated: '2026-10-31T03:01:13Z'
  - class: CommandLineTool
    id: netcdf_metadata
    baseCommand: python
    arguments:
      - /opt/parse.py
      - '--netcdf_file'
      - valueFrom: $(inputs.netcdf_file)
      - valueFrom: $(inputs.extra_props ? ['--extra_props', inputs.extra_props] :[])
    inputs:
      netcdf_file:
        type: File
      extra_props:
        type: File?
    outputs:
      metadata:
        outputBinding:
          glob: ./metadata.json
        type: File
        format: edam:format_3464
    requirements:
      MultipleInputFeatureRequirement: {}
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/netcdf-metadata:0.1.0
    s:name: netcdf_metadata
    s:softwareVersion: 0.1.0
    s:description: Extract metadata from NetCDF file
    s:keywords:
      - netcdf
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
    s:dateCreated: '2025-11-13T17:39:29Z'
  - class: CommandLineTool
    id: 2stac2_mpa_pipeline
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
      connectivity:
        format: edam:format_3620
        doc: connectivity file
        type: File?
        inputBinding:
          prefix: '--file'
      connectivity_with_locality_id:
        format: edam:format_3620
        doc: connectivity with locality id
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
        dockerPull: iliad-repository.inesctec.pt/2stac2:0.3.2
      InplaceUpdateRequirement:
        inplaceUpdate: true
      InitialWorkDirRequirement:
        listing: |
          ${
            const content = JSON.parse(inputs.metadata.contents);
            const metadata = [];
            metadata.push({...content, filename:inputs["simulation"].basename});
            if(inputs["connectivity"] && inputs["connectivity"].basename)
              metadata.push({...content, filename:inputs["connectivity"].basename , media_type:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"});
            if(inputs["connectivity_with_locality_id"] && inputs["connectivity_with_locality_id"].basename)
              metadata.push({...content, filename:inputs["connectivity_with_locality_id"].basename , media_type:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"});
            return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
          }
    s:name: 2stac2_mpa_pipeline
    s:softwareVersion: 0.3.2
    s:description: 2stac2 tool to transform MPA simulation files into a STAC
    s:keywords:
      - stac
      - metadata
      - mpa
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
    s:dateCreated: '2026-10-30T16:34:27Z'
