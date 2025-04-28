# Satellite detection of oil spills and forecasting through MEDSLIK II and high resolution models (Cretan Sea Domain) and lower resolution models (Global) options.
# Co created by FORTH-Greece, MEEO-Italy and INESCTEC-Portugal.

## How to use it:

To be able to run this CWL flow you need to have available on your machine:

1. [Python](https://www.python.org/)
2. [Docker](https://www.docker.com/)
3. [CWLTool](https://github.com/common-workflow-language/cwltool)

To run this CWL flow you have to execute the following command:

```
cwltool pipeline156.cwl#oilspill_pipeline_medslik_156 example.json
```
1. pipeline156.cwl is the path to the cwl workflow file
2. oilspill_pipeline_medslik_156 is the name of the workflow class to be executed
3. example.yml is the path to the file with the json  that has the input variables of the workflow

The example.yml file has, for this specific workflow, should be in a format similar to this example:

```
{
  "bbox": "24.07,35.70,24.69,36.26",
  "use_case_directory": "MEDSLIK_GLO",
  "start_date": "2023-06-27",
  "time_interval": 1,
  "verbose": true,  
  "debug": false,  
  "asf_username": "iliad_os",
  "asf_password": "password_asf",
  "cont_slick": "YES",
  "sat": "YES",
  "use_high_res": "NO",
  "min_lon": 24.07,
  "max_lon": 24.69,
  "min_lat": 35.70,
  "max_lat": 35.26,
  "lat_point": 33.892,
  "lon_point": 24.866,
  "date_spill": "2024-03-02T06:22:00Z",
  "spill_dur": "0001",
  "spill_res": "150.0",
  "spill_tons": 1.4,
  "username": "CMEMS_username",
  "password": "CMEMS_password",
  "ftp_server": "ftp_address_request_forth",
  "ftp_user": "iliad",
  "ftp_password": "password_request_forth",
  "remote_dir": "/iliad",
  "cds_token": "40d8b300-afa6-49d9-a1be-18ac497df73c"
}

#some identified examples through SAT:
#crete 24.07,35.70,24.69,36.26       2023-06-27
# corsica 8.8773, 43.29, 9.3885, 43.5292 
#tobago -61.5777, 10.9358, -60.5211, 11.4523     2024-02-14
```

The user either uses the SAT and cont_slick as YES, so the bbox is needed to identify a bounding box to be searched for an entire day "start_date".
If SAT and cont_slick are NO, then the second set of inputs are used, which specify a point spill:
  "min_lon": 24.07,
  "max_lon": 24.69,
  "min_lat": 35.70,
  "max_lat": 35.26,
  "lat_point": 33.892,
  "lon_point": 24.866,
  "date_spill": "2024-03-02T06:22:00Z",

Another option is given by "use_high_res": "NO" which is faster with NO, but uses higher resolution models of Coastal Crete if YES, and the spill is around the island of Crete.

Several credentials are needed to cover all possible run options:
  "asf_username": "iliad_os",
  "asf_password": "password_asf",
  "username": "CMEMS_username",
  "password": "CMEMS_password",
  "ftp_server": "ftp_address_request_forth",
  "ftp_user": "iliad",
  "ftp_password": "password_request_forth",
  "cds_token": "40d8b300-afa6-49d9-a1be-18ac497df73c"

Contact CMRL, FORTH on the following emails: antonisparasyris@iacm.forth.gr and vasmeth@iacm.forth.gr for further access to the high resolution WRF-NEMO-WWIII FTP server.
