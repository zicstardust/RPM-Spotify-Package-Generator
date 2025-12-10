# RPM Spotify Package Generator

A lightweight tool that automates the creation of RPM packages for Spotify. It downloads the latest Spotify release, applies necessary adjustments for system compatibility, and bundles everything into a clean RPM package ready for installation on RPM-based Linux distributions such as Fedora and RHEL derivatives.

Designed for simplicity and reliability, this generator helps users maintain up-to-date Spotify installations without relying on unofficial or outdated repositories.


[GitHub](https://github.com/zicstardust/RPM-Spotify-Package-Generator)

[Docker Hub](https://hub.docker.com/r/zicstardust/RPM-Spotify-Package-Generator)



## Tags

| Tag | Architecture | Description |
| :----: | :----: |--- |
| [`latest`, `fc43`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile) | amd64 | Create a Spotify package for the latest stable version of Fedora. |
| [`fc42`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-fedora-previous) | amd64 | Create a Spotify package for the previous stable version of Fedora. |
| [`fc44`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-fedora-beta) | amd64 | Create a Spotify package for Fedora Beta. |
| [`rawhide`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-fedora-rawhide) | amd64 | Create a Spotify package for Fedora Rawhide. |
| [`el8`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-el8) | amd64 | Create a Spotify package for RHEL 8 derivatives |
| [`el9`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-el9) | amd64 | Create a Spotify package for RHEL 9 derivatives |
| [`el10`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-el10) | amd64 | Create a Spotify package for RHEL 10 derivatives |

## Usage
### docker-compose
```
services:
  spotify-rpm:
    container_name: RPM-Spotify-Package-Generator
    image: zicstardust/RPM-Spotify-Package-Generator:latest
    environment:
      TZ: America/New_York
      #INTERVAL: 1d
    volumes:
      - <path to RPMs output>:/data
```

## Environment variables

| variables | Function | Default |
| :----: | --- | --- |
| `TZ` | Set Timezone | |
| `PUID` | Set UID | 1000 |
| `PGID` | Set GID | 1000 |
| `INTERVAL` | Set the interval to check for updates and generate the next RPM. | `1d` |
