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

# End
