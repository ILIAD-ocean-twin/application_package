# aquaculture-norway

This tool is derived from the original [GitHub](https://github.com/ILIAD-ocean-twin/aquaculture-norway/tree/master/opendrift) repository. It is based on the [OpenDrift](https://opendrift.github.io/index.html) project.

The tool is divided into 2 docker images, one for the `OpenDrift` tool and it's dependencies, and other for the `aquaculture-norway` itself.

## Opendrift docker image

The Dockerfile for the `OpenDrift` tool can be found [here](./Dockerfile.opendrift).

To build and publish the image, you can use the following commands:

```bash
IMAGE_NAME=opendrift:X.Y.Z
docker build -f Dockerfile.opendrift . -t $IMAGE_NAME
docker tag $IMAGE_NAME iliad-repository.inesctec.pt/$IMAGE_NAME
docker push iliad-repository.inesctec.pt/$IMAGE_NAME
```

`1.14.3` is the used `Opendrift` version for this project.

### Why a custom Opendrift image?

The original `Opendrift` image does not follow best practices for creating Docker images, so a new Dockerfile was created to work on cwltool and other CWL runners.
But for a correct answer on why the original image does not follow best practices, `Opendrift` docker image uses micromamba to install the dependencies, which is not a bad practice, but uses python and it's dependencies in a specific user and cannot be called from any other user, which is a problem for cwltool and other CWL runners that use a different user to run the commands.

## Run the aquaculture-norway tool

We can find the cwl repository for the `aquaculture-norway` tool in the following link: [aquaculture-norway](https://pipe-drive.inesctec.pt/application-packages/tools/aquaculture-norway).

To run directly with cwltool, you can use the following command:

```
cwltool https://pipe-drive.inesctec.pt/application-packages/tools/aquaculture-norway/aquaculture_norway_0_1_0.cwl#aquaculture-norway input.json
```

Can also be run with the with the local `tool.cwl` file:

```
cwltool tool.cwl#aquaculture-norway input.json
```

Example of input file (`input.json`):

```json
{
  "aqua_site_file": "https://iliadmonitoringtwin.blob.core.windows.net/public-data/salmon-sites-midnorway.xlsx",
  "aqua_site_distances_files": "https://iliadmonitoringtwin.blob.core.windows.net/public-data/sites-atsea-salmonoids-midnor-distances.xlsx",
  "aqua_opendrift_particles_per_site": 1,
  "aqua_opendrift_simulation_duration_hours": 1,
  "aqua_connectivity_number_of_neighbours": 10,
  "aqua_connectivity_radius": 100
}
```

You can find the application description on [ILIAD registry](https://iliad-registry.inesctec.pt/collections/aps/items/aquaculture_norway). There you can also find the CWL reference on last fields `url`.

## Changes made to the original repository

1) As explained before, we started to create a new Dockerfile for the `Opendrift` image, to follow best practices and to work on cwltool and other CWL runners.

2) The original code uses Environment Variables to pass the input parameters, which is not a good practice for CWL tools, so we changed the code to use input parameters instead. The input parameters are defined with `click` library, which is a good practice for command line tools.

3) The original code expects to upload the results to an S3, which cannot be the expected behavior for a APKG tool, so we changed the code to output the results to the output folder. To upload the results to an S3, you can use the [2s3](https://gitlab.inesctec.pt/humanise/_eoss/iliad/application-packages/tools/2s3) tool. In this phase, we removed the S3 upload code, variables and dependencies.

4) Update the Dockerfile for the `aquaculture-norway` image to use the new `Opendrift` image and install it's requirements.

## Create and publish new version (CI/CD)

To create a new version of this tool, you can create a tag, usually in the format `X.Y.Z`.

#### WARN: Do not commit between the tag creation and the pipeline execution, as the pipeline will use the last commit before the tag.

After a tag creation, a CI/CD pipeline will be triggered:

- Delete the created tag and create a new one with 'dev\_ $`X.Y.Z`', to keep the original changes (like a restore point)
- Commits the new version to the main branch
- Updates the `Dockerfile` and `tool.cwl` with the new version
- Builds the Docker image and pushes it to the registry
- Stores the `tool.cwl` in the drive
- Delete older `tool.cwl` on the registry
- Uploads the new `tool.cwl` to the registry
- Commits the changes to the main branch
- Commits the changes to the source branch from the tag, if not the main branch
- Recreates the original tag with the new changes
