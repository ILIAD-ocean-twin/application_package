cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:
- class: CommandLineTool

  id: medslik

  baseCommand:
    - /opt/miniconda3/envs/application/bin/python
    - /opt/MEDSLIK/RUN_medslik.py

  arguments:
  - --use_case_directory
  - valueFrom: "$(inputs.use_case_directory)"
  - --cont_slick
  - $(inputs.cont_slick)
  - --sat
  - $(inputs.sat)
  - --use_high_res
  - $(inputs.use_high_res)
  - --min_lon
  - $(inputs.min_lon)
  - --max_lon
  - $(inputs.max_lon)
  - --min_lat
  - $(inputs.min_lat)
  - --max_lat
  - $(inputs.max_lat)
  - --lat_point
  - $(inputs.lat_point)
  - --lon_point
  - $(inputs.lon_point)
  - --date_spill
  - $(inputs.date_spill)
  - --spill_dur
  - $(inputs.spill_dur)
  - --spill_res
  - $(inputs.spill_res)
  - --spill_tons
  - $(inputs.spill_tons)
  - --username
  - $(inputs.username)
  - --password
  - $(inputs.password)
  - --ftp_server
  - $(inputs.ftp_server)
  - --ftp_user
  - $(inputs.ftp_user)
  - --ftp_password
  - $(inputs.ftp_password)
  - --remote_dir
  - $(inputs.remote_dir)
  - --cds_token
  - $(inputs.cds_token)

  inputs:
    use_case_directory:
      doc: Path to directory as a string where to find input files and where to store outputs
      type: string
    cont_slick:
      type: string
      default: "NO"
    sat:
      type: string
      default: "NO"
    use_high_res:
      type: string
      default: "NO"
    min_lon:
      type: float?
      default: 24.069118741783797
    max_lon:
      type: float?
      default: 24.990341065648366
    min_lat:
      type: float?
      default: 35.09663196120557
    max_lat:
      type: float?
      default: 35.990635331961315
    lat_point:
      type: float?
      default: 35.496
    lon_point:
      type: float?
      default: -15.7433
    date_spill:
      type: string?
      default: "2024-11-07T06:22:00Z"
    spill_dur:
      type: string
    spill_res:
      type: string
    spill_tons:
      type: float
      default: 1.4
    username:
      type: string
    password:
      type: string
    ftp_server:
      type: string
    ftp_user:
      type: string
    ftp_password:
      type: string
    remote_dir:
      type: string
    cds_token:
      type: string?

  outputs:
    results:
      outputBinding:
        glob: "$(runtime.outdir)/OUT/"
      type: Directory
      doc: All results

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: antonisparasyris/iliad:medslik-1.0
    EnvVarRequirement:
      envDef:
        PATH: /opt/miniconda3/envs/application/bin:/opt/conda/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  hints:
    "cwltool:Secrets":
      secrets: [username,password]

  s:name: medslik
  s:softwareVersion: 0.1.0
  s:description: medslik
  s:keywords:
    - medslik
    - oil spill
  s:programmingLanguage: python
  s:sourceOrganization:
    - class: s:Organization
      s:name: FORTH
      s:url: https://forth.gr
  s:author:
    - class: s:Person
      s:email: antonisparasyris@iacm.forth.gr
      s:name: Antonios Parasyris
  s:mantainer:
    - class: s:Person
      s:email: vasmeth@iacm.forth.gr
      s:name: Vassiliki Metheniti
  s:contributor:
    - class: s:Person
      s:name: Miguel Correia
      s:email: miguel.r.correia@inesctec.pt
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/medslik-glo-forth/medslik_0_1_0.cwl
  s:dateCreated: "2024-11-12T16:00:00Z"
