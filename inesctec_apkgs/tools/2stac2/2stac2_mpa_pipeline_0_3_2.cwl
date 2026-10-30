cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: 2stac2_mpa_pipeline

  baseCommand: python
  arguments:
  - /opt/2stac2.py

  inputs:
    simulation:
      format: edam:format_3650 # NetCDF
      doc: simulation NetCDF file
      type: File
      inputBinding:
        prefix: --file
    connectivity:
      format: edam:format_3620 # xlsx
      doc: connectivity file
      type: File?
      inputBinding:
        prefix: --file
    connectivity_with_locality_id:
      format: edam:format_3620 # xlsx
      doc: connectivity with locality id
      type: File?
      inputBinding:
        prefix: --file
    metadata:
      format: edam:format_3464 # JSON
      doc: metadata file description
      type: File
      loadContents: true
      inputBinding:
        prefix: --metadata
        valueFrom: $(runtime.outdir + '/multiple_metadata.json')

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
      dockerPull: iliad-repository.inesctec.pt/2stac2:0.3.2
    InplaceUpdateRequirement:
      inplaceUpdate: true
    InitialWorkDirRequirement:
      listing: |
        ${
          const content = JSON.parse(inputs.metadata.contents);
          const metadata = [];
          metadata.push({...content, filename:inputs["simulation"].basename});
          if(inputs["connectivity"] && inputs["connectivity"].basename)
            metadata.push({...content, filename:inputs["connectivity"].basename , media_type:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"});
          if(inputs["connectivity_with_locality_id"] && inputs["connectivity_with_locality_id"].basename)
            metadata.push({...content, filename:inputs["connectivity_with_locality_id"].basename , media_type:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"});
          return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
        }

  s:name: 2stac2_mpa_pipeline
  s:softwareVersion: 0.3.2
  s:description: 2stac2 tool to transform MPA simulation files into a STAC
  s:keywords:
    - stac
    - metadata
    - mpa
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
  s:dateCreated: "2026-10-30T16:34:27Z"
