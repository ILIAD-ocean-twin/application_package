cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:
- class: CommandLineTool

  id: netcdf_metadata_medslik

  baseCommand: python
  arguments:
    - /opt/parse.py
    - --netcdf_file
    - valueFrom: |
        ${
          // Find the first .nc file in the input directory (recursively if needed)
          function findNetcdfFile(dir) {
            console.log("Searching for NetCDF file in:", dir);
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
    - --extra_props
    - valueFrom: $(runtime.outdir + '/extra_props.json')

  inputs:
    medslik_result:
      type: Directory
      loadListing: deep_listing
  outputs:
    metadata:
      outputBinding:
        glob: ./metadata.json
      type: File

  requirements:
    MultipleInputFeatureRequirement: {}
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/netcdf-metadata:0.1.0
    InitialWorkDirRequirement:
      listing: |
        ${
          return [{
            "class": "File",
            "basename": "extra_props.json",
            "contents": JSON.stringify({
              "description": "Medslik simulation NetCDF file",
              "keywords": ["metadata", "medslik", "netcdf"],
            })}];
        }

  s:name: netcdf_metadata
  s:softwareVersion: 0.1.0
  s:description: Extract metadata from NetCDF file
  s:keywords:
    - netcdf
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/netcdf-metadata/netcdf_metadata_medslik_pipeline_0_1_0.cwl
  s:dateCreated: "2025-06-10T01:07:05Z"
