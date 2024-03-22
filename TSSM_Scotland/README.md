# CWL

# TSSM Scotland CWL

## How to use it:

To be able to run this CWL flow you need to have available on your machine:

1. [Python](https://www.python.org/)
2. [Docker](https://www.docker.com/)
3. [CWLTool](https://github.com/common-workflow-language/cwltool)

To run this CWL flow you have to execute the following command:

```
cwltool --no-read-only workflow.cwl#tssm_scotland job.yml
```

Where:

1. workflow.cwl is the path to the cwl workflow file
2. tssm_scotland is the name of the workflow class to be executed
3. job.yml is the path to the file with the yml that has the input variables of the workflow

The job.yml file has, for this specific workflow, the following variables:

1. start - Start date time (YYYY-MM-DDTHH:MM) of simulation e.g. 2002-10-20T00:00
2. duration - Duration length of simulation, number and units e.g. "30d", "120h", "14c" (here "c" is semi-diurnal cycle)
3. ramp_duration - Duration length of ramp-up, number and units\ne.g. "2d", "24", "4c" (default unit "h")
4. num_proc - Number of processes used in parallel simulation, e.g. 1
