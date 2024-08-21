FROM python:alpine3.19

WORKDIR /opt

RUN pip install click

COPY WavyOceanDataProcessing.py /opt

CMD ["python", "/opt/WavyOceanDataProcessing.py",  "--help"]
