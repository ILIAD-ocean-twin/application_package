cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: pyopia_demo_pipeline
    doc: This pipeline runs the PyOPIA demo analysis for Norway.
    inputs: []
    steps:
      step_pyopia:
        run: '#pyopia_demo_sintef'
        in: []
        out:
          - particles_figure
          - vd_copepods
          - vd_copepods_per_L
          - netcdf_statistics
          - metadata
      step_2stac2:
        run: '#2stac2_pyopia_pipeline'
        in:
          simulation: step_pyopia/netcdf_statistics
          particles_figure: step_pyopia/particles_figure
          vd_copepods: step_pyopia/vd_copepods
          vd_copepods_per_L: step_pyopia/vd_copepods_per_L
          metadata: step_pyopia/metadata
        out:
          - stac_result
    outputs:
      - id: wf_outputs
        outputSource:
          - step_2stac2/stac_result
        type: Directory
    requirements:
      InlineJavascriptRequirement: {}
    s:name: pyopia_demo_pipeline
    s:description: >
      This pipeline runs a PyOPIA demo analysis, generating figures and
      statistics from copepod image data and packaging the results into a STAC
      output.
    s:keywords:
      - pyopia
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
    s:codeRepository: https://github.com/SINTEF/pyopia/tree/main
    s:dateCreated: '2025-11-24T23:38:39Z'
  - class: CommandLineTool
    id: pyopia_demo_sintef
    baseCommand: uv
    arguments:
      - run
      - /app/script.py
    inputs: []
    outputs:
      - id: netcdf_statistics
        type: File
        format: edam:format_3650
        outputBinding:
          glob: pyopiaproject/processed/pyopiaproject-STATS.nc
      - id: particles_figure
        type: File
        format: edam:format_3603
        outputBinding:
          glob: pyopiaproject/particles.png
      - id: vd_copepods
        type: File
        format: edam:format_3603
        outputBinding:
          glob: pyopiaproject/vd_copepods.png
      - id: vd_copepods_per_L
        type: File
        format: edam:format_3603
        outputBinding:
          glob: pyopiaproject/vd_copepods_per_L.png
      - id: metadata
        type: File
        format: edam:format_3464
        outputBinding:
          glob: pyopiaproject/nc_metadata.json
    requirements:
      NetworkAccess:
        networkAccess: true
      EnvVarRequirement:
        envDef:
          PATH: >-
            /app/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/pyopia-demo-sintef:0.1.0
    s:name: pyopia_demo_sintef
    s:description: Analysis of a small image example dataset using PyOPIA.
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
    s:dateCreated: '2025-10-29T18:07:13Z'
  - class: CommandLineTool
    id: 2stac2_pyopia_pipeline
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
      particles_figure:
        format: edam:format_3603
        doc: particles_figure
        type: File?
        inputBinding:
          prefix: '--file'
      vd_copepods:
        format: edam:format_3603
        doc: vd_copepods
        type: File?
        inputBinding:
          prefix: '--file'
      vd_copepods_per_L:
        format: edam:format_3603
        doc: vd_copepods_per_L
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
            metadata.push({...content, filename:inputs["particles_figure"].basename , media_type:"image/png"});
            metadata.push({...content, filename:inputs["vd_copepods"].basename , media_type:"image/png"});
            metadata.push({...content, filename:inputs["vd_copepods_per_L"].basename , media_type:"image/png"});
            return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
          }
    s:name: 2stac2_pyopia_pipeline
    s:softwareVersion: 0.3.1
    s:description: 2stac2 tool to transform pyopia simulation files into a STAC
    s:keywords:
      - stac
      - metadata
      - pyopia
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
    s:dateCreated: '2025-11-17T16:08:31Z'
