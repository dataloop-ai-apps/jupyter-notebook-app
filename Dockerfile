
FROM jupyter/base-notebook:latest

USER root

RUN apt-get update && \
    apt-get install -y nginx curl gcc python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Give jovyan sudo privileges
RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jovyan && \
    chmod 0440 /etc/sudoers.d/jovyan

USER jovyan
ENV HOME=/tmp

# Copy application files
COPY ./functions /tmp/app/functions
COPY ./start_dev.sh /tmp/app
COPY ./start.sh /tmp/app
COPY ./panels /tmp/app/panels
COPY ./requirements.txt /tmp/app

WORKDIR /tmp/app
RUN sudo chmod 777 -R /tmp

# Update pip and install Python dependencies
RUN pip install --no-cache-dir -U pip && \
    pip install --no-cache-dir -r requirements.txt

