# Questions about Application Packages

## 0. Install docker & cwltool

``` bash
sudo apt-get update

curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh ./get-docker.sh

sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "/home/$USER/.docker" -R

sudo chmod 666 /var/run/docker.sock

sudo apt-get install cwltool
```

## 1. CWL and JSON-LD

Print CWL document after preprocessing:

``` bash
cwltool --print-pre my_tool-or-workflow.cwl
```

## 2. Application Package network access

To allow the application have internet access to do requests, the follow requirement is needed:

``` yaml
requirements:
  NetworkAccess:
    networkAccess: true
```

## 3. Application Package without inputs

This case is allowed. However is needed to define the property:

- inputs: []

or inside a step:

- in: []

## 4. Add metadata information to the Application Package

For a better description of the application, is important to add the namespace schema.org:

```yaml
$namespaces:
  s: https://schema.org/
```

To add metadata regarding the entire CommandLineTool or Workflow:

```yaml
s:name: App name
s:description: App description
s:softwareVersion: 0.0.0
s:keywords:
  - appKeyword1
  - appKeyword2
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
    s:name: INESC TEC
    s:url: https://inesctec.pt
    s:address:
      class: s:PostalAddress
      s:addressCountry: PT
  - class: s:Organization
    s:name: Org Name
    s:url: https://org-example.com
    s:address:
      class: s:PostalAddress
      s:addressCountry: ES
s:author:
  - class: s:Person
    s:name: Person1
    s:email: person1@org-example.com
  - class: s:Person
    s:name: Person2
    s:email: someone@gmail.com
s:contributor:
  - class: s:Person
    s:name: Person3
    s:email: someone@inesctec.pt
s:codeRepository: https://somedrive.com/cwl/application.cwl
s:dateCreated: "2023-06-20"
```

## 5. File format metadata (inputs and outputs)

For a better description the application `inputs` and `outputs` files, is important to add the namespace [EDAM](https://www.ebi.ac.uk/ols4/ontologies/edam):

```yaml
$namespaces:
  edam: http://edamontology.org/
```

With this namespace, you add the file format information:

```yaml
inputs:
  file:
    format: edam:format_3650 # NetCDF
    type: File
    doc: The netcdf file containing the simulation results
outputs:
  animation:
    format: edam:format_3467 # GIF
    type: File
    outputBinding:
    glob: "result/animation.gif"
```

## 6. Reuse workflows and keep metadata

To allow a workflow call another workflow, the follow requirement is needed:

``` yaml
requirements:
  - class: SubworkflowFeatureRequirement
```

To persist metadata from a workflow, that will be called by another, the workflow and its respective CommandLineTool classes need to be a single node. You can see below, an example:

### Main workflow

``` txt
- Workflow (main_pipeline)
- CommandLineTool (step1)
- CommandLineTool (step2)
- CommandLineTool (2stac)
```

The sequence will be:

``` txt
calls step1 -> calls step2 -> calls 2stac
```

### Second workflow that calls the main

``` txt
- Workflow (second_pipeline)
- CommandLineTool (step0)
- - Workflow (main_pipeline)
  - CommandLineTool (step1)
  - CommandLineTool (step2)
  - CommandLineTool (2stac)
```

The sequence will be:

``` txt
calls step0 -> calls main_pipeline (calls step1 -> calls step2 -> calls 2stac)
```

## 7. Output variables

### 1- write to a file

To get on output CWL variables (instead of files), like this:

``` yaml
outputs:
  var1: float
  var2: string
  var3: int
```

Is needed two things:

1. On your application, write a JSON object to the `cwl.output.json` file:

``` python
outputs = {
  "var1": 10.2,
  "var2": "some_string",
  "var3": 1
}

with open("cwl.output.json", "w") as f:
  json.dump(outputs, f)
```

2. Add on CommandLineTool CWL the parameter

``` yml
stdout: _
```

### 2- use standard output

You can write to stdout

```python
print(json.dumps(outputs))
```

and on CWL you can parse them like the following example:

```yaml
stdout: out_file
  outputs:
    my_json_var:
      type: float
      outputBinding:
        glob: out_file
        loadContents: true
        outputEval: $(JSON.parse(self[0]["contents"])["my_json_var"])
```

## 8. Add environment variables

To pass to your application a environment variable, you can add it on CWL, like the following example:

```yml
requirements:
  EnvVarRequirement:
    envDef:
      MY_ENV_VAR: some value
```

## 9. Optional arguments

To set a optional input parameters. **Be attention to indentation.**

```yaml
 arguments:
  - valueFrom: $(
      function () {
        if (inputs.my_input) {
          return ["--my_input", inputs.my_input];
        } else {
          return [];
        }
      }())
```

Be aware to make on application code, the input optional and not required.

## 10. Secret inputs

To pass sensible arguments through CWL, like passwords, it can be defined like the following example:

```yaml

  inputs:
    password:
      type: string
    username:
      type: string

  hints:
    "cwltool:Secrets":
      secrets: [password]

  $namespaces:
    cwltool: http://commonwl.org/cwltool#
```

## 11. Optional workflow steps

To make a step optional, you can use the `when` parameter, like the following example:

```yaml
    step1:
      run: '#myid'
      when: $(inputs.input1 != null && inputs.input1 != "")
      in:
        input1: input1
        input2: input2
        ...
      out:
        ...
```

## 12. docker run read-only (Read-only file system)

If you have issues with read-only file system, you have a full example that explains how to solve it [here](./HelloWorldReadOnlyFs).

However, to run a docker container in read-only mode, you should use the following command:

```bash
docker run --read-only --tmpfs /tmp --tmpfs /wefbdjk -e HOME='/wefbdjk' -w /wefbdjk my-image my-command
```

This command will run the container in read-only mode, and the `/tmp` and `/wefbdjk` directories will be writable. Additionally, the working directory will be `/wefbdjk`. The cwltool runs the container in a similar environment.

## 13. debug with cwltool

(src: https://www.biostars.org/p/308029/#google_vignette)

1. Testing with cwltool and the --js-console and --debug options. Also using --tmp-outdir-prefix, -leave-tmpdir, and --leave-outputs to inspect results from intermediate steps

2. Having small sample inputs that can be used to run the workflows quickly when making changes

3. Testing the individual tools before the whole workflows

4. cwltool --validate to only validate the workflow and not run it

5. cwltool --print-dot and cwltool --print-rdf to show graph of the workflow