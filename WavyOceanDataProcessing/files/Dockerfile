FROM python:alpine3.19

WORKDIR /opt

RUN pip install click

COPY WavyOcean.py /opt

CMD ["python", "/opt/WavyOcean.py",  "--help"]
