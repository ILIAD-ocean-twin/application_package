FROM fisheries_packages

WORKDIR /usr/local/src/fisheries

############################
##  PYTHON from pyenv
############################
RUN apt-get update
RUN apt-get install -y git

RUN apt-get update

RUN git clone https://github.com/pyenv/pyenv.git /usr/local/src/fisheries/.pyenv

# RUN curl https://pyenv.run | bash
ARG ROOT_HOME=/usr/local/src/fisheries
ENV ROOT_HOME ${ROOT_HOME}
ENV PYENV_ROOT="${ROOT_HOME}/.pyenv"
ENV PATH="${ROOT_HOME}/.pyenv/bin:${PATH}"
ARG PYTHON_VERSION=3.10
ENV PYTHON_VERSION ${PYTHON_VERSION}

RUN pyenv install ${PYTHON_VERSION}

RUN git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

RUN pyenv virtualenv ${PYTHON_VERSION} base && \
    pyenv global base

ENV PATH="/usr/local/src/fisheries/.pyenv/versions/base/bin:$PATH"

############################
##  Model requirements
############################

COPY Scripts /usr/local/src/fisheries/Scripts
COPY Models /usr/local/src/fisheries/Models
COPY Input /usr/local/src/fisheries/Input

RUN mkdir /usr/local/src/fisheries/Output

COPY requirements.txt /usr/local/src/fisheries/requirements.txt

RUN pip install -r requirements.txt


# Copy the shell script to your image
COPY fisheries.sh /usr/local/bin/fisheries

# Add executable permissions
RUN chmod +x /usr/local/bin/fisheries

# Add the alias to the Dockerfile
RUN echo 'alias fisheries="fisheries.sh"' >> /usr/local/src/fisheries/.fisheries

# Set an environment variable to ensure non-interactive bash sessions also source the .bashrc
ENV BASH_ENV=/usr/local/src/fisheries/.fisheries

