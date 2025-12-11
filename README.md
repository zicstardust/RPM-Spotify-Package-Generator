# RPM Spotify Package Generator

A lightweight tool that automates the creation of RPM packages for Spotify. It downloads the latest Spotify release, applies necessary adjustments for system compatibility, and bundles everything into a clean RPM package ready for installation on RPM-based Linux distributions such as Fedora and RHEL derivatives.

Designed for simplicity and reliability, this generator helps users maintain up-to-date Spotify installations without relying on unofficial or outdated repositories.


[GitHub](https://github.com/zicstardust/rpm-spotify-package-generator)

[Docker Hub](https://hub.docker.com/r/zicstardust/RPM-Spotify-Package-Generator)



## Tags

| Tag | Architecture | Description |
| :----: | :----: |--- |
| [`latest`, `fc43`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile) | amd64 | Create a Spotify package for the latest stable version of Fedora. |
| [`fc-previous`, `fc42`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-fc-previous) | amd64 | Create a Spotify package for the previous stable version of Fedora. |
| [`fc-beta`,`fc44`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-fc-beta) | amd64 | Create a Spotify package for Fedora Beta. |
| [`rawhide`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-fc-rawhide) | amd64 | Create a Spotify package for Fedora Rawhide. |
| [`el8`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-el8) | amd64 | Create a Spotify package for RHEL 8 derivatives |
| [`el9`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-el9) | amd64 | Create a Spotify package for RHEL 9 derivatives |
| [`el`, `el10`](https://github.com/zicstardust/RPM-Spotify-Package-Generator/blob/main/dockerfile-el10) | amd64 | Create a Spotify package for RHEL 10 derivatives |


## Usage
### docker-compose
```
services:
  spotify-rpm:
    container_name: rpm-spotify-package-generator
    image: zicstardust/rpm-spotify-package-generator:latest
    environment:
      TZ: America/New_York
      #INTERVAL: 1d
    #ports: #only if ENABLE_SERVER_REPO is enable
    #  - 80:80
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
| `ENABLE_SERVER_REPO` | Set `1` to enable web server repository | `0` |


## License

This project is a packaging script. Spotify is proprietary software owned by Spotify AB.