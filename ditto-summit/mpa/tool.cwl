cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$graph:

- class: CommandLineTool

  id: mpa_ditto_summit

  baseCommand: python
  arguments:
   - /simulation/mpa.py
  inputs:
    norkyst_agg:
      type: string?
      doc: norkyst_agg
      inputBinding:
        prefix: --norkyst_agg
    starttime:
      type: string?
      doc: The start time of the simulation
      inputBinding:
        prefix: --starttime
    duration:
      type: int?
      doc: The duration of the simulation, in hours
      inputBinding:
        prefix: --duration

  outputs:
    simulation:
      format: edam:format_3650 # NetCDF
      type: File
      outputBinding:
        glob: "modeloutput/result.nc"

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/mpa-ditto-summit:0.1.0

  s:name: mpa_ditto_summit
  s:description: Runs (i) OpenDrift, and (ii) the connectivity analysis for aquaculture sites in Norway using the NorKyst model data, for Marine Protected Areas (MPAs).
  s:keywords:
    - opendrift
    - mpa
    - aquaculture
    - connectivity
    - norway
    - norkyst
  s:programmingLanguage: python
  s:softwareVersion: 0.1.0
  s:producer:
    class: s:Organization
    s:name: SINTEF OCEAN
    s:url: https://sintef.no/en/ocean/
    s:address:
        class: s:PostalAddress
        s:addressCountry: "NO"
  s:sourceOrganization:
    - class: s:Organization
      s:name: INESCTEC
      s:url: https://inesctec.pt
      s:address:
          class: s:PostalAddress
          s:addressCountry: PT
    - class: s:Organization
      s:name: SINTEF OCEAN
      s:url: https://sintef.no/en/ocean/
      s:address:
          class: s:PostalAddress
          s:addressCountry: "NO"
  s:author:
    - class: s:Person
      s:name: Arne Berre
      s:email: arne.j.berre@sintef.no
    - class: s:Person
      s:name: Volker Hoffmann
      s:email: volker.hoffmann@sintef.no
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://github.com/ILIAD-ocean-twin/application_package/tree/main/ditto-summut/mpa
  s:dateCreated: "2026-10-30T18:00:00Z"
