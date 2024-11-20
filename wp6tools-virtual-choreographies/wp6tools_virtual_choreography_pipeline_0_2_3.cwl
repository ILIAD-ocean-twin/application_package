cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  ogc: http://www.opengis.net/def/media-type/ogc/1.0/

$graph:

- class: Workflow
  id: wp6tools_virtual_choreographies_pipeline
  doc: wp6 workflow
  inputs:
    latitude:
      type: float
      label: Latitude
      doc: The latitude of the study area
    longitude:
      type: float
      label: Longitude
      doc: The longitude of the study area
    radius:
      type: float
      label: radius
      doc: The radius of the study area
    type:
      type: string
    url:
      type: string
    samples:
      type: string
    time:
      type: string
    minutes:
      type: string
    frames:
      type: string
    density:
      type: string
    output-format:
      type: string?
      default: stac

    template_file:
      type: string
    cesium_mappings:
      type: string
    unity_mappings:
      type: string

    region:
      type: string?
      doc: region
    endpoint:
      type: string
      doc: endpoint
    access_key:
      type: string
      doc: access_key
    secret_key:
      type: string
      doc: secret_key
    session_token:
      type: string?
      doc: region
    bucket:
      type: string
      doc: bucket

  steps:
    # step_point2bbox:
    #   run: '#point2bbox'
    #   in:
    #     lat: latitude
    #     lon: longitude
    #     radius: radius
    #   out:
    #   - lon_min
    #   - lon_max
    #   - lat_min
    #   - lat_max
    # step_bathymetry:
    #   run: '#bathymetry'
    #   in:
    #     lon_min: step_point2bbox/lon_min
    #     lon_max: step_point2bbox/lon_max
    #     lat_min: step_point2bbox/lat_min
    #     lat_max: step_point2bbox/lat_max
    #   out:
    #   - result
    #   - metadata
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
      out:
      - result
    step_extract_particles:
      run: '#extract-particles'
      in:
        input-file: step_generate_model/result
        output-format:
          default: "stac"
        projection-function:
          default: "none"
        projection-resolution:
          default: "none"
        latitude-variable:
          default: "lat"
        longitude-variable:
          default: "lon"
        time-variable:
          default: "time"
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
      run: '#json_append'
      in:
        files: dir2files/output_files
      out:
      - result
    step_virtual_choreographies_generator:
      run: '#virtual-choreographies-generator'
      in:
        dataset: json_append/result
        template: template_file
      out:
      - vc
    step_virtual_choreographies_unity_plugin:
      run: '#virtual-choreographies-unity-plugin'
      in:
        vc: step_virtual_choreographies_generator/vc
        mappings: unity_mappings
      out:
      - platform_choreography
    step_virtual_choreographies_cesium_plugin:
      run: '#virtual-choreographies-cesium-plugin'
      in:
        vc: step_virtual_choreographies_generator/vc
        mappings: cesium_mappings
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
      run: '#2stac2'
      in:
        unity_choreography: step_virtual_choreographies_cesium_plugin/platform_choreography
        cesium_choreography: step_virtual_choreographies_unity_plugin/platform_choreography
        metadata: step_metadata_2stact2/result
      out:
      - stac_result
    step_2s3:
      run: '#2s3'
      in:
        region: region
        endpoint: endpoint
        access_key: access_key
        secret_key: secret_key
        session_token: session_token
        bucket: bucket
        stac_result: step_2stac2/stac_result
      out:
        - base_path

  outputs:
  - id: wf_output_2stac2
    outputSource:
    - step_2stac2/stac_result
    type:
      Directory
#   - id: wf_output_bathymetry
#     outputSource:
#     - step_bathymetry/result
#     type:
#       File

  s:name: wp6tools virtual choreographies pipeline
  s:description: wp6 tools workflow to generate contours
  s:softwareVersion: 0.2.3
  s:keywords:
    - oil spill
    - opendrift
    - choreographies
    - virtual choreographies
    - 2s3
    - wp6
    - tools
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:author:
    - class: s:Person
      s:name: Alexandre Valle
      s:email: alexandre.valle@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/workflows/wp6tools/wp6tools_virtual_choreography_pipeline_0_2_1.cwl
  s:dateCreated: "2024-11-15T13:00:00Z"
  s:license: https://opensource.org/licenses/MIT

# - class: CommandLineTool

#   id: point2bbox

#   baseCommand: python
#   arguments:
#   - /opt/point2bbox.py
#   - --lat
#   - valueFrom: $( inputs.lat )
#   - --lon
#   - valueFrom: $( inputs.lon )
#   - --radius
#   - valueFrom: $( inputs.radius )

#   inputs:
#     lat:
#       type: float
#       doc: Latitude
#     lon:
#       type: float
#       doc: Longitude
#     radius:
#       type: float
#       doc: Radius

#   outputs:
#     lon_min:
#       type: float
#     lon_max:
#       type: float
#     lat_min:
#       type: float
#     lat_max:
#       type: float


#   requirements:
#     ResourceRequirement: {}
#     InlineJavascriptRequirement: {}
#     DockerRequirement:
#       dockerPull: iliad-repository.inesctec.pt/point2bbox:2.0.0

#   s:name: point to boundingBox
#   s:description: Convert a point and radius to a bounding box
#   s:keywords:
#     - point2bbox
#   s:programmingLanguage: python
#   s:softwareVersion: 2.0.0
#   s:sourceOrganization:
#     - class: s:Organization
#       s:name: INESCTEC
#       s:url: https://inesctec.pt
#   s:author:
#     - class: s:Person
#       s:name: Miguel Correia
#       s:email: miguel.r.correia@inesctec.pt
#   s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/point2bbox/point2bbox_2_0_0.cwl
#   s:dateCreated: "2024-11-14T17:34:32Z"

# - class: CommandLineTool

#   id: bathymetry

#   baseCommand: python
#   arguments:
#   - /opt/bathymetry.py
#   - --lon_min
#   - valueFrom: $( inputs.lon_min )
#   - --lon_max
#   - valueFrom: $( inputs.lon_max )
#   - --lat_min
#   - valueFrom: $( inputs.lat_min )
#   - --lat_max
#   - valueFrom: $( inputs.lat_max )

#   inputs:
#     lon_min:
#       type: float
#       doc: The minimum longitude of the study area.
#     lon_max:
#       type: float
#       doc: The maximum longitude of the study area.
#     lat_min:
#       type: float
#       doc: The minimum latitude of the study area.
#     lat_max:
#       type: float
#       doc: The maximum latitude of the study area.

#   outputs:
#     result:
#       format: ogc:netcdf
#       type: File
#       outputBinding:
#         glob: "result/out.nc"
#       doc: |
#         The output NetCDF file generated by the bathymetry model.
#         The file is in the OGC NetCDF media type.
#     metadata:
#       type: File
#       outputBinding:
#         glob: "result/metadata.json"
#       doc: metadata description

#   requirements:
#     NetworkAccess:
#         networkAccess: true
#     EnvVarRequirement:
#       envDef:
#         PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#         # GEBCO_URL: https://pipe-drive.inesctec.pt/inputs/GEBCO_2014_1D.nc
#     ResourceRequirement: {}
#     InlineJavascriptRequirement: {}
#     DockerRequirement:
#       dockerPull: iliad-repository.inesctec.pt/bathymetry-forth:2.0.0

#   s:name: Bathymetry for given bounding box
#   s:description: Get bathymetry to a given bounding box. You can define an outside source.
#   s:keywords:
#     - bathymetry
#     - bounding box
#   s:softwareVersion: 2.0.0
#   s:programmingLanguage: python
#   s:sourceOrganization:
#     - class: s:Organization
#       s:name: INESCTEC
#       s:url: https://inesctec.pt
#     - class: s:Organization
#       s:name: FORTH
#       s:url: https://forth.gr
#   s:author:
#     - class: s:Person
#       s:email: kspanoudaki@gmail.com
#       s:name: Katerina Spanoudaki
#   s:contributor:
#     - class: s:Person
#       s:email: miguel.r.correia@inesctec.pt
#       s:name: Miguel Correia
#   s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/bathymetry-forth/bathymetry_forth_2_0_0.cwl
#   s:dateCreated: "2024-11-14T19:47:14Z"


- class: CommandLineTool

  id: crop-frames

  baseCommand: python
  arguments:
  - /opt/main.py
  - crop-frames
  - --input-url
  - valueFrom: $( inputs['particles'])
  - --input-format
  - stac
  # - valueFrom: $( inputs['input-format'] )
  - --frames
  - valueFrom: $( inputs['frames'] )

  - --output-url
  - output/cropped

  inputs:
    particles:
      type: Directory
    # input-format:
    #   type: string
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
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0
  s:name: wp6-tools crop
  s:description: crop frames from wp6-tools
  s:keywords:
    - wp6-tools
    - crop
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:author:
    - class: s:Person
      s:name: Alexandre Valle
      s:email: alexandre.valle@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-crop-frames/wp6tools_crop_frames_0_2_0.cwl
  s:dateCreated: "2024-11-19T17:54:35Z"


- class: CommandLineTool

  id: extract-particles

  baseCommand: python
  arguments:
  - /opt/main.py
  - extract-particles
  - --input-url
  - valueFrom: $( inputs['input-file'] )
  - --output-format
  - valueFrom: $( inputs['output-format'] )
  - --projection-function
  - valueFrom: $( inputs['projection-function'] )
  - --projection-resolution
  - valueFrom: $( inputs['projection-resolution'] )
  - --latitude-variable
  - valueFrom: $( inputs['latitude-variable'] )
  - --longitude-variable
  - valueFrom: $( inputs["longitude-variable"] )
  - --time-variable
  - valueFrom: $( inputs["time-variable"] )

  - --output-url
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
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0
  s:name: wp6-tools extract
  s:description: extract particles frames from wp6-tools
  s:keywords:
    - wp6-tools
    - extract
    - particles
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:author:
    - class: s:Person
      s:name: Alexandre Valle
      s:email: alexandre.valle@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-extract-particles/wp6tools_extract_particles_0_2_0.cwl
  s:dateCreated: "2024-11-19T17:54:35Z"

- class: CommandLineTool

  id: generate-contours

  baseCommand: python
  arguments:
  - /opt/main.py
  - generate-contours-at-density
  - --input-url
  - valueFrom: $( inputs['cropped'])
  - --input-format
  - stac
  # - valueFrom: $( inputs['input-format'] )
  - --output-format
  - valueFrom: $( inputs['output-format'] )
  - --density
  - valueFrom: $( inputs['density'] )

  - --output-url
  - output/contours

  inputs:
    cropped:
      type: Directory
    # input-format:
    #   type: string
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
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0
  s:name: wp6-tools contours
  s:description: generate contours frames from wp6-tools
  s:keywords:
    - wp6-tools
    - contours
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:author:
    - class: s:Person
      s:name: Alexandre Valle
      s:email: alexandre.valle@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-contours/wp6tools_generate_contours_0_2_0.cwl
  s:dateCreated: "2024-11-19T17:54:35Z"

- class: CommandLineTool

  id: generate-model

  baseCommand: python
  arguments:
  - /opt/main.py
  - generate-model
  - --type
  - valueFrom: $( inputs.type )
  - --url
  - valueFrom: $( inputs.url )
  - --latitude
  - valueFrom: $( inputs.latitude )
  - --longitude
  - valueFrom: $( inputs.longitude )
  - --radius
  - valueFrom: $( inputs.radius )
  - --samples
  - valueFrom: $( inputs.samples )
  - --time
  - valueFrom: $( inputs.time )
  - --minutes
  - valueFrom: $( inputs.minutes )
  - --output-url
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

  outputs:
    result:
      type: File
      outputBinding:
        glob: output/oceandrift.nc

  requirements:
    NetworkAccess:
      networkAccess: true
    EnvVarRequirement:
      envDef:
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0

  s:name: wp6-tools model
  s:description: generate model frames from wp6-tools
  s:keywords:
    - wp6-tools
    - model
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:author:
    - class: s:Person
      s:name: Alexandre Valle
      s:email: alexandre.valle@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-generate-model/wp6tools_generate_model_0_2_0.cwl
  s:dateCreated: "2024-11-19T17:54:35Z"

- class: CommandLineTool

  id: metadata-2stact2

  baseCommand: python
  arguments:
  - /opt/main.py
  - metadata-2stac2
  - --latitude
  - valueFrom: $( inputs.latitude )
  - --longitude
  - valueFrom: $( inputs.longitude )
  - --radius
  - valueFrom: $( inputs.radius )
  - --time
  - valueFrom: $( inputs.time )
  - --frames
  - valueFrom: $( inputs.frames )
  - --output-url
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
      type: File
      outputBinding:
        glob: output/metadata.json

  requirements:
    EnvVarRequirement:
      envDef:
        PATH: /opt/miniconda3/envs/opendrift/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/wp6tools:0.2.0

  s:name: wp6-tools metadata
  s:description: generate metadata from wp6-tools to the 2stac2
  s:keywords:
    - wp6-tools
    - metadata
    - 2stac2
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-metadata-2stac2/wp6tools_metadata_2stac2_0_2_0.cwl
  s:dateCreated: "2024-11-19T17:54:35Z"

- class: CommandLineTool

  id: dir2files

  baseCommand: python
  arguments:
  - /opt/dir2files.py
  - --directory
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
        dockerPull: iliad-repository.inesctec.pt/dir2files:0.1.1
    EnvVarRequirement:
      envDef:
        PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

  s:name: dir2files
  s:description: Converts a directory to a list of files
  s:keywords:
    - directory
    - files
  s:programmingLanguage: bash
  s:softwareVersion: 0.1.1
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/dir2files/dir2files_0_1_1.cwl
  s:dateCreated: "2024-11-20T01:47:08Z"

- class: CommandLineTool

  id: json_append

  baseCommand: python
  arguments:
  - /opt/append.py
  - valueFrom: $(
      function () {

        var files_array = [];
        Object.keys(inputs.files).forEach(function (element) {
            console.log(inputs.files[element]);
            if(inputs.files[element].basename !== 'contour-header.json')
            files_array.push('--file');
            files_array.push(inputs.files[element]);
        });
        return files_array;

      }())

  inputs:
    files:
      type: File[]?
      doc: files

  outputs:
    result:
      type: File
      outputBinding:
        glob: "appended.json"
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
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/json-append/json_append_0_1_0.cwl
  s:dateCreated: "2024-11-14T15:34:32Z"

- class: CommandLineTool

  id: virtual-choreographies-generator

  baseCommand: python
  arguments:
  - /opt/src/vc_generator.py
  - valueFrom: $( inputs.dataset )
  - valueFrom: $( inputs.template )

  inputs:
    template:
     type: string
    dataset:
     type: File
  outputs:
    vc:
      type: File
      outputBinding:
        glob: vc.json

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-generator:0.1.1

  s:name: virtual-choreographies-generator
  s:description: Generator of virtual choreographies
  s:keywords:
    - wp6-tools
    - choreographies
    - virtual-choreographies
  s:programmingLanguage: python
  s:softwareVersion: 0.1.1
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:author:
    - class: s:Person
      s:name: Fernando Cassola
      s:email: fernando.c.marques@inesctec.pt
  s:mantainer:
    - class: s:Person
      s:name: Vitor Cavaleiro
      s:email: up202004724@edu.fe.up.pt
  s:codeRepository:
  s:dateCreated: "2024-11-19T19:54:39Z"

- class: CommandLineTool

  id: virtual-choreographies-cesium-plugin
  baseCommand: python
  arguments:
  - /opt/src/converter_cesium.py
  - valueFrom: $( inputs.vc )
  - valueFrom: $( inputs.mappings )

  inputs:
    vc:
     type: File
    mappings:
     type: string
  outputs:
    platform_choreography:
      type: File
      outputBinding:
        glob: platform_choreography.json
        outputEval: ${self[0].basename="platform_choreography_cesium.json"; return self;}

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-cesium-plugin:0.1.1

  s:name: virtual-choreographies-cesium-plugin
  s:description: Generator of cesium inputs to virtual choreographies
  s:keywords:
    - wp6-tools
    - choreographies
    - virtual-choreographies
    - cesium
  s:programmingLanguage: python
  s:softwareVersion: 0.1.1
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:author:
    - class: s:Person
      s:name: Fernando Cassola
      s:email: fernando.c.marques@inesctec.pt
  s:mantainer:
    - class: s:Person
      s:name: Vitor Cavaleiro
      s:email: vitor.cavaleiro@inesctec.pt
  s:codeRepository:
  s:dateCreated: "2024-11-19T19:54:39Z"

- class: CommandLineTool

  id: virtual-choreographies-unity-plugin
  baseCommand: python
  arguments:
  - /opt/src/converter_unity.py
  - valueFrom: $( inputs.vc )
  - valueFrom: $( inputs.mappings )

  inputs:
    vc:
     type: File
    mappings:
     type: string
  outputs:
    platform_choreography:
      type: File
      outputBinding:
        glob: platform_choreography.json
        outputEval: ${self[0].basename="platform_choreography_unity.json"; return self;}

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/virtual-choreographies-unity-plugin:0.1.1

  s:name: virtual-choreographies-unity-plugin
  s:description: Generator of unity inputs to virtual choreographies
  s:keywords:
    - wp6-tools
    - choreographies
    - virtual-choreographies
    - unity
  s:programmingLanguage: python
  s:softwareVersion: 0.1.1
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:author:
    - class: s:Person
      s:name: Fernando Cassola
      s:email: fernando.c.marques@inesctec.pt
  s:mantainer:
    - class: s:Person
      s:name: Vitor Cavaleiro
      s:email: vitor.cavaleiro@inesctec.pt
  s:codeRepository:
  s:dateCreated: "2024-11-19T19:54:39Z"

- class: CommandLineTool

  id: 2stac2

  baseCommand: python
  arguments:
  - /opt/2stac2.py
  - --file
  - valueFrom: $(inputs.unity_choreography)
  - --file
  - valueFrom: $(inputs.cesium_choreography)
  - --metadata
  - valueFrom: $(runtime.outdir + '/multiple_metadata.json')

  inputs:
    unity_choreography:
      doc: unity choreography json file
      type: File
    cesium_choreography:
      doc: cesium choreography json file
      type: File
    metadata:
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
        PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac2:2.0.1
    InplaceUpdateRequirement:
      inplaceUpdate: true
    InitialWorkDirRequirement:
      listing: |
        ${
          const content = JSON.parse(inputs.metadata.contents);
          const metadata = [];
          metadata.push({...content, filename:"platform_choreography_cesium.json"});
          metadata.push({...content, filename:"platform_choreography_unity.json" });
          return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
        }

  s:name: 2Stac2
  s:softwareVersion: 2.0.1
  s:description: Transform and array of files into a STAC
  s:keywords:
    - stac
    - metadata
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_2_0_1.cwl
  s:dateCreated: "2024-11-20T00:06:52Z"

- class: CommandLineTool

  id: 2s3

  baseCommand: python
  arguments:
  - /opt/2s3.py
  - --endpoint
  - valueFrom: $( inputs.endpoint )
  - --access_key
  - valueFrom: $( inputs.access_key )
  - --secret_key
  - valueFrom: $( inputs.secret_key )
  - --bucket
  - valueFrom: $( inputs.bucket )
  - --endpoint
  - valueFrom: $( inputs.endpoint )
  - valueFrom: $(
      function () {
        if (inputs.region) {
          return ["--region", inputs.region];
        } else {
          return [];
        }
      }())
  - --base_path
  - valueFrom: $(
      function () {
        return "wp6tools_virtual_choreographies_result_" + new Date().toISOString().replace(/:/g, '').replace(/\-/g, '').split('.')[0];
      }())
  - valueFrom: $(
      function () {
        if (inputs.session_token) {
          return ["--session_token", inputs.session_token];
        } else {
          return [];
        }
      }())
  - --directory
  - valueFrom: $( inputs.stac_result )

  inputs:
    region:
      type: string?
      doc: region
    endpoint:
      type: string
      doc: endpoint
    access_key:
      type: string
      doc: access_key
    secret_key:
      type: string
      doc: secret_key
    session_token:
      type: string?
      doc: session_token
    bucket:
      type: string
      doc: bucket
    stac_result:
      type: Directory
      doc: stac result folder

  outputs:
    base_path:
      type: string

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2s3:2.0.0
  hints:
    "cwltool:Secrets":
      secrets: [access_key,secret_key,session_token]

  s:name: 2s3
  s:description: Uploads files and/or folders to a S3 bucket storage.
  s:keywords:
    - s3
    - storage
  s:programmingLanguage: python
  s:softwareVersion: 2.0.0
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2s3/2s3_2_0_0.cwl
  s:dateCreated: "2024-11-15T11:49:11Z"