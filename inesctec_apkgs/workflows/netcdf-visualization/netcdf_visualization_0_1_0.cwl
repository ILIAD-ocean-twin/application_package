cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: netcdf_visualization_pipeline
    doc: netcdf visualization pipeline
    inputs:
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
      s3_bucket:
        type: string?
        doc: S3 storage bucket
      s3_path:
        type: string?
        doc: S3 path to file
      netcdf_file:
        type:
          - File?
          - string?
        label: netcdf file
        format: edam:format_3650
      frames:
        type: string
        label: narratives
      density:
        type: string
        label: narratives
      latitude:
        type: float
      longitude:
        type: float
      radius:
        type: float
      time:
        type: string
    steps:
      step_get_file:
        run: '#get_file'
        in:
          filename:
            default: simulation.nc
          file: netcdf_file
          s3_endpoint: s3_endpoint
          s3_region: s3_region
          s3_access_key: s3_access_key
          s3_secret_key: s3_secret_key
          s3_session_token: s3_session_token
          s3_bucket: s3_bucket
          s3_path: s3_path
        out:
          - file_output
      step_extract_particles:
        run: '#extract_particles'
        in:
          input-file: step_get_file/file_output
          output-format:
            default: stac
          projection-function:
            default: none
          projection-resolution:
            default: none
          latitude-variable:
            default: latitude
          longitude-variable:
            default: longitude
          time-variable:
            default: time
        out:
          - result
      step_crop_frames:
        run: '#crop_frames'
        in:
          particles: step_extract_particles/result
          frames: frames
        out:
          - result
      step_generate_contours:
        run: '#generate_contours'
        in:
          cropped: step_crop_frames/result
          density: density
          output-format:
            default: json
        out:
          - result
      dir2files:
        run: '#dir2files'
        in:
          input_dir: step_generate_contours/result
        out:
          - output_files
      json_append:
        run: '#json_append_wp6tools_pipeline'
        in:
          files: dir2files/output_files
        out:
          - result
      step_virtual_choreographies_generator:
        run: '#virtual_choreographies_generator'
        in:
          dataset: json_append/result
        out:
          - vc
          - recipe
      step_virtual_choreographies_unity_plugin:
        run: '#virtual_choreographies_transformer_plugin_unity'
        in:
          vc: step_virtual_choreographies_generator/vc
          vc_recipe: step_virtual_choreographies_generator/recipe
        out:
          - platform_choreography
      step_virtual_choreographies_cesium_plugin:
        run: '#virtual_choreographies_transformer_plugin_cesium'
        in:
          vc: step_virtual_choreographies_generator/vc
          vc_recipe: step_virtual_choreographies_generator/recipe
        out:
          - platform_choreography
      step_netcdf_metadata:
        in:
          netcdf_file: step_get_file/file_output
        run: '#netcdf_metadata'
        out:
          - metadata
      step_2stac2:
        run: '#2stac2_wp6tools_pipeline'
        in:
          unity_choreography: step_virtual_choreographies_cesium_plugin/platform_choreography
          cesium_choreography: step_virtual_choreographies_unity_plugin/platform_choreography
          simulation: step_get_file/file_output
          metadata: step_netcdf_metadata/metadata
        out:
          - stac_result
    outputs:
      - id: openoil
        outputSource:
          - step_2stac2/stac_result
        type: Directory
    hints:
      cwltool:Secrets:
        secrets:
          - access_key
          - secret_key
          - session_token
    requirements:
      InlineJavascriptRequirement: {}
    s:name: netcdf_visualization_pipeline
    s:description: netcdf visualization pipeline
    s:keywords:
      - oil spill
      - opendrift
      - choreographies
      - virtual choreographies
      - wp6
      - tools
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
      https://pipe-drive.inesctec.pt/application-packages/workflows/netcdf-visualization/netcdf_visualization_0_1_0.cwl
    s:dateCreated: '2025-06-10T01:54:24Z'
  - class: CommandLineTool
    id: get_file
    baseCommand: python
    arguments:
      - /opt/get-file.py
      - '--filename'
      - valueFrom: $( inputs.filename )
      - valueFrom: |
          ${ return inputs.file ? ["--file", inputs.file] : [] }
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
      - valueFrom: |
          ${ return inputs.s3_bucket ? ["--s3_bucket", inputs.s3_bucket] : [] }
      - valueFrom: |
          ${ return inputs.s3_path ? ["--s3_path", inputs.s3_path] : [] }
    inputs:
      filename:
        type: string
        doc: Name of the output file
      file:
        type:
          - string?
          - File?
        doc: URL to download the file or local path
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
      s3_bucket:
        type: string?
        doc: S3 storage bucket
      s3_path:
        type: string?
        doc: S3 path to file
    outputs:
      file_output:
        format: edam:format_3650
        type: File
        outputBinding:
          glob: $(inputs.filename)
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/get-file:0.1.0
    s:name: get_file
    s:description: Tool to download a file from a URL or S3 storage
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/get-file/get_file_netcdf_visualization_pipeline_0_1_0.cwl
    s:dateCreated: '2025-06-09T18:55:34Z'
  - class: CommandLineTool
    id: extract_particles
    baseCommand: python
    arguments:
      - /opt/main.py
      - extract-particles
      - '--input-url'
      - valueFrom: $( inputs['input-file'] )
      - '--output-format'
      - valueFrom: $( inputs['output-format'] )
      - '--projection-function'
      - valueFrom: $( inputs['projection-function'] )
      - '--projection-resolution'
      - valueFrom: $( inputs['projection-resolution'] )
      - '--latitude-variable'
      - valueFrom: $( inputs['latitude-variable'] )
      - '--longitude-variable'
      - valueFrom: $( inputs["longitude-variable"] )
      - '--time-variable'
      - valueFrom: $( inputs["time-variable"] )
      - '--output-url'
      - output/particles
    inputs:
      input-file:
        type: File
      output-format:
        type: string
      projection-function:
        type: string
      projection-resolution:
        type: string
      latitude-variable:
        type: string
      longitude-variable:
        type: string
      time-variable:
        type: string
    outputs:
      result:
        type: Directory
        outputBinding:
          glob: output/particles
    requirements:
      NetworkAccess:
        networkAccess: true
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0
    s:name: extract_particles
    s:description: extract particles frames from wp6-tools
    s:keywords:
      - wp6-tools
      - extract
      - particles
    s:programmingLanguage: python
    s:softwareVersion: 0.2.0
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
        s:name: Alexandre Valle
        s:email: alexandre.valle@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-extract-particles/wp6tools_extract_particles_0_2_0.cwl
    s:dateCreated: '2025-06-10T01:24:42Z'
  - class: CommandLineTool
    id: crop_frames
    baseCommand: python
    arguments:
      - /opt/main.py
      - crop-frames
      - '--input-url'
      - valueFrom: $( inputs['particles'])
      - '--input-format'
      - stac
      - '--frames'
      - valueFrom: $( inputs['frames'] )
      - '--output-url'
      - output/cropped
    inputs:
      particles:
        type: Directory
      frames:
        type: string
    outputs:
      result:
        type: Directory
        outputBinding:
          glob: output/cropped
    requirements:
      NetworkAccess:
        networkAccess: true
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0
    s:name: crop_frames
    s:description: crop frames from wp6-tools
    s:keywords:
      - wp6-tools
      - crop
    s:programmingLanguage: python
    s:softwareVersion: 0.2.0
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
        s:name: Alexandre Valle
        s:email: alexandre.valle@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-crop-frames/wp6tools_crop_frames_0_2_0.cwl
    s:dateCreated: '2025-06-10T01:24:42Z'
  - class: CommandLineTool
    id: generate_contours
    baseCommand: python
    arguments:
      - /opt/main.py
      - generate-contours-at-density
      - '--input-url'
      - valueFrom: $( inputs['cropped'])
      - '--input-format'
      - stac
      - '--output-format'
      - valueFrom: $( inputs['output-format'] )
      - '--density'
      - valueFrom: $( inputs['density'] )
      - '--output-url'
      - output/contours
    inputs:
      cropped:
        type: Directory
      output-format:
        type: string
        default: json
      density:
        type: string
    outputs:
      result:
        type: Directory
        outputBinding:
          glob: output/contours
    requirements:
      NetworkAccess:
        networkAccess: true
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0
    s:name: generate_contours
    s:description: generate contours frames from wp6-tools
    s:keywords:
      - wp6-tools
      - contours
    s:programmingLanguage: python
    s:softwareVersion: 0.2.0
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
        s:name: Alexandre Valle
        s:email: alexandre.valle@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-contours/wp6tools_generate_contours_0_2_0.cwl
    s:dateCreated: '2025-06-10T01:24:42Z'
  - class: CommandLineTool
    id: dir2files
    baseCommand: python
    arguments:
      - /opt/dir2files.py
      - '--directory'
      - valueFrom: $(inputs.input_dir)
    inputs:
      input_dir:
        type: Directory
    outputs:
      output_files:
        type: File[]
        outputBinding:
          glob: ./*
    requirements:
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/dir2files:0.1.0
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    s:name: dir2files
    s:description: Converts a directory to a list of files
    s:keywords:
      - directory
      - files
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/dir2files/dir2files_0_1_0.cwl
    s:dateCreated: '2025-05-12T12:12:44Z'
  - class: CommandLineTool
    id: json_append_wp6tools_pipeline
    baseCommand: python
    arguments:
      - /opt/append.py
      - valueFrom: >-
          $( function () {

          var files_array = []; Object.keys(inputs.files).forEach(function
          (element) { console.log(inputs.files[element]);
          if(inputs.files[element].basename !== 'contour-header.json')
          files_array.push('--file'); files_array.push(inputs.files[element]);
          }); return files_array;

          }())
    inputs:
      files:
        type: File[]?
        doc: files
    outputs:
      result:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: appended.json
        doc: json file appended
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/json-append:0.1.0
    s:name: json_append
    s:description: Append json files, objects and array of objects, to an array of objects
    s:keywords:
      - json
      - merge
      - append
      - metadata
    s:programmingLanguage: python
    s:softwareVersion: 0.1.0
    s:sourceOrganization:
      class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
    s:author:
      class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/json-append/json_append_wp6tools_pipeline_0_1_0.cwl
    s:dateCreated: '2025-05-12T12:23:08Z'
  - class: CommandLineTool
    id: virtual_choreographies_generator
    baseCommand: python
    arguments:
      - /opt/src/command.py
      - valueFrom: $( inputs.dataset )
      - valueFrom: >-
          $( inputs.template || inputs.template_url ||
          '/opt/templates/template.json')
    inputs:
      template:
        type: File?
      template_url:
        type: string?
      dataset:
        type: File
    outputs:
      vc:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: vc.json
      recipe:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: recipe.json
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-generator:0.3.0
    s:name: virtual_choreographies_generator
    s:description: Generator of virtual choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
    s:programmingLanguage: python
    s:softwareVersion: 0.3.0
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
        s:name: Fernando Cassola
        s:email: fernando.c.marques@inesctec.pt
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:maintainer:
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-generator/virtual_choreographies_generator_0_3_0.cwl
    s:dateCreated: '2025-06-10T00:22:25Z'
  - class: CommandLineTool
    id: virtual_choreographies_transformer_plugin_unity
    baseCommand: python
    arguments:
      - /opt/src/command.py
      - valueFrom: $( inputs.vc )
      - valueFrom: >-
          $( inputs.mappings || inputs.mappings_url || '/opt/mappings/unity.j2'
          )
      - valueFrom: $( inputs.vc_recipe || inputs.vc_recipe_url )
      - valueFrom: >-
          $( inputs.platform_recipe || inputs.platform_recipe_url ||
          '/opt/recipes/platform_recipe_unity.json')
    inputs:
      vc:
        type: File
      mappings:
        type: File?
      mappings_url:
        type: string?
      vc_recipe:
        type: File?
      vc_recipe_url:
        type: File?
      platform_recipe:
        type: File?
      platform_recipe_url:
        type: File?
    outputs:
      platform_choreography:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: result/platform_choreography.json
          outputEval: ${self[0].basename="platform_choreography_unity.json"; return self;}
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: >-
          iliad-repository.inesctec.pt/virtual-choreographies-transformer-plugin:0.3.0
    s:name: virtual_choreographies_transformer_plugin_unity
    s:description: >-
      Generator of platform specific choregoraphies form generic virtual
      choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
      - transformer
    s:programmingLanguage: python
    s:softwareVersion: 0.3.0
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
        s:name: Fernando Cassola
        s:email: fernando.c.marques@inesctec.pt
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:maintainer:
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-unity/virtual_choreographies_transformer_plugin_unity_0_3_0.cwl
    s:dateCreated: '2025-06-10T00:22:25Z'
  - class: CommandLineTool
    id: virtual_choreographies_transformer_plugin_cesium
    baseCommand: python
    arguments:
      - /opt/src/command.py
      - valueFrom: $( inputs.vc )
      - valueFrom: >-
          $( inputs.mappings || inputs.mappings_url || '/opt/mappings/cesium.j2'
          )
      - valueFrom: $( inputs.vc_recipe || inputs.vc_recipe_url)
      - valueFrom: >-
          $( inputs.platform_recipe || inputs.platform_recipe_url ||
          '/opt/recipes/platform_recipe_cesium.json')
    inputs:
      vc:
        type: File
      mappings:
        type: File?
      mappings_url:
        type: string?
      vc_recipe:
        type: File?
      vc_recipe_url:
        type: File?
      platform_recipe:
        type: File?
      platform_recipe_url:
        type: File?
    outputs:
      platform_choreography:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: result/platform_choreography.json
          outputEval: >-
            ${self[0].basename="platform_choreography_cesium.json"; return
            self;}
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: >-
          iliad-repository.inesctec.pt/virtual-choreographies-transformer-plugin:0.3.0
    s:name: virtual_choreographies_transformer_plugin_cesium
    s:description: >-
      Generator of platform specific choregoraphies form generic virtual
      choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
      - transformer
    s:programmingLanguage: python
    s:softwareVersion: 0.3.0
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
        s:name: Fernando Cassola
        s:email: fernando.c.marques@inesctec.pt
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:maintainer:
      - class: s:Person
        s:name: Vitor Cavaleiro
        s:email: vitor.cavaleiro@inesctec.pt
    s:contributor:
      - class: s:Person
        s:name: Miguel Correia
        s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-cesium/virtual_choreographies_transformer_plugin_cesium_0_3_0.cwl
    s:dateCreated: '2025-06-10T00:22:25Z'
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/netcdf-metadata/netcdf_metadata_0_1_0.cwl
    s:dateCreated: '2025-06-10T01:07:05Z'
  - class: CommandLineTool
    id: 2stac2_wp6tools_pipeline
    baseCommand: python
    arguments:
      - /opt/2stac2.py
      - valueFrom: >-
          $( function () { if (inputs["unity_choreography"]) { return ["--file",
          inputs["unity_choreography"]]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs["cesium_choreography"]) { return
          ["--file", inputs["cesium_choreography"]]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs["simulation"]) { return ["--file",
          inputs["simulation"]]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs["animation"]) { return ["--file",
          inputs["animation"]]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs["bathymetry"]) { return ["--file",
          inputs["bathymetry"]]; } else { return []; } }())
      - '--metadata'
      - valueFrom: $(runtime.outdir + '/multiple_metadata.json')
    inputs:
      unity_choreography:
        format: edam:format_3464
        doc: unity choreography json file
        type: File?
      cesium_choreography:
        format: edam:format_3464
        doc: cesium choreography json file
        type: File?
      simulation:
        format: edam:format_3650
        doc: NetCDF simulation file
        type: File?
      animation:
        format: edam:format_3467
        doc: Animation GIF file
        type: File?
      bathymetry:
        format: edam:format_3650
        doc: Bathymetry NetCDF file
        type: File?
      metadata:
        format: edam:format_3464
        doc: metadata file description
        type: File
        loadContents: true
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
        dockerPull: iliad-repository.inesctec.pt/2stac2:0.3.0
      InplaceUpdateRequirement:
        inplaceUpdate: true
      InitialWorkDirRequirement:
        listing: |
          ${
            const content = JSON.parse(inputs.metadata.contents);
            const metadata = [];
            if(inputs.unity_choreography) metadata.push({...content, filename: inputs.unity_choreography.basename});
            if(inputs.cesium_choreography) metadata.push({...content, filename: inputs.cesium_choreography.basename});
            if(inputs.simulation) metadata.push({...content, filename: inputs.simulation.basename});
            if(inputs.animation) metadata.push({...content, filename: inputs.animation.basename});
            if(inputs.bathymetry) metadata.push({...content, filename: inputs.bathymetry.basename});
            return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
          }
    s:name: 2stac2_wp6tools_pipeline
    s:softwareVersion: 0.3.0
    s:description: 2stac2 for WP6 tools pipeline
    s:keywords:
      - stac
      - metadata
    s:programmingLanguage: python
    s:sourceOrganization:
      class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
        class: s:PostalAddress
        s:addressCountry: PT
    s:author:
      class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_wp6tools_pipeline_0_3_0.cwl
    s:dateCreated: '2025-06-10T00:47:37Z'
