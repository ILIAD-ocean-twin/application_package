
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:

- class: Workflow
  id: pyopia_demo_pipeline
  doc: This pipeline runs the PyOPIA demo analysis for Norway.
  inputs: []
  steps:
    step_pyopia:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/pyopia-demo-sintef/pyopia_demo_sintef_0_1_0.cwl#pyopia_demo_sintef'
      in: []
      out:
      - particles_figure
      - vd_copepods
      - vd_copepods_per_L
      - netcdf_statistics
      - metadata
    step_2stac2:
      run: 'https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_pyopia_pipeline_0_3_1.cwl#2stac2_pyopia_pipeline'
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
    type:
      Directory

  requirements:
    InlineJavascriptRequirement: {}

  s:name: pyopia_demo_pipeline
  s:description: |
    This pipeline runs a PyOPIA demo analysis, generating figures and statistics from copepod image data and packaging the results into a STAC output.
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
  s:dateCreated: "2025-11-24T23:38:39Z"
