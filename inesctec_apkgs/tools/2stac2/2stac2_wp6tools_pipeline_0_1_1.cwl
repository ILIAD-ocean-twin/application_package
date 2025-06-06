cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:

- class: CommandLineTool

  id: 2stac2_wp6tools_pipeline
  baseCommand: python
  arguments:
  - /opt/2stac2.py
  - valueFrom: $(
      function () {
        if (inputs["unity_choreography"]) {
            return ["--file", inputs["unity_choreography"]];
        } else {
            return [];
        }
      }())
  - valueFrom: $(
      function () {
        if (inputs["cesium_choreography"]) {
            return ["--file", inputs["cesium_choreography"]];
        } else {
            return [];
        }
      }())
  - valueFrom: $(
      function () {
        if (inputs["simulation"]) {
            return ["--file", inputs["simulation"]];
        } else {
            return [];
        }
      }())
  - valueFrom: $(
      function () {
        if (inputs["animation"]) {
            return ["--file", inputs["animation"]];
        } else {
            return [];
        }
      }())
  - valueFrom: $(
      function () {
        if (inputs["bathymetry"]) {
            return ["--file", inputs["bathymetry"]];
        } else {
            return [];
        }
      }())
  - --metadata
  - valueFrom: $(runtime.outdir + '/multiple_metadata.json')

  inputs:
    unity_choreography:
      format: edam:format_3464 # JSON
      doc: unity choreography json file
      type: File?
    cesium_choreography:
      format: edam:format_3464 # JSON
      doc: cesium choreography json file
      type: File?
    simulation:
      format: edam:format_3650 # NetCDF
      doc: NetCDF simulation file
      type: File?
    animation:
      format: edam:format_3467 # GIF
      doc: Animation GIF file
      type: File?
    bathymetry:
      format: edam:format_3650 # NetCDF
      doc: Bathymetry NetCDF file
      type: File?
    metadata:
      format: edam:format_3464 # JSON
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
        PATH: /opt/conda/envs/application/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2stac2:0.1.1
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
  s:softwareVersion: 0.1.1
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_wp6tools_pipeline_0_1_1.cwl
  s:dateCreated: "2025-05-12T11:39:40Z"
