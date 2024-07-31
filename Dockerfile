FROM quay.io/jupyter/datascience-notebook:4d70cf8da953
USER root
RUN apt update -y && apt install -y git nginx

RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jovyan && \
    chmod 0440 /etc/sudoers.d/jovyan


WORKDIR /tmp
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout local.dataloop.ai.key -out local.dataloop.ai.crt -subj "/CN=local.dataloop.ai"
RUN cp local.dataloop.ai.crt /etc/ssl/certs/ && cp local.dataloop.ai.key /etc/ssl/private/

USER jovyan
ENV HOME=/tmp

COPY . /tmp/app
WORKDIR /tmp/app
RUN sudo chmod 777 -R /tmp
RUN git clone https://github.com/dataloop-ai/dtlpy-documentation.git /tmp/dtlpy-documentation

RUN python3 -m pip install -U pip
RUN pip3 install --user --upgrade -r requirements.txt

# Switch back to root user to update npm
USER root

# Install node and npm (you can specify a specific version of node if needed)
RUN apt update && apt install -y nodejs npm

# Update npm to the latest version
RUN npm install -g npm@latest

# Switch back to jovyan user
USER jovyan


# docker build --no-cache -t gcr.io/viewo-g/piper/agent/jupyter-server:0.1.51 -f ./Dockerfile .
# docker push gcr.io/viewo-g/piper/agent/jupyter-server:0.1.51

# docker run -p 3004:3000  -it -v E:\Applications\jupyter-notebook-app:/tmp/app gcr.io/viewo-g/piper/agent/jupyter-server:0.1.51 bash

# docker run -p 3004:3000  -it gcr.io/viewo-g/piper/agent/jupyter-server:0.1.50 bash


