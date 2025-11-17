FROM iliad-repository.inesctec.pt/opendrift:1.14.6

LABEL maintainer="Miguel Correia <miguel.r.correia@inesctec.pt>"
LABEL version=0.2.0

ENV WORKSPACE_DIR=/opt
WORKDIR ${WORKSPACE_DIR}

ENV PATH=/opt/miniconda3/envs/opendrift/bin:/opt/miniconda3/bin:$PATH

ENV PATH=/.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN pip install click click2cwl

COPY requirements.txt .
RUN pip install -r requirements.txt

RUN mkdir -p /mpa
COPY runnorkystforecast.py /mpa/runnorkystforecast.py
