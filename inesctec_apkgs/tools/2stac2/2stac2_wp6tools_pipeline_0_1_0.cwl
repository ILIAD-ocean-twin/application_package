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
  - --file
  - valueFrom: $(inputs.unity_choreography)
  - --file
  - valueFrom: $(inputs.cesium_choreography)
  - --metadata
  - valueFrom: $(runtime.outdir + '/multiple_metadata.json')

  inputs:
    unity_choreography:
      format: edam:format_3464 # JSON
      doc: unity choreography json file
      type: File
    cesium_choreography:
      format: edam:format_3464 # JSON
      doc: cesium choreography json file
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
          metadata.push({...content, filename:"platform_choreography_cesium.json"});
          metadata.push({...content, filename:"platform_choreography_unity.json" });
          return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
        }

  s:name: 2stac2_wp6tools_pipeline
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_wp6tools_pipeline_0_1_0.cwl
  s:dateCreated: "2025-03-15T07:53:14Z"
