# Use a lightweight Python base image
FROM python:3.10-slim

# Install necessary system dependencies
RUN apt update -y && apt install -y --no-install-recommends \
    nginx build-essential libssl-dev sudo \
    && rm -rf /var/lib/apt/lists/*

# Create the sudoers.d directory and set permissions for the jovyan user
RUN mkdir -p /etc/sudoers.d && \
    adduser --disabled-password --gecos '' jovyan && \
    echo "jovyan ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jovyan && \
    chmod 0440 /etc/sudoers.d/jovyan

# Install Jupyter Lab and necessary Python packages
RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir jupyterlab tornado==6.4 requests==2.31.0

# Switch to jovyan user
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
# Install Python dependencies for your app
RUN pip install --user --upgrade -r requirements.txt
USER jovyan

