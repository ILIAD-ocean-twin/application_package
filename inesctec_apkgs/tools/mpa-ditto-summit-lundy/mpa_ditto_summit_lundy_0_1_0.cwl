cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/
  cwltool: http://commonwl.org/cwltool#

$graph:

- class: CommandLineTool

  id: mpa_ditto_summit_lundy

  baseCommand: python
  arguments:
  - /simulation/mpa.py
  - --startdate
  - valueFrom: $( inputs.startdate )
  - --duration
  - valueFrom: $( inputs.duration )
  - --username
  - valueFrom: $( inputs.username )
  - --password
  - valueFrom: $( inputs.password )

  inputs:
    startdate:
      type: string
      doc: The start time of the simulation
    duration:
      type: int
      doc: The simulation duration
    username:
      type: string
      doc: The CMEMS username
    password:
      type: string
      doc: The CMEMS password
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
      dockerPull: iliad-repository.inesctec.pt/mpa-ditto-summit-lundy:0.1.0

  hints:
    "cwltool:Secrets":
      secrets: [password]

  s:name: mpa_ditto_summit_lundy
  s:description: Runs (i) OpenDrift for Marine Protected Areas (MPAs).
  s:keywords:
    - opendrift
    - mpa
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
  s:dateCreated: "2026-10-31T02:26:57Z"
