#!/bin/bash
set -e

SERVER_ZIP_URL="${SERVER_ZIP_URL:-https://mirror.tactical-ops.eu/anticheat-server/servers/TO340Server-v469d-TOST4240-Nexgen113-ACE12e.zip}"
MAP="${MAP:-TO-Blister}"
GAME="${GAME:-s_SWAT.s_SWATGame}"
SERVER_INI="${SERVER_INI:-TacticalOps-Server.ini}"
EXTRA_PARAMS="${EXTRA_PARAMS:-}"
SYSTEM_DIR="${SYSTEM_DIR:-/server/System}"

echo "=================================================="
echo " Tactical Ops: Assault on Terror 3.4 Docker"
echo "=================================================="
echo "Server directory: /server"
echo "System directory: ${SYSTEM_DIR}"
echo "Server ZIP URL: ${SERVER_ZIP_URL}"
echo "Map: ${MAP}"
echo "Game: ${GAME}"
echo "INI: ${SERVER_INI}"
echo "Extra params: ${EXTRA_PARAMS}"
echo "=================================================="

if [ ! -f "${SYSTEM_DIR}/ucc-bin" ]; then
  echo "Tactical Ops server files not found."
  echo "Downloading server pack..."

  mkdir -p /tmp/to-download
  curl -fL "${SERVER_ZIP_URL}" -o /tmp/to-download/server.zip

  echo "Extracting server pack..."
  unzip -q /tmp/to-download/server.zip -d /tmp/to-download/extracted

  echo "Looking for extracted server directory..."

  if [ -d /tmp/to-download/extracted/TO340Server ]; then
    echo "Found TO340Server directory."
    cp -a /tmp/to-download/extracted/TO340Server/. /server/
  elif [ -d /tmp/to-download/extracted/System ]; then
    echo "Found System directory at archive root."
    cp -a /tmp/to-download/extracted/. /server/
  else
    echo "ERROR: Could not find TO340Server or System directory inside zip."
    echo "Extracted contents:"
    find /tmp/to-download/extracted -maxdepth 3 -type d | sort
    exit 1
  fi

  rm -rf /tmp/to-download
fi

if [ ! -f "${SYSTEM_DIR}/ucc-bin" ]; then
  echo "ERROR: ucc-bin was not found at:"
  echo "${SYSTEM_DIR}/ucc-bin"
  echo
  echo "Current /server contents:"
  find /server -maxdepth 3 -type d | sort
  exit 1
fi

cd "${SYSTEM_DIR}"

chmod +x ./ucc-bin || true

echo "Starting server..."
echo "./ucc-bin server \"${MAP}?game=${GAME}${EXTRA_PARAMS}\" ini=\"${SERVER_INI}\" -nohomedir"

exec ./ucc-bin server "${MAP}?game=${GAME}${EXTRA_PARAMS}" ini="${SERVER_INI}" -nohomedir
