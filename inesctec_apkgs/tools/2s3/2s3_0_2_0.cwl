cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

$graph:
- class: CommandLineTool

  id: 2s3

  baseCommand: python
  arguments:
  - /opt/2s3.py
  - --endpoint
  - valueFrom: $( inputs.endpoint )
  - --access_key
  - valueFrom: $( inputs.access_key )
  - --secret_key
  - valueFrom: $( inputs.secret_key )
  - --bucket
  - valueFrom: $( inputs.bucket )
  - --endpoint
  - valueFrom: $( inputs.endpoint )
  - valueFrom: $(
      function () {
        if (inputs.region) {
          return ["--region", inputs.region];
        } else {
          return [];
        }
      }())
  - valueFrom: $(
      function () {
        if (inputs.base_path) {
          return ["--base_path", `${inputs.base_path}_${new Date().toISOString().replace(/:/g, '').replace(/\-/g, '').split('.')[0]}`];
        } else {
          return [];
        }
      }())
  - valueFrom: $(
      function () {
        if (inputs.session_token) {
          return ["--session_token", inputs.session_token];
        } else {
          return [];
        }
      }())
  - valueFrom: $(
      function () {
        if(inputs.files) {
          var files_array = [];

          Object.keys(inputs.files).forEach(function (element) {
              files_array.push('--file');
              files_array.push(inputs.files[element]);
          });

          return files_array;
        } else {
          return [];
        }
      }())
  - valueFrom: $(
      function () {
        if(inputs.directories) {
          var directories_array = [];

          Object.keys(inputs.directories).forEach(function (element) {
              directories_array.push('--directory');
              directories_array.push(inputs.directories[element]);
          });

          return directories_array;
         } else {
          return [];
        }
      }())
  - valueFrom: $(
      function () {
        if(inputs.file) {
          return ['--file', inputs.file];
        } else {
          return [];
        }
      }())
  - valueFrom: $(
      function () {
        if(inputs.directory) {
            return ['--directory', inputs.directory];
         } else {
          return [];
        }
      }())

  inputs:
    endpoint:
      type: string?
      doc: S3 storage endpoint
    region:
      type: string?
      doc: S3 storage region
    access_key:
      type: string?
      doc: S3 storage access_key
    secret_key:
      type: string?
      doc: S3 storage secret_key
    session_token:
      type: string?
      doc: S3 storage region
    bucket:
      type: string?
      doc: S3 storage bucket
    base_path:
      type: string?
      doc: S3 storage final directory name
    files:
      type: File[]?
      doc: Multiple files to upload
    directories:
      type: Directory[]?
      doc: Multiple directories to upload
    directory:
      type: Directory?
      doc: Single directory to upload
    file:
      type: File?
      doc: Single file to upload

  outputs:
    base_path:
      type: string

  requirements:
    NetworkAccess:
      networkAccess: true
    ResourceRequirement: {}
    InlineJavascriptRequirement: {}
    DockerRequirement:
      dockerPull: iliad-repository.inesctec.pt/2s3:0.2.0
  hints:
    "cwltool:Secrets":
      secrets: [access_key,secret_key,session_token]


  s:name: 2s3
  s:description: Uploads files and/or folders to a S3 bucket storage.
  s:keywords:
    - s3
    - storage
  s:programmingLanguage: python
  s:softwareVersion: 0.2.0
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
  s:codeRepository: https://pipe-drive.inesctec.pt/application-packages/tools/2s3/2s3_0_2_0.cwl
  s:dateCreated: "2025-02-07T16:52:37Z"