cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:
- class: CommandLineTool

  id: get_file

  baseCommand: python
  arguments:
  - /opt/get-file.py
  - --filename
  - valueFrom: $( inputs.filename )
  - valueFrom: |
      ${ return inputs.file ? ["--file", inputs.file] : [] }

  - valueFrom: |
      ${ return inputs.s3_endpoint ? ["--s3_endpoint", inputs.s3_endpoint] : [] }
  - valueFrom: |
      ${ return inputs.s3_region ? ["--s3_region", inputs.s3_region] : [] }
  - valueFrom: |
      ${ return inputs.s3_access_key ? ["--s3_access_key", inputs.s3_access_key] : [] }
  - valueFrom: |
      ${ return inputs.s3_secret_key ? ["--s3_secret_key", inputs.s3_secret_key] : [] }
  - valueFrom: |
      ${ return inputs.s3_session_token ? ["--s3_session_token", inputs.s3_session_token] : [] }
  - valueFrom: |
      ${ return inputs.s3_bucket ? ["--s3_bucket", inputs.s3_bucket] : [] }
  - valueFrom: |
      ${ return inputs.s3_path ? ["--s3_path", inputs.s3_path] : [] }


  inputs:
    filename:
      type: string
      doc: Name of the output file

    file:
      type:
        - string?
        - File?
      doc: URL to download the file or local path

    s3_endpoint:
      type: string?
      doc: S3 storage endpoint
    s3_region:
      type: string?
      doc: S3 storage region
    s3_access_key:
      type: string?
      doc: S3 storage access_key
    s3_secret_key:
      type: string?
      doc: S3 storage secret_key
    session_token:
      type: string?
      doc: S3 storage region
    s3_bucket:
      type: string?
      doc: S3 storage bucket
    s3_path:
      type: string?
      doc: S3 path to file

  outputs:
    file_output:
      # format: edam: # UNDEFINED
      type: File
      outputBinding:
        glob: "$(inputs.filename)"

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/get-file:0.1.0


  s:name: get_file
  s:description: Tool to download a file from a URL or S3 storage
  s:keywords:
    - s3
    - storage
  s:programmingLanguage: python
  s:softwareVersion: 0.1.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/get-file/get_file_0_1_0.cwl
  s:dateCreated: "2025-05-30T16:10:19Z"