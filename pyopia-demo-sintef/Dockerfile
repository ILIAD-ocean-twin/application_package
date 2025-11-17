FROM python:3.12-slim

LABEL maintainer="Miguel Correia <miguel.r.correia@inesctec.pt>"
LABEL version=0.1.0

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN uv pip install --system pyopia[classification] ipywidgets directory_tree
RUN uv pip install --system --force-reinstall --upgrade xarray==2023.12.0 zarr dask fsspec

COPY script_demo.py /app/script.py
