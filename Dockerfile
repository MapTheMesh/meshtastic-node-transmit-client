# Dockerfile to create image with cron services
FROM python:3.12-slim-bookworm
LABEL org.opencontainers.image.authors="mapthemesh@friendlydev.com"

# Add the script to the Docker Image
ADD requirements.txt /root/requirements.txt
ADD run.sh /root/run.sh

# Set the current SHELL to bash
SHELL ["/bin/bash", "-c"]

# Set the Terminal Environment
ENV TERM=xterm

# Give execution rights on the cron scripts
RUN chmod +x /root/run.sh

# Configure Timezone
RUN ln -sf /usr/share/zoneinfo/GMT /etc/localtime

# Install Dependencies
RUN apt update && \
    apt install -y jq curl

RUN pip install -r /root/requirements.txt

ENTRYPOINT ["/bin/bash", "-c", "while :; do clear && /usr/bin/env bash -c /root/run.sh && sleep 900; test $? -gt 128 && break; done"]
