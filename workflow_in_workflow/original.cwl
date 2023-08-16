cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: Workflow
  id: main_pipeline
  doc: Simulation steps pipeline
  inputs:
    lat:
      type: float
    lon:
      type: float
    time:
      type: string
    oiltype:
      type: string
    duration:
      type: int

  steps:
    step_1:
      run: '#step1'
      in:
        lat: lat
        lon: lon
      out:
      - metadata
    step_2:
      run: '#step2'
      in:
        time: time
        oiltype: oiltype
        duration: duration
      out:
      - result
    step_2stac:
      run: '#2stac'
      in:
        result: step_2/result
        metadata: step_1/metadata
      out:
      - results
      
  outputs:
  - id: wf_outputs
    outputSource:
    - step_2stac/results
    type:
      Directory

- class: CommandLineTool
  baseCommand: step1
  id: step1

  arguments:
  - --lat
  - valueFrom: $( inputs.lat )
  - --lon
  - valueFrom: $( inputs.lon )

  inputs:
    lat:
      type: float
      doc: The latitude of the study area
    lon:
      type: float
      doc: The longitude of the study area
      
  outputs:
    metadata:
      type: File
      outputBinding:
        glob: "result/metadata.json"
      doc: metadata description
      s:fileFormat: "application/json"
      
  requirements:
    NetworkAccess:
      networkAccess: true

    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/step1:1.0.1
  
- class: CommandLineTool
  baseCommand: step2
  id: step2

  arguments:
  - --time
  - valueFrom: $( inputs.time )
  - --oiltype
  - valueFrom: $( inputs.oiltype )
  - --duration
  - valueFrom: $( inputs.duration )
  inputs:
    time:
      type: string
      doc: The start time of the simulation
    oiltype:
      type: string
      doc: The type of the oil to run the simulation
    duration:
      type: int
      doc: The simulation duration
  outputs:
    result:
      type: File
      doc: A result file
      outputBinding:
        glob: "result/result.txt"
      
  requirements:
    # NetworkAccess:
    #   networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/step2:1.0.1


- class: CommandLineTool
  baseCommand: 2stac
  id: 2stac

  arguments:
  - --result
  - valueFrom: $( inputs.result )
  - --metadata
  - valueFrom: $( inputs.metadata )
  
  inputs:
    result:
      type: File
      doc: The resulting file of the previous model to insert in STAC 
      s:name: Input result file
      s:description: The resulting file of the previous model to insert in STAC 
      s:keywords:
        - result
        - File
      s:fileFormat: "*/*"
    metadata:
      type: File
      doc: The resulting metadata of the previous model to insert in STAC 
      s:name: Input metadata file
      s:description: The resulting metadata of the previous model to insert in STAC 
      s:keywords:
        - metadata
        - File
      s:fileFormat: "application/json"

  outputs:
    results:
      outputBinding:
        glob: .
      type: Directory
      doc: STAC output

  requirements:
    EnvVarRequirement:
      envDef:
        PATH: /srv/conda/envs/model-env/bin:/srv/conda/bin:/srv/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac:1.0.0

s:softwareVersion: 1.0.1
s:name: Steps example
s:description: Simulation workflows steps

