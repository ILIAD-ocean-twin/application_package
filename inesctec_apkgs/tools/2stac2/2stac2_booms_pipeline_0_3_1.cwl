cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:

- class: CommandLineTool

  id: 2stac2_booms_pipeline
  baseCommand: python
  arguments:
  - /opt/2stac2.py
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
        if (inputs["statistics"]) {
            return ["--file", inputs["statistics"]];
        } else {
            return [];
        }
      }())

  - valueFrom: $(
      function () {
        if (inputs["contours"]) {
            return ["--file", inputs["contours"]];
        } else {
            return [];
        }
      }())
  - --metadata
  - valueFrom: $(runtime.outdir + '/multiple_metadata.json')

  inputs:
    simulation:
      format: edam:format_3650 # NetCDF
      doc: NetCDF simulation file
      type: File?
    contours:
      format: edam:format_3464 # JSON
      doc: Contours file
      type: File?
    statistics:
      format: edam:format_3464 # JSON
      doc: Statistics file
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
      dockerPull: iliad-repository.inesctec.pt/2stac2:0.3.1
    InplaceUpdateRequirement:
      inplaceUpdate: true
    InitialWorkDirRequirement:
      listing: |
        ${
          const content = JSON.parse(inputs.metadata.contents);
          const metadata = [];
          if(inputs.simulation) metadata.push({...content, filename: inputs.simulation.basename});
          if(inputs.statistics) metadata.push({...content, filename: inputs.statistics.basename});
          if(inputs.contours) metadata.push({...content, filename: inputs.contours.basename});
          return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
        }

  s:name: 2stac2_booms_pipeline
  s:softwareVersion: 0.3.1
  s:description: 2stac2 for booms tools pipeline
  s:keywords:
    - stac
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
  s:dateCreated: "2026-01-27T16:00:40Z"
