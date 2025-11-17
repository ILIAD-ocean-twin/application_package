# pyopia-demo-sintef

This tool runs a demo for the PyOpiA framework.

## Run the pyopia-demo-sintef tool

We can find the cwl repository for the pyopia-demo-sintef tool in the following link: [pyopia-demo-sintef](https://pipe-drive.inesctec.pt/application-packages/tools/pyopia-demo-sintef).

To run directly with cwltool, you can use the following command:

```
cwltool https://pipe-drive.inesctec.pt/application-packages/tools/pyopia-demo-sintef/pyopia_demo_sintef_0_1_0.cwl#pyopia_demo_sintef input.json
```

Can also be run with the with the local `tool.cwl` file:

```
cwltool tool.cwl#pyopia_demo_sintef input.json
```

You can find the application description on [ILIAD registry](https://iliad-registry.inesctec.pt/collections/apks/items?name=pyopia_demo_sintef). There you can also find the CWL reference on last fields `url`.

## Create and publish new version (CI/CD)

To create a new version of this tool, you can create a tag, usually in the format `X.Y.Z`.

#### WARN: Do not commit between the tag creation and the end of the pipeline execution, as the pipeline will use the last commit before the tag.

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
