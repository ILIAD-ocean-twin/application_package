# SWAN Heraklion CWL

## How to use it:

To be able to run this CWL flow you need to have available on your machine:

1. [Python](https://www.python.org/)
2. [Docker](https://www.docker.com/)
3. [CWLTool](https://github.com/common-workflow-language/cwltool)

To run this CWL flow you have to execute the following command:

```
cwltool workflow.cwl#run_swan_creta job.yml
```

Where:

1. workflow.cwl is the path to the cwl workflow file
2. run_swan_creta is the name of the workflow class to be executed
3. job.yml is the path to the file with the yml that has the input variables of the workflow

The job.yml file has, for this specific workflow, the following variables:

1. copernicus_username - Copernicus username
2. copernicus_password - Copernicus password
3. hindcast - (days) for example: 1
4. forecast - (days) for example: 3
