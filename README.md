# Tactical Ops: Assault on Terror 3.4 Docker

Docker wrapper for a **Tactical Ops: Assault on Terror 3.4** dedicated server.

This project provides a small Docker container that installs the required Linux runtime dependencies and starts a TO:AoT 3.4 dedicated server.

The Tactical Ops server files are **not included in this repository or Docker image**.  
On first start, the container can download the TO3.4 server package into the mounted `/server` volume.

## Game files

The game files are downloadable here: [TO:AoT Fixed Pack](https://tactical-ops.eu/to-aot-fixed-pack.php) from [tactical-ops.eu](https://www.tactical-ops.eu).

Please also refer to their guides for client setup and game-specific configuration.

## Features

- Tactical Ops: Assault on Terror 3.4 dedicated server
- Designed for Docker Compose and Portainer
- Works well on Unraid
- Persistent server files via `/server`
- Automatic first-run server package download
- Configurable map, game type, INI file and startup parameters
- Optional WebAdmin auto-configuration

## Disclaimer

This repository only contains a Docker wrapper, startup script and documentation.

It does **not** contain Tactical Ops, Unreal Tournament, Epic Games, Infogrames, Atari, or any copyrighted game files.

Users are responsible for ensuring they are allowed to download and run the Tactical Ops server files in their jurisdiction and environment.

The MIT license applies only to the Docker wrapper, scripts and documentation in this repository. It does not apply to Tactical Ops or any third-party game files.

## Directory layout

The container expects the Tactical Ops server files to be available in `/server`.

After the first successful start, your mounted server directory should look similar to this:

```text
server/
├── Logs/
├── Maps/
├── Music/
├── Sounds/
├── System/
│   ├── ucc-bin
│   ├── TacticalOps-Server.ini
│   └── ...
├── Textures/
├── Web/
└── Readme.txt
```

## Ports

| Port | Protocol | Purpose |
|---:|---|---|
| `7777` | UDP | Game port |
| `7778` | UDP | Query port |
| `7779` | UDP | Master server uplink / additional query |
| `6665` | UDP | ACE anti-cheat communication |
| `5080` | TCP | WebAdmin interface, if enabled |

For bridge networking, publish these ports in Docker Compose.

For `br0`, `macvlan`, `ipvlan`, or other custom LAN IP setups, port publishing is usually not required because the container has its own IP address.

## WebAdmin

WebAdmin can be enabled automatically with environment variables:

```yaml
environment:
  ENABLE_WEBADMIN: "true"
  WEBADMIN_PORT: "5080"
  WEBADMIN_USER: "admin"
  WEBADMIN_PASSWORD: "change-me"
```

Then open:

```text
http://SERVER-IP:5080/ServerAdmin/
```

For bridge networking, publish TCP port `5080`:

```yaml
ports:
  - "5080:5080/tcp"
```

The WebAdmin configuration is written to the server INI on container start when `ENABLE_WEBADMIN` is set to `true`.

Change the default credentials before exposing WebAdmin to your LAN or the internet.

## Docker Compose

The image is available on Docker Hub:

```text
sin7ek/tactical-ops-aot-34-docker:latest
```

Example:

```yaml
services:
  tactical-ops-aot-34-docker:
    image: sin7ek/tactical-ops-aot-34-docker:latest
    container_name: tactical-ops-aot-34-docker
    restart: unless-stopped

    environment:
      SERVER_ZIP_URL: "https://mirror.tactical-ops.eu/anticheat-server/servers/TO340Server-v469d-TOST4240-Nexgen113-ACE12e.zip"
      MAP: "TO-Blister"
      GAME: "s_SWAT.s_SWATGame"
      SERVER_INI: "TacticalOps-Server.ini"
      EXTRA_PARAMS: ""
      SYSTEM_DIR: "/server/System"

      # Optional WebAdmin variables
      ENABLE_WEBADMIN: "true"
      WEBADMIN_PORT: "5080"
      WEBADMIN_USER: "admin"
      WEBADMIN_PASSWORD: "change-me"

    volumes:
      - ./server:/server:rw

    ports:
      - "7777-7779:7777-7779/udp"
      - "6665:6665/udp"
      - "5080:5080/tcp"

    # Optional Unraid labels
    # labels:
    #   net.unraid.docker.webui: "http://[IP]:[PORT:5080]/"
    #   net.unraid.docker.icon: "https://cdn2.steamgriddb.com/logo_thumb/7e2f21ec8c69203309c420fdf06d4012.png"
```

Start the server with:

```bash
docker compose up -d
```

View logs with:

```bash
docker logs -f tactical-ops-aot-34-docker
```

## Portainer

Use the Portainer Web editor or Git repository deployment with the Docker Hub image:

```yaml
image: sin7ek/tactical-ops-aot-34-docker:latest
```

No local build path is required.

When updating the stack in Portainer, enable:

```text
Re-pull image
Force recreate
```

Do not use `build:` unless you intentionally want to build the image yourself from source.

## Unraid bridge example

For a normal Unraid bridge setup, use an absolute host path for the persistent server files:

```yaml
services:
  tactical-ops-aot-34-docker:
    image: sin7ek/tactical-ops-aot-34-docker:latest
    container_name: tactical-ops-aot-34-docker
    restart: unless-stopped

    environment:
      SERVER_ZIP_URL: "https://mirror.tactical-ops.eu/anticheat-server/servers/TO340Server-v469d-TOST4240-Nexgen113-ACE12e.zip"
      MAP: "TO-Blister"
      GAME: "s_SWAT.s_SWATGame"
      SERVER_INI: "TacticalOps-Server.ini"
      EXTRA_PARAMS: ""
      SYSTEM_DIR: "/server/System"

      ENABLE_WEBADMIN: "true"
      WEBADMIN_PORT: "5080"
      WEBADMIN_USER: "admin"
      WEBADMIN_PASSWORD: "change-me"

    volumes:
      - /mnt/user/appdata/tacticalops34/server:/server:rw

    ports:
      - "7777-7779:7777-7779/udp"
      - "6665:6665/udp"
      - "5080:5080/tcp"

    labels:
      net.unraid.docker.webui: "http://[IP]:[PORT:5080]/"
      net.unraid.docker.icon: "https://cdn2.steamgriddb.com/logo_thumb/7e2f21ec8c69203309c420fdf06d4012.png"
```

Change the host path on the left side of the volume mapping if you want to store the server files somewhere else.

## Unraid with br0 / custom LAN IP

If you run this on Unraid and want the server to have its own LAN IP address, you can use a custom Docker network such as `br0`.

When using `br0`, port mappings are usually not required.

Example:

```yaml
services:
  tactical-ops-aot-34-docker:
    image: sin7ek/tactical-ops-aot-34-docker:latest
    container_name: tactical-ops-aot-34-docker
    restart: unless-stopped

    environment:
      SERVER_ZIP_URL: "https://mirror.tactical-ops.eu/anticheat-server/servers/TO340Server-v469d-TOST4240-Nexgen113-ACE12e.zip"
      MAP: "TO-Blister"
      GAME: "s_SWAT.s_SWATGame"
      SERVER_INI: "TacticalOps-Server.ini"
      EXTRA_PARAMS: ""
      SYSTEM_DIR: "/server/System"

      ENABLE_WEBADMIN: "true"
      WEBADMIN_PORT: "5080"
      WEBADMIN_USER: "admin"
      WEBADMIN_PASSWORD: "change-me"

    volumes:
      - /mnt/user/appdata/tacticalops34/server:/server:rw

    labels:
      net.unraid.docker.webui: "http://[IP]:[PORT:5080]/"
      net.unraid.docker.icon: "https://cdn2.steamgriddb.com/logo_thumb/7e2f21ec8c69203309c420fdf06d4012.png"

    networks:
      br0:
        ipv4_address: 192.168.1.100

networks:
  br0:
    external: true
```

Change `192.168.1.100` to the LAN IP address you want to assign to the container.

## Local development / building from source

For normal use, the Docker Hub image is recommended.

For local development, clone this repository and build the image yourself:

```bash
git clone https://github.com/sin7ek/tactical-ops-aot-34-docker.git
cd tactical-ops-aot-34-docker
docker build -t tactical-ops-aot-34-docker:local .
```

You can then use the local image in Compose:

```yaml
services:
  tactical-ops-aot-34-docker:
    build: .
    image: tactical-ops-aot-34-docker:local
```

After changing `start.sh` or the `Dockerfile`, rebuild the image. Restarting the container is not enough.

## Updating

When using the Docker Hub image, update by pulling the latest image and recreating the container:

```bash
docker pull sin7ek/tactical-ops-aot-34-docker:latest
docker compose up -d
```

In Portainer, update the stack with:

```text
Re-pull image
Force recreate
```

## Quirks

### Modern Windows DPI scaling

If the game window or mouse behaves strangely on modern Windows, enable DPI scaling override on the client:

```text
TacticalOps.exe → Properties → Compatibility → Change high DPI settings → Override high DPI scaling behavior → Application
```

This is a client-side setting and cannot be pushed from the server.

### WebAdmin credentials

Some TO/UT WebAdmin builds may read default credentials from `System/Default.ini`.

For the included TO3.4 server pack, the default credentials may be:

```text
Username: admin
Password: admin
```

When using `ENABLE_WEBADMIN=true`, this container attempts to set the configured WebAdmin username and password automatically.
