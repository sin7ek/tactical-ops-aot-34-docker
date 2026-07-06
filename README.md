# Tactical Ops: Assault on Terror 3.4 Docker

Docker wrapper for a **Tactical Ops: Assault on Terror 3.4** dedicated server.

This project provides a small Docker container that installs the required Linux runtime dependencies and starts a TO:AoT 3.4 dedicated server.

The Tactical Ops server files are **not included in this repository or Docker image**.  
On first start, the container can download the TO3.4 server package into the mounted `/server` volume.

## Features

- Tactical Ops: Assault on Terror 3.4 dedicated server
- Designed for Docker Compose / Portainer
- Works well on Unraid
- Persistent server files via `/server`
- Automatic first-run server package download
- Configurable map, game type, INI file and startup parameters

## Disclaimer

This repository only contains a Docker wrapper and startup script.

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
| `5080` | TCP | Web/admin interface, if enabled by server config |

## Docker Compose

For a normal Docker Compose or Portainer setup, use the included `docker-compose.yml`.

Example:

```yaml
services:
  tactical-ops-aot-34-docker:
    build: .
    image: tactical-ops-aot-34-docker:local
    container_name: tactical-ops-aot-34-docker
    restart: unless-stopped

    environment:
      SERVER_ZIP_URL: "https://mirror.tactical-ops.eu/anticheat-server/servers/TO340Server-v469d-TOST4240-Nexgen113-ACE12e.zip"
      MAP: "TO-Blister"
      GAME: "s_SWAT.s_SWATGame"
      SERVER_INI: "TacticalOps-Server.ini"
      EXTRA_PARAMS: ""
      SYSTEM_DIR: "/server/System"

    volumes:
      - ./server:/server:rw

    ports:
      - "7777-7779:7777-7779/udp"
      - "5080:5080/tcp"
      - "6665:6665/udp"

    # Optional Unraid labels:
    # labels:
    #   net.unraid.docker.webui: "http://[IP]:[PORT:5080]/"
    #   net.unraid.docker.icon: "https://cdn2.steamgriddb.com/logo_thumb/7e2f21ec8c69203309c420fdf06d4012.png"
```

Start the server with:

```bash
docker compose up -d
```

Logs:

```bash
docker logs -f tactical-ops-aot-34-docker

```
## Unraid with br0 / custom LAN IP

If you run this on Unraid and want the server to have its own LAN IP address, you can use a custom Docker network such as `br0`.

Example:

```yaml
services:
  tactical-ops-aot-34-docker:
    build: .
    image: tactical-ops-aot-34-docker:local
    container_name: tactical-ops-aot-34-docker
    restart: unless-stopped

    environment:
      SERVER_ZIP_URL: "https://mirror.tactical-ops.eu/anticheat-server/servers/TO340Server-v469d-TOST4240-Nexgen113-ACE12e.zip"
      MAP: "TO-Blister"
      GAME: "s_SWAT.s_SWATGame"
      SERVER_INI: "TacticalOps-Server.ini"
      EXTRA_PARAMS: ""
      SYSTEM_DIR: "/server/System"

    volumes:
      # Host path : Container path
      # Change the host path (left side, everything before *:/server:rw*) to your own path
      - /mnt/user/appdata/tacticalops34/server:/server:rw

    labels:
      net.unraid.docker.webui: "http://[IP]:[PORT:5080]/"
      net.unraid.docker.icon: "https://cdn2.steamgriddb.com/logo_thumb/7e2f21ec8c69203309c420fdf06d4012.png"

    networks:
      br0:
        ipv4_address: 192.168.1.100 # Change this to your desired LAN IP

networks:
  br0:
    external: true

```
Change `/mnt/user/appdata/tacticalops34/server` to the location where you want to store the persistent Tactical Ops server files on your Unraid server.
When using `br0`, port mappings are usually not required because the container has its own IP address.
