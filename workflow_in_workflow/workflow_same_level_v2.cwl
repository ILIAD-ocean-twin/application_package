cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: Workflow
  id: second_pipeline
  doc: Simulation of 2 workflows
  requirements:
  - class: SubworkflowFeatureRequirement
  inputs: []
  steps:
    generate_inputs:
      run: '#step0'
      in: []
      out:
      - lat
      - lon
      - time
      - oiltype
      - duration
    pipeline:
      run: '#main_pipeline'
      in: 
        lat: generate_inputs/lat
        lon: generate_inputs/lon
        time: generate_inputs/time
        oiltype: generate_inputs/oiltype
        duration: generate_inputs/duration
      out:
      - wf_outputs
    
  outputs:
  - id: wf_outputs_2
    outputSource:
    - pipeline/wf_outputs
    type:
      Directory
  s:name: second_pipeline
  s:description: Workflow that calls another workflow inside a node
  s:keywords:
    - workflows
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:dateCreated: "2023-07-28"
  s:softwareVersion: 1.0.1

- class: CommandLineTool
  baseCommand: step0
  id: step0
  inputs: []
  stdout: _
  outputs:
    lat:
      type: float
      doc: The latitude of the study area
      s:name: Input lat float
      s:description: The latitude of the study area
      s:keywords:
        - lat
        - float
    lon:
      type: float
      doc: The longitude of the study area
      s:name: Input lon float
      s:description: The longitude of the study area
      s:keywords:
        - lon
        - float
    time:
      type: string
      doc: The start time of the simulation
      s:name: Input time string
      s:description: The start time of the simulation. Type dd-mm-yyyy
      s:keywords:
        - time
        - string
    oiltype:
      type: string
      doc: The type of the oil to run the simulation
      s:name: Input oiltype string
      s:description: The type of the oil to run the simulation
      s:keywords:
        - oiltype
        - string

    duration:
      type: int
      doc: The simulation duration
      s:name: Input duration int
      s:description: The simulation duration
      s:keywords:
        - duration
        - int
  requirements:
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/step0:1.0.1
  s:name: step0
  s:description: Tool that simulates operations to give input to the workflow
  s:keywords:
    - workflows
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:dateCreated: "2023-07-26"
  s:softwareVersion: 1.0.1


- class: Workflow
  id: main_pipeline
  doc: Simulation steps pipeline
  inputs:
    lat:
      type: float
      doc: The latitude of the study area
      s:name: Input lat float
      s:description: The latitude of the study area
      s:keywords:
        - lat
        - float
    lon:
      type: float
      doc: The longitude of the study area
      s:name: Input lon float
      s:description: The longitude of the study area
      s:keywords:
        - lon
        - float
    time:
      type: string
      doc: The start time of the simulation
      s:name: Input time string
      s:description: The start time of the simulation. Type dd-mm-yyyy
      s:keywords:
        - time
        - string
      # %d-%m-%Y %H:%M:%S
      # https://strftime.org/
    oiltype:
      type: string
      doc: The type of the oil to run the simulation
      s:name: Input oiltype string
      s:description: The type of the oil to run the simulation
      s:keywords:
        - oiltype
        - string

    duration:
      type: int
      doc: The simulation duration
      s:name: Input duration int
      s:description: The simulation duration
      s:keywords:
        - duration
        - int

  steps:
    generate_metadata:
      run: '#step1'
      in:
        lat: lat
        lon: lon
      out:
      - metadata
    model:
      run: '#step2'
      in:
        time: time
        oiltype: oiltype
        duration: duration
      out:
      - result
    2stac:
      run: '#2stac'
      in:
        result: model/result
        metadata: generate_metadata/metadata
      out:
      - results
      
  outputs:
  - id: wf_outputs
    outputSource:
    - 2stac/results
    type:
      Directory
  s:name: main_pipeline
  s:description: Main workflow that distributes inputs to the steps
  s:keywords:
    - workflows
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:dateCreated: "2023-07-26"
  s:softwareVersion: 1.0.3

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
      s:name: Input lat float
      s:description: The latitude of the study area
      s:keywords:
        - lat
        - float
    lon:
      type: float
      doc: The longitude of the study area
      s:name: Input lon float
      s:description: The longitude of the study area
      s:keywords:
        - lon
        - float
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
  s:name: step1
  s:description: Tool that creates a metadata file to 2stac
  s:keywords:
    - workflows
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:dateCreated: "2023-07-25"
  s:softwareVersion: 1.0.1


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
      s:name: Input time string
      s:description: The start time of the simulation. Type dd-mm-yyyy
      s:keywords:
        - time
        - string
    oiltype:
      type: string
      doc: The type of the oil to run the simulation
      s:name: Input oiltype string
      s:description: The type of the oil to run the simulation
      s:keywords:
        - oiltype
        - string
    duration:
      type: int
      doc: The simulation duration
      s:name: Input duration int
      s:description: The simulation duration
      s:keywords:
        - duration
        - int
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
  s:name: step2
  s:description: Tool that do something as a result of the intire workflow
  s:keywords:
    - workflows
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
  s:author:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:dateCreated: "2023-07-21"
  s:softwareVersion: 1.0.1

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
  s:name: 2Stac
  s:description: Transform the result into a STAC
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
  s:dateCreated: "2023-04-21"
  s:softwareVersion: 1.0.0

s:softwareVersion: 1.0.1
s:name: Workflow Steps example
s:description: Simulation workflows steps

