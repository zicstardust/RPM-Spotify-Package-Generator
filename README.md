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
    ports:
      - 80:80
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
| `DISABLE_WEB_SERVER` | Set `1` to disable web server repository | `0` |


## Repository Web Server

## On client

Exemple `/etc/yum.repos.d/spotify.repo` file
```
[spotify]
name=Spotify - $releasever
baseurl=http://127.0.0.1/$releasever/$basearch/stable
enabled=1
gpgcheck=0
#gpgkey=http://127.0.0.1/gpg
```
Install:
```
sudo dnf install spotify-client
```

## Multiple release repository
Example of a single web server for FC 42, 43, 44 and EL 9.
```
services:
  fc42:
    container_name: spotify-fc42-releases
    image: zicstardust/rpm-spotify-package-generator:fc42
    environment:
      TZ: America/New_York
    ports:
      - 80:80
    volumes:
      - <path to RPMs output>:/data
  fc43:
    container_name: spotify-fc43-releases
    image: zicstardust/rpm-spotify-package-generator:fc43
    environment:
      TZ: America/New_York
      DISABLE_WEB_SERVER: 1
    volumes:
      - <same path to RPMs output>:/data
  fc44:
    container_name: spotify-fc44-releases
    image: zicstardust/rpm-spotify-package-generator:fc44
    environment:
      TZ: America/New_York
      DISABLE_WEB_SERVER: 1
    volumes:
      - <same path to RPMs output>:/data
  el9:
    container_name: spotify-el9-releases
    image: zicstardust/rpm-spotify-package-generator:el9
    environment:
      TZ: America/New_York
      DISABLE_WEB_SERVER: 1
    volumes:
      - <same path to RPMs output>:/data
```






## License

This project is a packaging script. Spotify is proprietary software owned by Spotify AB.