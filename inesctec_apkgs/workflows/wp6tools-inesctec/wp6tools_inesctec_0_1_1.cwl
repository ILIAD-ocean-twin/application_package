cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#
  edam: http://edamontology.org/
$graph:
  - class: Workflow
    id: wp6tools_pipeline
    doc: wp6 workflow
    inputs:
      bathymetry:
        type: boolean?
        doc: If want to generate bathymetry
        label: bathymetry
      latitude:
        type: float
        doc: The latitude of the study area
        label: narratives
      longitude:
        type: float
        doc: The longitude of the study area
        label: narratives
      radius:
        type: float
        doc: The radius of the study area
        label: narratives
      type:
        type: string
        label: narratives
      url:
        type: string
        label: narratives
      samples:
        type: string
        label: narratives
      time:
        type: string
        label: narratives
      minutes:
        type: string
        label: narratives
      frames:
        type: string
        label: narratives
      density:
        type: string
        label: narratives
      output-format:
        type: string?
        default: stac
        label: narratives
      depth:
        type: float?
      output-animation:
        type: boolean?
        label: narratives
      endpoint:
        type: string?
        doc: S3 storage endpoint
        label: s3storage
      region:
        type: string?
        doc: S3 storage region
        label: s3storage
      access_key:
        type: string?
        doc: S3 storage access_key
        label: s3storage
      secret_key:
        type: string?
        doc: S3 storage secret_key
        label: s3storage
      session_token:
        type: string?
        doc: S3 storage region
        label: s3storage
      bucket:
        type: string?
        doc: S3 storage bucket
        label: s3storage
      base_path:
        type: string?
        doc: S3 storage final directory name
        default: wp6tools_virtual_choreographies_pipeline
        label: s3storage
    steps:
      step_point2bbox:
        when: $(inputs.bathymetry == true)
        run: '#point2bbox'
        in:
          bathymetry: bathymetry
          lat: latitude
          lon: longitude
          radius: radius
        out:
          - lon_min
          - lon_max
          - lat_min
          - lat_max
      step_bathymetry:
        when: $(inputs.bathymetry == true)
        run: '#bathymetry'
        in:
          bathymetry: bathymetry
          lon_min: step_point2bbox/lon_min
          lon_max: step_point2bbox/lon_max
          lat_min: step_point2bbox/lat_min
          lat_max: step_point2bbox/lat_max
        out:
          - result
          - metadata
      step_generate_model:
        run: '#generate-model'
        in:
          type: type
          url: url
          latitude: latitude
          longitude: longitude
          radius: radius
          samples: samples
          time: time
          minutes: minutes
          output-animation: output-animation
        out:
          - result
          - animation
      step_extract_particles:
        run: '#extract-particles'
        in:
          input-file: step_generate_model/result
          output-format:
            default: stac
          projection-function:
            default: none
          projection-resolution:
            default: none
          latitude-variable:
            default: lat
          longitude-variable:
            default: lon
          time-variable:
            default: time
        out:
          - result
      step_crop_frames:
        run: '#crop-frames'
        in:
          particles: step_extract_particles/result
          frames: frames
        out:
          - result
      step_generate_contours:
        run: '#generate-contours'
        in:
          cropped: step_crop_frames/result
          density: density
          output-format: output-format
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
        run: '#virtual-choreographies-generator'
        in:
          dataset: json_append/result
        out:
          - vc
          - recipe
      step_virtual_choreographies_unity_plugin:
        run: '#virtual-choreographies-transformer-plugin-unity'
        in:
          vc: step_virtual_choreographies_generator/vc
          vc_recipe: step_virtual_choreographies_generator/recipe
        out:
          - platform_choreography
      step_virtual_choreographies_cesium_plugin:
        run: '#virtual-choreographies-transformer-plugin-cesium'
        in:
          vc: step_virtual_choreographies_generator/vc
          vc_recipe: step_virtual_choreographies_generator/recipe
        out:
          - platform_choreography
      step_metadata_2stact2:
        run: '#metadata-2stact2'
        in:
          latitude: latitude
          longitude: longitude
          radius: radius
          frames: frames
          time: time
        out:
          - result
      step_2stac2:
        run: '#2stac2_wp6tools_pipeline'
        in:
          unity_choreography: step_virtual_choreographies_cesium_plugin/platform_choreography
          cesium_choreography: step_virtual_choreographies_unity_plugin/platform_choreography
          simulation: step_generate_model/result
          animation: step_generate_model/animation
          metadata: step_metadata_2stact2/result
          bathymetry: step_bathymetry/result
        out:
          - stac_result
      step_2s3:
        run: '#2s3'
        when: $(inputs.endpoint != null && inputs.endpoint != "")
        in:
          region: region
          endpoint: endpoint
          access_key: access_key
          secret_key: secret_key
          session_token: session_token
          bucket: bucket
          directory: step_2stac2/stac_result
        out:
          - base_path
    outputs:
      - id: openoil
        outputSource:
          - step_2stac2/stac_result
        type: Directory
      - id: contours
        outputSource:
          - step_generate_contours/result
        type: Directory
      - id: dataset
        outputSource:
          - json_append/result
        type: File
      - id: vc
        outputSource:
          - step_virtual_choreographies_generator/vc
        type: File
      - id: recipe
        outputSource:
          - step_virtual_choreographies_generator/recipe
        type: File
    hints:
      cwltool:Secrets:
        secrets:
          - access_key
          - secret_key
          - session_token
    requirements:
      InlineJavascriptRequirement: {}
    s:name: wp6tools_pipeline
    s:description: wp6 tools workflow to generate contours
    s:keywords:
      - oil spill
      - opendrift
      - choreographies
      - virtual choreographies
      - 2s3
      - wp6
      - tools
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
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/workflows/wp6tools-inesctec/wp6tools_inesctec_0_1_1.cwl
    s:dateCreated: '2025-05-26T10:28:35Z'
  - class: CommandLineTool
    id: point2bbox
    baseCommand: python
    arguments:
      - /opt/point2bbox.py
      - '--lat'
      - valueFrom: $( inputs.lat )
      - '--lon'
      - valueFrom: $( inputs.lon )
      - '--radius'
      - valueFrom: $( inputs.radius )
    inputs:
      lat:
        type: float
        doc: Latitude
      lon:
        type: float
        doc: Longitude
      radius:
        type: float
        doc: Radius
    outputs:
      lon_min:
        type: float
      lon_max:
        type: float
      lat_min:
        type: float
      lat_max:
        type: float
    requirements:
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/point2bbox:0.1.0
    s:name: point2bbox
    s:description: Convert a point and radius to a bounding box
    s:keywords:
      - point2bbox
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
      https://pipe-drive.inesctec.pt/application-packages/tools/point2bbox/point2bbox_0_1_0.cwl
    s:dateCreated: '2025-05-12T12:37:42Z'
  - class: CommandLineTool
    id: bathymetry
    baseCommand: python
    arguments:
      - /opt/bathymetry.py
      - '--lon_min'
      - valueFrom: $( inputs.lon_min )
      - '--lon_max'
      - valueFrom: $( inputs.lon_max )
      - '--lat_min'
      - valueFrom: $( inputs.lat_min )
      - '--lat_max'
      - valueFrom: $( inputs.lat_max )
    inputs:
      lon_min:
        type: float
        doc: The minimum longitude of the study area.
      lon_max:
        type: float
        doc: The maximum longitude of the study area.
      lat_min:
        type: float
        doc: The minimum latitude of the study area.
      lat_max:
        type: float
        doc: The maximum latitude of the study area.
    outputs:
      result:
        format: edam:format_3650
        type: File
        outputBinding:
          glob: result/out.nc
        doc: |
          The output NetCDF file generated by the bathymetry model.
          The file is in the OGC NetCDF media type.
      metadata:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: result/metadata.json
        doc: metadata description
    requirements:
      NetworkAccess:
        networkAccess: true
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/bathymetry-forth:0.1.0
    s:name: bathymetry
    s:description: Get bathymetry to a given bounding box. You can define an outside source.
    s:keywords:
      - bathymetry
      - bounding box
    s:softwareVersion: 0.1.0
    s:programmingLanguage: python
    s:producer:
      class: s:Organization
      s:name: FORTH
      s:url: https://forth.gr
      s:address:
        class: s:PostalAddress
        s:addressCountry: GR
    s:sourceOrganization:
      - class: s:Organization
        s:name: INESCTEC
        s:url: https://inesctec.pt
        s:address:
          class: s:PostalAddress
          s:addressCountry: PT
      - class: s:Organization
        s:name: FORTH
        s:url: https://forth.gr
        s:address:
          class: s:PostalAddress
          s:addressCountry: GR
    s:author:
      - class: s:Person
        s:email: kspanoudaki@gmail.com
        s:name: Katerina Spanoudaki
    s:contributor:
      - class: s:Person
        s:email: miguel.r.correia@inesctec.pt
        s:name: Miguel Correia
    s:codeRepository: >-
      https://pipe-drive.inesctec.pt/application-packages/tools/bathymetry-forth/bathymetry_forth_0_1_0.cwl
    s:dateCreated: '2025-05-12T11:45:31Z'
  - class: CommandLineTool
    id: generate-model
    baseCommand: python
    arguments:
      - /opt/main.py
      - generate-model
      - '--type'
      - valueFrom: $( inputs.type )
      - '--url'
      - valueFrom: $( inputs.url )
      - '--latitude'
      - valueFrom: $( inputs.latitude )
      - '--longitude'
      - valueFrom: $( inputs.longitude )
      - '--radius'
      - valueFrom: $( inputs.radius )
      - '--samples'
      - valueFrom: $( inputs.samples )
      - '--time'
      - valueFrom: $( inputs.time )
      - '--minutes'
      - valueFrom: $( inputs.minutes )
      - valueFrom: >-
          $( function () { if (inputs["output-animation"]) { return
          ["--output-animation", "true"]; } else { return []; } }())
      - valueFrom: $( function () { return ["--depth", inputs["depth"]]; }())
      - '--output-url'
      - output/oceandrift.nc
    inputs:
      type:
        type: string
      url:
        type: string
      latitude:
        type: float
      longitude:
        type: float
      radius:
        type: float
      samples:
        type: string
      time:
        type: string
      minutes:
        type: string
      output-animation:
        type: boolean?
      depth:
        type: float?
        default: 0
    outputs:
      result:
        format: edam:format_3650
        type: File
        outputBinding:
          glob: output/oceandrift.nc
      animation:
        format: edam:format_3467
        type: File?
        outputBinding:
          glob: output/animation.gif
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
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.2
    s:name: generate-model
    s:description: generate model frames from wp6-tools
    s:keywords:
      - wp6-tools
      - model
    s:programmingLanguage: python
    s:softwareVersion: 0.1.2
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
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-model/wp6tools_generate_model_0_1_2.cwl
    s:dateCreated: '2025-05-20T17:09:37Z'
  - class: CommandLineTool
    id: extract-particles
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
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.2
    s:name: extract-particles
    s:description: extract particles frames from wp6-tools
    s:keywords:
      - wp6-tools
      - extract
      - particles
    s:programmingLanguage: python
    s:softwareVersion: 0.1.2
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
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-extract-particles/wp6tools_extract_particles_0_1_2.cwl
    s:dateCreated: '2025-05-20T17:09:37Z'
  - class: CommandLineTool
    id: crop-frames
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
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.2
    s:name: crop-frames
    s:description: crop frames from wp6-tools
    s:keywords:
      - wp6-tools
      - crop
    s:programmingLanguage: python
    s:softwareVersion: 0.1.2
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
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-crop-frames/wp6tools_crop_frames_0_1_2.cwl
    s:dateCreated: '2025-05-20T17:09:37Z'
  - class: CommandLineTool
    id: generate-contours
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
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.2
    s:name: generate-contours
    s:description: generate contours frames from wp6-tools
    s:keywords:
      - wp6-tools
      - contours
    s:programmingLanguage: python
    s:softwareVersion: 0.1.2
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
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-contours/wp6tools_generate_contours_0_1_2.cwl
    s:dateCreated: '2025-05-20T17:09:37Z'
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
    id: virtual-choreographies-generator
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
        dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-generator:0.2.1
    s:name: virtual-choreographies-generator
    s:description: Generator of virtual choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
    s:programmingLanguage: python
    s:softwareVersion: 0.2.1
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
      https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-generator/virtual_choreographies_generator_0_2_1.cwl
    s:dateCreated: '2025-05-26T10:06:27Z'
  - class: CommandLineTool
    id: virtual-choreographies-transformer-plugin-unity
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
          iliad-repository.inesctec.pt/virtual-choreographies-transformer-plugin:0.2.1
    s:name: virtual-choreographies-transformer-plugin-unity
    s:description: >-
      Generator of platform specific choregoraphies form generic virtual
      choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
      - transformer
    s:programmingLanguage: python
    s:softwareVersion: 0.2.1
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
      https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-unity/virtual_choreographies_transformer_plugin_unity_0_2_1.cwl
    s:dateCreated: '2025-05-26T10:06:27Z'
  - class: CommandLineTool
    id: virtual-choreographies-transformer-plugin-cesium
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
          iliad-repository.inesctec.pt/virtual-choreographies-transformer-plugin:0.2.1
    s:name: virtual-choreographies-transformer-plugin-cesium
    s:description: >-
      Generator of platform specific choregoraphies form generic virtual
      choreographies
    s:keywords:
      - wp6-tools
      - choreographies
      - virtual-choreographies
      - transformer
    s:programmingLanguage: python
    s:softwareVersion: 0.2.1
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
      https://pipe-drive.inesctec.pt/application-packages/tools/virtual-choreographies-transformer-plugin-cesium/virtual_choreographies_transformer_plugin_cesium_0_2_1.cwl
    s:dateCreated: '2025-05-26T10:06:27Z'
  - class: CommandLineTool
    id: metadata-2stact2
    baseCommand: python
    arguments:
      - /opt/main.py
      - metadata-2stac2
      - '--latitude'
      - valueFrom: $( inputs.latitude )
      - '--longitude'
      - valueFrom: $( inputs.longitude )
      - '--radius'
      - valueFrom: $( inputs.radius )
      - '--time'
      - valueFrom: $( inputs.time )
      - '--frames'
      - valueFrom: $( inputs.frames )
      - '--output-url'
      - output/metadata.json
    inputs:
      latitude:
        type: float
      longitude:
        type: float
      radius:
        type: float
      time:
        type: string
      frames:
        type: string
    outputs:
      result:
        format: edam:format_3464
        type: File
        outputBinding:
          glob: output/metadata.json
    requirements:
      EnvVarRequirement:
        envDef:
          PATH: >-
            /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/wp6tools:0.1.2
    s:name: metadata-2stact2
    s:description: generate metadata from wp6-tools to the 2stac2
    s:keywords:
      - wp6-tools
      - metadata
      - 2stac2
    s:programmingLanguage: python
    s:softwareVersion: 0.1.2
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
      https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-metadata-2stac2/wp6tools_metadata_2stac2_0_1_2.cwl
    s:dateCreated: '2025-05-20T17:09:37Z'
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
        dockerPull: iliad-repository.inesctec.pt/2stac2:0.1.3
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
    s:softwareVersion: 0.1.3
    s:description: Transform and array of files into a STAC
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
      https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_wp6tools_pipeline_0_1_3.cwl
    s:dateCreated: '2025-05-21T15:08:53Z'
  - class: CommandLineTool
    id: 2s3
    baseCommand: python
    arguments:
      - /opt/2s3.py
      - '--endpoint'
      - valueFrom: $( inputs.endpoint )
      - '--access_key'
      - valueFrom: $( inputs.access_key )
      - '--secret_key'
      - valueFrom: $( inputs.secret_key )
      - '--bucket'
      - valueFrom: $( inputs.bucket )
      - '--endpoint'
      - valueFrom: $( inputs.endpoint )
      - valueFrom: >-
          $( function () { if (inputs.region) { return ["--region",
          inputs.region]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs.base_path) { return ["--base_path",
          `${inputs.base_path}_${new Date().toISOString().replace(/:/g,
          '').replace(/\-/g, '').split('.')[0]}`]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if (inputs.session_token) { return
          ["--session_token", inputs.session_token]; } else { return []; } }())
      - valueFrom: >-
          $( function () { if(inputs.files) { var files_array = [];

          Object.keys(inputs.files).forEach(function (element) {
          files_array.push('--file'); files_array.push(inputs.files[element]);
          });

          return files_array; } else { return []; } }())
      - valueFrom: >-
          $( function () { if(inputs.directories) { var directories_array = [];

          Object.keys(inputs.directories).forEach(function (element) {
          directories_array.push('--directory');
          directories_array.push(inputs.directories[element]); });

          return directories_array; } else { return []; } }())
      - valueFrom: >-
          $( function () { if(inputs.file) { return ['--file', inputs.file]; }
          else { return []; } }())
      - valueFrom: >-
          $( function () { if(inputs.directory) { return ['--directory',
          inputs.directory]; } else { return []; } }())
    inputs:
      endpoint:
        type: string?
        doc: S3 storage endpoint
      region:
        type: string?
        doc: S3 storage region
      access_key:
        type: string?
        doc: S3 storage access_key
      secret_key:
        type: string?
        doc: S3 storage secret_key
      session_token:
        type: string?
        doc: S3 storage region
      bucket:
        type: string?
        doc: S3 storage bucket
      base_path:
        type: string?
        doc: S3 storage final directory name
      files:
        type: File[]?
        doc: Multiple files to upload
      directories:
        type: Directory[]?
        doc: Multiple directories to upload
      directory:
        type: Directory?
        doc: Single directory to upload
      file:
        type: File?
        doc: Single file to upload
    outputs:
      base_path:
        type: string
    requirements:
      NetworkAccess:
        networkAccess: true
      ResourceRequirement: {}
      InlineJavascriptRequirement: {}
      DockerRequirement:
        dockerPull: iliad-repository.inesctec.pt/2s3:0.1.0
    hints:
      cwltool:Secrets:
        secrets:
          - access_key
          - secret_key
          - session_token
    s:name: 2s3
    s:description: Uploads files and/or folders to a S3 bucket storage.
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
      https://pipe-drive.inesctec.pt/application-packages/tools/2s3/2s3_0_1_0.cwl
    s:dateCreated: '2025-05-12T11:03:57Z'
