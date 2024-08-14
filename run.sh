#!/usr/bin/env bash

# print ascii header if the terminal is wide enough
if [ $(tput cols) -lt 165 ]; then
  echo $'╔════════════════════════════╗';
  echo $'║         Meshtastic         ║';
  echo $'║    Node Transmit Client    ║';
  echo $'╚════════════════════════════╝\n';
else
  echo "                                                                                                                                                                     ";
  echo "╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗";
  echo "║                                                                                                                                                                   ║";
  echo "║                                         ███╗   ███╗███████╗███████╗██╗  ██╗████████╗ █████╗ ███████╗████████╗██╗ ██████╗                                          ║";
  echo "║                                         ████╗ ████║██╔════╝██╔════╝██║  ██║╚══██╔══╝██╔══██╗██╔════╝╚══██╔══╝██║██╔════╝                                          ║";
  echo "║                                         ██╔████╔██║█████╗  ███████╗███████║   ██║   ███████║███████╗   ██║   ██║██║                                               ║";
  echo "║                                         ██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║   ██║   ██╔══██║╚════██║   ██║   ██║██║                                               ║";
  echo "║                                         ██║ ╚═╝ ██║███████╗███████║██║  ██║   ██║   ██║  ██║███████║   ██║   ██║╚██████╗                                          ║";
  echo "║                                         ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝ ╚═════╝                                          ║";
  echo "║                                                                                                                                                                   ║";
  echo "║    ███╗   ██╗ ██████╗ ██████╗ ███████╗    ████████╗██████╗  █████╗ ███╗   ██╗███████╗███╗   ███╗██╗████████╗     ██████╗██╗     ██╗███████╗███╗   ██╗████████╗    ║";
  echo "║    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝    ╚══██╔══╝██╔══██╗██╔══██╗████╗  ██║██╔════╝████╗ ████║██║╚══██╔══╝    ██╔════╝██║     ██║██╔════╝████╗  ██║╚══██╔══╝    ║";
  echo "║    ██╔██╗ ██║██║   ██║██║  ██║█████╗         ██║   ██████╔╝███████║██╔██╗ ██║███████╗██╔████╔██║██║   ██║       ██║     ██║     ██║█████╗  ██╔██╗ ██║   ██║       ║";
  echo "║    ██║╚██╗██║██║   ██║██║  ██║██╔══╝         ██║   ██╔══██╗██╔══██║██║╚██╗██║╚════██║██║╚██╔╝██║██║   ██║       ██║     ██║     ██║██╔══╝  ██║╚██╗██║   ██║       ║";
  echo "║    ██║ ╚████║╚██████╔╝██████╔╝███████╗       ██║   ██║  ██║██║  ██║██║ ╚████║███████║██║ ╚═╝ ██║██║   ██║       ╚██████╗███████╗██║███████╗██║ ╚████║   ██║       ║";
  echo "║    ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝       ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝     ╚═╝╚═╝   ╚═╝        ╚═════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝       ║";
  echo "║                                                                                                                                                                   ║";
  echo "╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝";
  echo "                                                                                                                                                                     ";
fi

# check if python is installed
if ! command -v python &> /dev/null; then
  echo "Python is not installed"
  exit 1
fi

# check if meshtastic is installed
if ! command -v meshtastic &> /dev/null; then
  echo "Meshtastic CLI is not installed"
  exit 1
fi

# check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "\"jq\" is not installed"
  exit 1
fi

# read the environment variables if the .env file exists
if [ -f .env ]; then
  unamestr=$(uname)

  if [ "$unamestr" = 'Linux' ]; then
    export $(grep -v '^#' .env | xargs -d '\n')
  elif [ "$unamestr" = 'FreeBSD' ] || [ "$unamestr" = 'Darwin' ]; then
    export $(grep -v '^#' .env | xargs -0)
  fi
fi

# safeurl encode function
safeurl_encode() {
  local data="$1"
  data="${data//+//}"
  data="${data//-/_}"
  echo "${data//=/}"
}

# get hash of the data
data_hash() {
  local data="$1"
  data=$(sha512sum < "${data}")
  data="${data//-/}"
  echo "${data// /}"
}

CONNECTION=""

# if MESHTASTIC_PORT is set, then use it as the connection string
if [ -n "${MESHTASTIC_PORT}" ]; then
  echo $'- Using MESHTASTIC_PORT as the connection string'
  echo $"    - \"--port ${MESHTASTIC_PORT}\""

  CONNECTION="--port ${MESHTASTIC_PORT}"
fi

# if MESHTASTIC_HOST is set, then use it as the connection string
if [ -n "${MESHTASTIC_HOST}" ]; then
  echo $'- Using MESHTASTIC_HOST as the connection string'
  echo $"    - Connection String: \"--host ${MESHTASTIC_HOST}\""

  CONNECTION="--host ${MESHTASTIC_HOST}"
fi

# if MESHTASTIC_PORT is set, then use it as the connection string
if [ -n "${MESHTASTIC_BLE}" ]; then
  echo $'- Using MESHTASTIC_BLE as the connection string'
  echo $"    - \"--ble ${MESHTASTIC_BLE}\""

  CONNECTION="--ble ${MESHTASTIC_BLE}"
fi

# use the meshtastic CLI to get the info
# and save the output to a file
echo $'- Fetching node info from Meshtastic Device...'
echo $"    - Command: \"meshtastic ${CONNECTION} --info\""
MESHTASTIC_INFO_OUTPUT=$(meshtastic $CONNECTION --info)
_COMMAND_EXIT_CODE=$?
_INFO_TMP_FILE=$(mktemp /tmp/com.friendlydev.node-transmit.XXXXXXXXXXXX)
echo "${MESHTASTIC_INFO_OUTPUT}" > "${_INFO_TMP_FILE}"

# check if the output is empty
if [ $_COMMAND_EXIT_CODE -ne 0 ]; then
  rm -f -- "${_INFO_TMP_FILE}"
  echo $'\nUnable to fetch node info\n'
  trap - EXIT
  exit 1
fi

# extract the node info we need from the output
_OWNER=$(echo "${MESHTASTIC_INFO_OUTPUT}" | grep -e 'Owner: ' | cut -d ' ' -f2-)
_ID=$(echo "${MESHTASTIC_INFO_OUTPUT}" | grep -e 'My info: ' | cut -d ' ' -f3- | jq -r .myNodeNum)
_FIRMWARE_VERSION=$(echo "${MESHTASTIC_INFO_OUTPUT}" | grep -e 'Metadata: ' | cut -d ' ' -f2- | jq -r .firmwareVersion)
_HARDWARE=$(echo "${MESHTASTIC_INFO_OUTPUT}" | grep -e 'Metadata: ' | cut -d ' ' -f2- | jq -r .hwModel)
_ROLE=$(echo "${MESHTASTIC_INFO_OUTPUT}" | grep -e 'Metadata: ' | cut -d ' ' -f2- | jq -r .role)

# if the user has a custom MESHTASTIC_API_URL set, use that
if [ -z "${MESHTASTIC_API_URL}" ]; then
  MESHTASTIC_API_URL="https://api.themesh.live/upload-nodes"
fi

echo $'- Uploading node info to the server...'
printf "    - Endpoint: \"%s\"\n" "$MESHTASTIC_API_URL"

# upload the payload to the server
curl \
  --silent \
  -o /dev/null \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
  --data-urlencode "owner=${_OWNER}" \
  --data-urlencode "id=${_ID}" \
  --data-urlencode "firmware=${_FIRMWARE_VERSION}" \
  --data-urlencode "hardware=${_HARDWARE}" \
  --data-urlencode "role=${_ROLE}" \
  --data-urlencode "info=$(safeurl_encode $(base64 < "${_INFO_TMP_FILE}"))" \
  --data-urlencode "info_hash=$(data_hash "${_INFO_TMP_FILE}")" \
  "${MESHTASTIC_API_URL}"

# let user know if upload was successful
if [ $? -eq 0 ]; then
  echo $'    - Upload successful'
else
  echo $'    - Upload failed'
  exit 1
fi

echo $'- Cleaning up...'

# cleanup the files
rm -f -- "${_INFO_TMP_FILE}"

echo $'\nAll done!'

trap - EXIT
exit 0
