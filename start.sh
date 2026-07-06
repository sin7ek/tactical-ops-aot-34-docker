#!/bin/bash
set -e

SERVER_ZIP_URL="${SERVER_ZIP_URL:-https://mirror.tactical-ops.eu/anticheat-server/servers/TO340Server-v469d-TOST4240-Nexgen113-ACE12e.zip}"
MAP="${MAP:-TO-Blister}"
GAME="${GAME:-s_SWAT.s_SWATGame}"
SERVER_INI="${SERVER_INI:-TacticalOps-Server.ini}"
EXTRA_PARAMS="${EXTRA_PARAMS:-}"
SYSTEM_DIR="${SYSTEM_DIR:-/server/System}"

ENABLE_WEBADMIN="${ENABLE_WEBADMIN:-false}"
WEBADMIN_PORT="${WEBADMIN_PORT:-5080}"
WEBADMIN_USER="${WEBADMIN_USER:-admin}"
WEBADMIN_PASSWORD="${WEBADMIN_PASSWORD:-admin}"

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
echo "WebAdmin enabled: ${ENABLE_WEBADMIN}"
echo "WebAdmin port: ${WEBADMIN_PORT}"
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

INI_PATH="${SYSTEM_DIR}/${SERVER_INI}"
DEFAULT_INI_PATH="${SYSTEM_DIR}/Default.ini"

if [ "${ENABLE_WEBADMIN}" = "true" ]; then
  echo "Configuring WebAdmin..."

  if [ ! -f "${INI_PATH}" ]; then
    echo "WARNING: Server INI not found: ${INI_PATH}"
  else
    # Enable UWeb.WebServer actor if it is commented out.
    if grep -qE '^[[:space:]]*;[[:space:]]*ServerActors=UWeb\.WebServer' "${INI_PATH}"; then
      sed -i -E 's/^[[:space:]]*;[[:space:]]*ServerActors=UWeb\.WebServer/ServerActors=UWeb.WebServer/' "${INI_PATH}"
      echo "Enabled existing UWeb.WebServer actor."
    elif grep -qE '^[[:space:]]*ServerActors=UWeb\.WebServer' "${INI_PATH}"; then
      echo "UWeb.WebServer actor already enabled."
    else
      sed -i '/^\[Engine\.GameEngine\]/a ServerActors=UWeb.WebServer' "${INI_PATH}"
      echo "Added UWeb.WebServer actor to [Engine.GameEngine]."
    fi

    # Add or update WebAdmin config section.
    if ! grep -qE '^\[UWeb\.WebServer\]' "${INI_PATH}"; then
      cat >> "${INI_PATH}" <<EOF

[UWeb.WebServer]
Applications[0]=UTServerAdmin.UTServerAdmin
ApplicationPaths[0]=/ServerAdmin
Applications[1]=UTServerAdmin.UTImageServer
ApplicationPaths[1]=/images
DefaultApplication=0
bEnabled=True
ListenPort=${WEBADMIN_PORT}
ServerName=TO3.4 Server WebAdmin
EOF
      echo "Added [UWeb.WebServer] section."
    else
      sed -i -E "/^\[UWeb\.WebServer\]/,/^\[/ s/^bEnabled=.*/bEnabled=True/" "${INI_PATH}"
      sed -i -E "/^\[UWeb\.WebServer\]/,/^\[/ s/^ListenPort=.*/ListenPort=${WEBADMIN_PORT}/" "${INI_PATH}"
      echo "Updated existing [UWeb.WebServer] section."
    fi
  fi

  # Update WebAdmin credentials in Default.ini and the active server INI.
  # Some UT/TO WebAdmin builds read from Default.ini, others from the active server INI.
  for CREDENTIALS_INI in "${DEFAULT_INI_PATH}" "${INI_PATH}"; do
    if [ -f "${CREDENTIALS_INI}" ]; then
      echo "Updating WebAdmin credentials in: ${CREDENTIALS_INI}"

      if grep -qE '^AdminUsername=' "${CREDENTIALS_INI}"; then
        sed -i -E "s/^AdminUsername=.*/AdminUsername=${WEBADMIN_USER}/" "${CREDENTIALS_INI}"
      fi

      if grep -qE '^AdminPassword=' "${CREDENTIALS_INI}"; then
        sed -i -E "s/^AdminPassword=.*/AdminPassword=${WEBADMIN_PASSWORD}/" "${CREDENTIALS_INI}"
      fi
    else
      echo "WARNING: INI not found: ${CREDENTIALS_INI}"
    fi
  done

  echo "WebAdmin configured."
  echo "WebAdmin URL: http://SERVER-IP:${WEBADMIN_PORT}/ServerAdmin/"
fi

cd "${SYSTEM_DIR}"

chmod +x ./ucc-bin || true

echo "Starting server..."
echo "./ucc-bin server \"${MAP}?game=${GAME}${EXTRA_PARAMS}\" ini=\"${SERVER_INI}\" -nohomedir"

exec ./ucc-bin server "${MAP}?game=${GAME}${EXTRA_PARAMS}" ini="${SERVER_INI}" -nohomedir
