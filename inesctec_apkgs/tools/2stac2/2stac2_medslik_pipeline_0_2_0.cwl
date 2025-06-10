cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$graph:
- class: CommandLineTool

  id: 2stac2_medslik_pipeline

  baseCommand: python
  arguments:
  - /opt/2stac2.py
  - --file
  - valueFrom: |
      ${
        function findNetcdfFile(dir) {
          if (dir.class === 'File' && dir.basename.endsWith('.nc')) return dir.path;
          if (dir.class === 'Directory' && dir.listing) {
            for (const f of dir.listing) {
              const found = findNetcdfFile(f);
              if (found) return found;
            }
          }
          return null;
        }
        const ncPath = findNetcdfFile(inputs.medslik_result);
        if (!ncPath) throw new Error('No NetCDF file found in directory');
        return ncPath;
      }
  - --metadata
  - valueFrom: $(runtime.outdir + '/multiple_metadata.json')

  inputs:
    medslik_result:
      doc: Medslik simulation result
      type: Directory
      loadListing: deep_listing
    metadata:
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
      dockerPull: iliad-repository.inesctec.pt/2stac2:0.2.0
    InplaceUpdateRequirement:
      inplaceUpdate: true
    InitialWorkDirRequirement:
      listing: |
        ${
          const content = JSON.parse(inputs.metadata.contents);
          const metadata = [{...JSON.parse(inputs.metadata.contents), filename: 'spill_properties.nc'}];
          return [{"class": "File", "basename": "multiple_metadata.json", "contents": JSON.stringify(metadata) }];
        }

  s:name: 2stac2_medslik_pipeline
  s:softwareVersion: 0.2.0
  s:description: 2stac2 tool to transform Medslik result into a STAC
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2stac2/2stac2_medslik_pipeline_0_2_0.cwl
  s:dateCreated: "2025-06-08T23:17:18Z"
