# Dockerfile to create image with cron services
FROM python:3.12-slim-bookworm

LABEL org.opencontainers.image.authors="mapthemesh@friendlydev.com"
LABEL org.opencontainers.image.source = "https://github.com/MapTheMesh/meshtastic-node-transmit-client"

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
    apt install -y jq curl cron

RUN pip install -r /root/requirements.txt

# Create a bash script to run the run.sh script every 15 minutes
RUN echo "*/15 * * * * source /etc/environment; PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; /root/run.sh > /proc/1/fd/1 2>/proc/1/fd/2" >> /etc/crontab

# Apply cron job
RUN crontab /etc/crontab

# Start the cron service
ENTRYPOINT printenv > /etc/environment && /usr/sbin/cron -f
