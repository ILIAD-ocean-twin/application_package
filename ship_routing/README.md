# VISIR-2 Global CWL with higher resolution in Cretan Sea

## How to use it:

To be able to run this CWL flow you need to have available on your machine:

1. [Python](https://www.python.org/)
2. [Docker](https://www.docker.com/)
3. [CWLTool](https://github.com/common-workflow-language/cwltool)

To run this CWL flow you have to execute the following command:

```
cwltool workflow.cwl#run_visir job.yml
```
1. workflow.cwl is the path to the cwl workflow file
2. run_visir is the name of the workflow class to be executed
3. job.yml is the path to the file with the yml that has the input variables of the workflow

The job.yml file has, for this specific workflow, should be in a format similar to this example:

```
wrf_ftpserver: 127.0.0.1
wrf_username: username
wrf_password: password
wrf_remotedir: /dir
start_lat: 37.9406
start_lon: 23.6333
end_lat: 35.3434
end_lon: 25.1509
vessel_type: motor
cmems_username: username2
cmems_password: password2
departure_date: 2024-02-27T11:17:00Z
# maxDraught: 8
# bathymetry_file:
#   class: File
#   path: VISIR/__data/bathymetry/GEBCO_2024_sub_ice_topo.nc
```

With each variable meaning:

1. wrf_ftpserver - WRF FTP server, e.g., 127.0.0.1
2. wrf_username - WRF FTP username, e.g., username
3. wrf_password - WRF FTP password, e.g., password
4. wrf_remotedir - WRF remote directory, e.g., /iliad  which is the current directory for the files
5. start_lat - Starting latitude, e.g., 38.26392
6. start_lon - Starting longitude, e.g., 21.71479
7. end_lat - Ending latitude, e.g., 40.66274
8. end_lon - Ending longitude, e.g., 18.00269
9. vessel_type - Type of vessel, e.g., motor or sail (for sailboat where CO2 is not produced)
10. cmems_usernam	e - CMEMS username, e.g., username2
11. cmems_password - CMEMS password, e.g., password2
12. departure_date - Departure date in ISO 8601 format, e.g., 2024-02-27T11:17:00Z
13. maxDraught (Optional) - Max Draught to be used, eg., 8 which represents the minimum depth the vessel can travel onto.
14. bathymetry_file - (Optional) Bathymetry file path relative to current directory, e.g., VISIR/__data/bathymetry/GEBCO_2024_sub_ice_topo.nc

In the example above, the optional inputs are commented out. To be able to use them, you need to uncomment them and put them into a 
separate .yml file that is called in the cwltool command.

This tool uses VISIR-2 software (https://zenodo.org/records/10960842 created by CMCC, Italy) and leverages advanced algorithms to determine the most efficient paths for vessels, offering real-time and predictive insights.

The given coordinates are for a trip from Athens to Heraklion Ports, but the application package can identify if the ports are within the bounding box
of the higher resolution models (1km waves currents and 3km atmospheric forecasts) or work in global mode with inputs from GFS (27km) and CMEMS (~4.4 km).

Contact CMRL, FORTH on the following emails: antonisparasyris@iacm.forth.gr and vasmeth@iacm.forth.gr for further access to the high resolution WRF-NEMO-WWIII FTP server
