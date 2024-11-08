# Use a lightweight Python base image
FROM python:3.10-slim

# Install necessary system dependencies
RUN apt update -y && apt install -y --no-install-recommends \
    nginx build-essential libssl-dev sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter Lab and necessary Python packages
RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir jupyterlab tornado==6.4 requests==2.31.0

RUN useradd -m -u 1000 myuser
USER myuser

# Set the working directory to /tmp/app
WORKDIR /tmp/app

# Copy files and directories into the working directory (already set to /tmp/app)
COPY --chown=myuser:myuser ./functions ./functions
COPY --chown=myuser:myuser ./start_dev.sh .
COPY --chown=myuser:myuser ./start.sh .
COPY --chown=myuser:myuser ./panels ./panels
COPY --chown=myuser:myuser ./requirements.txt .



# Install Python dependencies for your app
RUN pip install --user --upgrade -r requirements.txt
USER jovyan

