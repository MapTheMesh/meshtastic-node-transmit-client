# Dockerfile to create image with cron services
FROM ubuntu:latest
MAINTAINER map.themesh.live

# Add the script to the Docker Image
ADD requirements.txt /root/requirements.txt
ADD run.sh /root/run.sh

# Set the current SHELL to bash
SHELL ["/bin/bash", "-c"]

# Set the Terminal Environment
ENV TERM xterm

# Give execution rights on the cron scripts
RUN chmod +x /root/run.sh

# Configure Timezone
RUN ln -sf /usr/share/zoneinfo/GMT /etc/localtime

# Install Dependencies
RUN apt update
RUN apt install -y python3-pip
RUN apt install -y python3-virtualenv
RUN apt install -y jq
RUN apt install -y curl

RUN virtualenv -p python3 /root/venv
ENV PATH="/root/venv/bin:$PATH"
RUN /root/venv/bin/pip install -r /root/requirements.txt

ENTRYPOINT ["/bin/bash", "-c", "while :; do clear && /usr/bin/env bash -c /root/run.sh && sleep 900; done"]
