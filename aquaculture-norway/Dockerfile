FROM iliad-repository.inesctec.pt/opendrift:1.14.3

ENV WORKSPACE_DIR=/opt
WORKDIR ${WORKSPACE_DIR}

ENV PATH=/opt/miniconda3/envs/opendrift/bin:/opt/miniconda3/bin:$PATH

SHELL ["conda", "run", "-n", "opendrift", "/bin/bash", "-c"]
SHELL ["/bin/bash", "--login", "-c"]

RUN conda install -n opendrift -y click click2cwl

COPY requirements.txt .
RUN conda install -n opendrift -y --file requirements.txt

RUN mkdir -p /aquaculturedemo
COPY runnorkystforecast.py /aquaculturedemo/runnorkystforecast.py
