cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: pyopia_pipeline
    doc: This pipeline runs a pyopia
    inputs:
      dir_name:
        type: string?
        doc: Name of the output directory
        default: pyopia_inputs
      directory:
        type:
          - string?
          - Directory?
        doc: URL to download the directory or local path
      s3_endpoint:
        type: string?
        doc: S3 storage endpoint
      s3_region:
        type: string?
        doc: S3 storage region
      s3_access_key:
        type: string?
        doc: S3 storage access_key
      s3_secret_key:
        type: string?
        doc: S3 storage secret_key
      s3_session_token:
        type: string?
        doc: S3 storage region
      s3_bucket_name:
        type: string?
        doc: S3 storage bucket
      s3_path:
        type: string?
        doc: S3 path to the directory
    steps:
      step_get_dir:
        run: '#get_dir_pyopia_pipeline'
        in:
          dir_name: dir_name
          directory: directory
          s3_endpoint: s3_endpoint
          s3_region: s3_region
          s3_access_key: s3_access_key
          s3_secret_key: s3_secret_key
          s3_session_token: s3_session_token
          s3_bucket_name: s3_bucket_name
          s3_path: s3_path
        out:
          - images
          - auxiliary_data
          - config
          - metadata
          - model_classifier
      step_pyopia:
        run: '#pyopia_sintef'
        in:
          images: step_get_dir/images
          auxiliary_data: step_get_dir/auxiliary_data
          config: step_get_dir/config
          metadata: step_get_dir/metadata
          model_classifier: step_get_dir/model_classifier
        out:
          - netcdf_statistics
          - particles_figure
          - vd_copepods
          - vd_copepods_per_L
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
    s:name: pyopia_pipeline
    s:description: >
      This pipeline runs a PyOPIA analysis, generating figures and statistics
      from copepod image data and packaging the results into a STAC output.
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
    s:dateCreated: '2025-11-24T23:31:23Z'
  - class: CommandLineTool
    id: get_dir_pyopia_pipeline
    baseCommand: python
    arguments:
      - /opt/get-dir.py
      - '--dir_name'
      - valueFrom: $( inputs.dir_name )
      - valueFrom: |
          ${ return inputs.directory ? ["--directory", inputs.directory] : [] }
      - valueFrom: >
          ${ return inputs.s3_endpoint ? ["--s3_endpoint", inputs.s3_endpoint] :
          [] }
      - valueFrom: |
          ${ return inputs.s3_region ? ["--s3_region", inputs.s3_region] : [] }
      - valueFrom: >
          ${ return inputs.s3_access_key ? ["--s3_access_key",
          inputs.s3_access_key] : [] }
      - valueFrom: >
          ${ return inputs.s3_secret_key ? ["--s3_secret_key",
          inputs.s3_secret_key] : [] }
      - valueFrom: >
          ${ return inputs.s3_session_token ? ["--s3_session_token",
          inputs.s3_session_token] : [] }
      - valueFrom: >
          ${ return inputs.s3_bucket_name ? ["--s3_bucket",
          inputs.s3_bucket_name] : [] }
      - valueFrom: |
          ${ return inputs.s3_path ? ["--s3_path", inputs.s3_path] : [] }
    inputs:
      dir_name:
        type: string?
        doc: Name of the output directory
        default: pyopia_inputs
      directory:
        type:
          - string?
          - Directory?
        doc: URL to download the directory or local path
      s3_endpoint:
        type: string?
        doc: S3 storage endpoint
      s3_region:
        type: string?
        doc: S3 storage region
      s3_access_key:
        type: string?
        doc: S3 storage access_key
      s3_secret_key:
        type: string?
        doc: S3 storage secret_key
      s3_session_token:
        type: string?
        doc: S3 storage region
      s3_bucket_name:
        type: string?
        doc: S3 storage bucket
      s3_path:
        type: string?
        doc: S3 path to the directory
    outputs:
      images:
        type: Directory
        doc: Input image directory
        outputBinding:
          glob: $(inputs.dir_name)/images
      auxiliary_data:
        type: File
        doc: Auxiliary data file
        outputBinding:
          glob: $(inputs.dir_name)/auxillarydata/auxillary_data.csv
      config:
        type: File
        doc: Configuration file
        outputBinding:
          glob: $(inputs.dir_name)/config.toml
      metadata:
        type: File
        doc: Metadata file
        outputBinding:
          glob: $(inputs.dir_name)/metadata.json
      model_classifier:
        type: File?
        doc: Model classifier file
        outputBinding:
          glob: $(inputs.dir_name)/*.keras
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/get-dir:0.1.0
    s:name: get_dir_pyopia_pipeline
    s:description: Tool to download images from a URL or S3 storage
    s:keywords:
      - s3
      - storage
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
    s:dateCreated: '2025-11-13T17:16:45Z'
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
          prefix: '--images'
      auxiliary_data:
        type: File
        doc: Auxiliary data file
        inputBinding:
          prefix: '--auxiliary_data'
      config:
        type: File
        doc: Configuration file
        inputBinding:
          prefix: '--config'
      metadata:
        type: File
        doc: Metadata file
        inputBinding:
          prefix: '--metadata'
      model_path:
        type: File?
        doc: Model classifier file
        inputBinding:
          prefix: '--model_path'
    outputs:
      - id: netcdf_statistics
        type: File
        format: edam:format_3650
        outputBinding:
          glob: results-STATS.nc
      - id: particles_figure
        type: File
        format: edam:format_3603
        outputBinding:
          glob: particles.png
      - id: vd_copepods
        type: File
        format: edam:format_3603
        outputBinding:
          glob: vd_copepods.png
      - id: vd_copepods_per_L
        type: File
        format: edam:format_3603
        outputBinding:
          glob: vd_copepods_per_L.png
      - id: metadata
        type: File
        format: edam:format_3464
        outputBinding:
          glob: nc_metadata.json
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
    s:dateCreated: '2025-11-13T21:42:33Z'
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
