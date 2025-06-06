cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: 2stac2_openoil_pipeline

  baseCommand: python
  arguments:
  - /opt/2stac2.py
  - --file
  - valueFrom: $(inputs.simulation)
  - valueFrom: $(
      function () {
        if (inputs.animation) {
          return ["--file", inputs.animation];
        } else {
          return [];
        }
      }())
  - --metadata
  - valueFrom: $(runtime.outdir + '/multiple_metadata.json')

  inputs:
    simulation:
      format: edam:format_3650 # NetCDF
      doc: simulation NetCDF file
      type: File
    animation:
      format: edam:format_3467 # GIF
      doc: animation Gif file
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
      dockerPull: iliad-repository.inesctec.pt/2stac2:0.1.0
    InplaceUpdateRequirement:
      inplaceUpdate: true
    InitialWorkDirRequirement:
      listing: |
        ${
          const content = JSON.parse(inputs.metadata.contents);
          const metadata = [];
          metadata.push({...content, filename:inputs["simulation"].basename});
          if(inputs["animation"] != null) {
            metadata.push({...content, filename:inputs["animation"].basename , media_type:"image/gif" });
          }
          return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
        }

  s:name: 2stac2_openoil_pipeline
  s:softwareVersion: 0.1.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_openoil_pipeline_0_1_0.cwl
  s:dateCreated: "2025-03-15T07:53:14Z"
