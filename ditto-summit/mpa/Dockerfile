FROM iliad-repository.inesctec.pt/opendrift:1.14.6

LABEL maintainer="Miguel Correia <miguel.r.correia@inesctec.pt>"
LABEL version=0.2.0

ENV WORKSPACE_DIR=/opt
WORKDIR ${WORKSPACE_DIR}

ENV PATH=/opt/miniconda3/envs/opendrift/bin:/opt/miniconda3/bin:$PATH

ENV PATH=/.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN pip install click click2cwl

# COPY requirements.txt .
# RUN pip install -r /opt/requirements.txt

RUN mkdir -p /simulation

COPY mpa.py /simulation/mpa.py

RUN apk add --no-cache curl

RUN mkdir -p /simulation/data \
    && curl -fL \
        "https://ows.emodnet-humanactivities.eu/geonetwork/srv/api/records/ddbe3597-4e3f-4e74-8d31-947c4efef2e9/attachments/EMODnet_HA_OG_Offshore_Installations_20240216.zip" \
        -o /tmp/emodnet.zip \
    && unzip -oq /tmp/emodnet.zip -d /simulation/data \
    && rm /tmp/emodnet.zip