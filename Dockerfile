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
#RUN echo "*/15 * * * * source /etc/environment; /bin/bash -c /root/run.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/meshtastic-node-transmit-client
RUN echo "* * * * * source /etc/environment; PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; /root/run.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/meshtastic-node-transmit-client

# Give execution rights on the cron scripts
RUN chmod 0644 /etc/cron.d/meshtastic-node-transmit-client

# Apply cron job
RUN crontab /etc/cron.d/meshtastic-node-transmit-client

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD echo $'Starting the runner for MapTheMesh'; printenv > /etc/environment; cron; echo $'Cron started, tailing the log file...'; tail -f /var/log/cron.log
