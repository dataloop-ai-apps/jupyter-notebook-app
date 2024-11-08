FROM quay.io/jupyter/datascience-notebook:4d70cf8da953
USER root
RUN apt update -y && apt install -y nginx

RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jovyan && \
    chmod 0440 /etc/sudoers.d/jovyan

USER jovyan
ENV HOME=/tmp

# Copy your application files
COPY ./functions /tmp/app/functions
COPY ./start_dev.sh /tmp/app
COPY ./start.sh /tmp/app
COPY ./panels /tmp/app/panels
COPY ./requirements.txt /tmp/app

WORKDIR /tmp/app
RUN sudo chmod 777 -R /tmp

RUN python3 -m pip install -U pip
RUN pip3 install --user --upgrade -r requirements.txt



USER jovyan

