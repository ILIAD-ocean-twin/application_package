# SWAN Heraklion CWL
This is a 500m and 50m spatial resolution implementation of SWAN wave model, that requires inputs from already downscaled in-house WRF (3km) resolution.
It also requires the CMEMS username and password of the user, inputed as a yaml file with the inputs, along with the number of hindcast and forecast days (integer)
## How to use it:

To be able to run this CWL flow you need to have available on your machine:

1. [Python](https://www.python.org/)
2. [Docker](https://www.docker.com/)
3. [CWLTool](https://github.com/common-workflow-language/cwltool)

To start the docker service you need:
sudo service docker start

To run this CWL flow you have to execute the following command:

```
cwltool workflow.cwl#run_swan_creta job.yml
```

Where:

1. workflow.cwl is the path to the cwl workflow file
2. run_swan_creta is the name of the workflow class to be executed
3. job.yml is the path to the file with the yml that has the input variables of the workflow

The job.yml file has, for this specific workflow, the following variables:

1. cmems_username - Cmems username
2. cmems_password - Cmems password
3. wrf_ftpserver - WRF FTP server
4. wrf_username - WRF FTP username
5. wrf_password - WRF FTP password
6. hindcast - (days) for example: 1
7. forecast - (days) for example: 3

Contact CMRL, FORTH on the following emails: antonisparasyris@iacm.forth.gr and vasmeth@iacm.forth.gr for further access to WRF FTP server
