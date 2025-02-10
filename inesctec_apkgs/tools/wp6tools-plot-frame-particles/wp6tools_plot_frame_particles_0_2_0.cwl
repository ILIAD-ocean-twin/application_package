cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: CommandLineTool

  id: plot-frame-particles

  baseCommand: python
  arguments:
  - /opt/main.py
  - plot-frame-particles
  - --input-url
  - valueFrom: $( inputs['particles'])
  - --input-format
  - stac
  # - valueFrom: $( inputs['input-format'] )
  - --process-project
  - valueFrom: $( inputs['process-project'] )
  - --process-project-resolution
  - valueFrom: $( inputs['process-project-resolution'] )
  - --process-collapse
  - valueFrom: $( inputs['process-collapse'] )

  - --output-url
  - output/plot

  inputs:
    particles:
      type: Directory
    # input-format:
    #   type: string
    process-project:
      type: string
    process-project-resolution:
      type: string
    process-collapse:
      type: string


  outputs:
    result:
      type: Directory
      outputBinding:
        glob: output/plot

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

  s:name: plot-frame-particles
  s:description: plot frame particles frames from wp6-tools
  s:keywords:
    - wp6-tools
    - plot
    - particles
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
  s:sourceOrganization:
    class: s:Organization
    s:name: INESCTEC
    s:url: https://inesctec.pt
    s:address:
        class: s:PostalAddress
        s:addressCountry: PT
  s:author:
    class: s:Person
    s:name: Alexandre Valle
    s:email: alexandre.valle@inesctec.pt
  s:contributor:
    class: s:Person
    s:name: Miguel Correia
    s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/wp6tools-plot-frame-particles/wp6tools_plot_frame_particles_0_2_0.cwl
  s:dateCreated: "2025-02-07T18:04:41Z"