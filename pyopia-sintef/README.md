# pyopia-sintef

This tool runs the PyOpiA framework.

## Run the pyopia-sintef tool

We can find the cwl repository for the pyopia-sintef tool in the following link: [pyopia-sintef](https://pipe-drive.inesctec.pt/application-packages/tools/pyopia-sintef).

To run directly with cwltool, you can use the following command:

```
cwltool https://pipe-drive.inesctec.pt/application-packages/tools/pyopia-sintef/pyopia_sintef_0_1_0.cwl#pyopia_sintef input.json
```

Can also be run with the with the local `tool.cwl` file:

```
cwltool tool.cwl#pyopia_sintef input.json
```

You can find the application description on [ILIAD registry](https://iliad-registry.inesctec.pt/collections/apks/items?name=pyopia_sintef). There you can also find the CWL reference on last fields `url`.

This is the PyOPIA inputs:
 - Option 1 -> S3 bucket
 - Option 2 -> Public folder (e.g. nginx autoindex) e.g.: https://pipe-drive.inesctec.pt/inputs/pyopia/

Either of the above options, should expose:

  - Dir_name (default value - no need to modify)

  (Option 1) S3 Bucket
  - S3_endpoint
  - S3_region
  - S3_access_key
  - S3_secret_key
  - S3_session_token
  - S3_bucket_name
  - S3_path - base path to the inputs directory
  

 (Option 2) URL
  - Directory

#### 1) If you opt by Option1 then you need to input:

- Dir_name (default value - no need to modify)
- S3_endpoint
- S3_region
- S3_access_key
- S3_secret_key
- S3_session_token
- S3_bucket_name
- S3_path

#### 2) If you opt by Option2 then you need to input:
- Dir_name (default value - no need to modify)
- Directory - URL of the public directory
