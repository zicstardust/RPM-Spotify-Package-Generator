import os
import shutil
from datetime import datetime
from download_deb import parse_deb_control_file

result = parse_deb_control_file('/build/spotify.info')
spotify_version = result['Version'].replace('1:', '')

deb_file = f'/build/spotify-client_{spotify_version}_amd64.deb'


BUILD_DIR = "/root/rpmbuild"


# Create directory structure for rpmbuild
print('Create directory structure for rpmbuild')
os.mkdir(BUILD_DIR)
os.mkdir(f'{BUILD_DIR}/BUILD')
os.mkdir(f'{BUILD_DIR}/RPMS')
os.mkdir(f'{BUILD_DIR}/SOURCES')
os.mkdir(f'{BUILD_DIR}/SPECS')
os.mkdir(f'{BUILD_DIR}/SRPMS')


# Copy .deb to SOURCES
shutil.copy(deb_file, f'{BUILD_DIR}/SOURCES')

# Extract .deb manually
print('Extract .deb')
os.system(f'ar x {deb_file}')
os.system('tar xf /build/data.tar.gz')



# Create installation directory
INSTALL_DIR = f"{BUILD_DIR}/BUILD/spotify-{spotify_version}/BUILDROOT"

os.makedirs (f'{INSTALL_DIR}/usr/bin', exist_ok=True)
os.makedirs (f'{INSTALL_DIR}/usr/share/spotify', exist_ok=True)
os.makedirs (f'{INSTALL_DIR}/usr/share/applications', exist_ok=True)
os.makedirs (f'{INSTALL_DIR}/usr/share/icons/hicolor', exist_ok=True)
os.makedirs (f'{INSTALL_DIR}/usr/share/appdata', exist_ok=True)
os.makedirs (f'{INSTALL_DIR}/usr/share/man/man1', exist_ok=True)


# Copy Spotify files
os.system(f'cp -ar /build/usr/share/spotify/* "{INSTALL_DIR}/usr/share/spotify/"')


# Create launcher script
output_path = f"{INSTALL_DIR}/usr/bin/spotify"
content = """#!/usr/bin/bash
# Spotify launcher with Fedora fixes

# Disable hardware acceleration that causes black screen
export SPOTIFY_CLEAN_CACHE=1

# Flags to improve compatibility
exec /usr/share/spotify/spotify \\
    --disable-gpu-sandbox \\
    --disable-seccomp-filter-sandbox \\
    --no-zygote \\
    "$@"
"""

with open(output_path, "w", encoding="utf-8") as f:
    f.write(content)

os.chmod(output_path, 0o755)



# Create .desktop file
output_path = f"{INSTALL_DIR}/usr/share/applications/spotify.desktop"
content = f"""[Desktop Entry]
Type=Application
Name=Spotify
Version={spotify_version}
GenericName=Music Player
Comment=Spotify streaming music client
Icon=spotify
Exec=spotify %U
Terminal=false
MimeType=x-scheme-handler/spotify;
Categories=Audio;Music;Player;AudioVideo;
StartupWMClass=spotify
"""

with open(output_path, "w", encoding="utf-8") as f:
    f.write(content)


# Copy icons
for size in [16, 22, 24, 32, 48, 64, 128, 256, 512]:
    if os.path.isfile(f"/build/usr/share/spotify/icons/spotify-linux-{size}.png"):
        os.makedirs(f"{INSTALL_DIR}/usr/share/icons/hicolor/{size}x{size}/apps", exist_ok=True)
        shutil.copy(f"/build/usr/share/spotify/icons/spotify-linux-{size}.png", f"{INSTALL_DIR}/usr/share/icons/hicolor/{size}x{size}/apps/spotify.png")


# Create appdata.xml
output_path = f"{INSTALL_DIR}/usr/share/appdata/spotify.xml"
content = f"""<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop">
  <id>spotify.desktop</id>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>LicenseRef-proprietary</project_license>
  <name>Spotify</name>
  <summary>Online music streaming service</summary>
  <description>
    <p>Spotify is a digital music service that gives you access to millions of songs.</p>
  </description>
  <url type="homepage">https://www.spotify.com/</url>
</component>
"""

with open(output_path, "w", encoding="utf-8") as f:
    f.write(content)


#Create man page
output_path = f"{INSTALL_DIR}/usr/share/man/man1/spotify.1"
content = f""".TH SPOTIFY 1 "December 2025" "Spotify Client" "User Commands"
.SH NAME
spotify \\- Spotify streaming music client
.SH SYNOPSIS
.B spotify
[\\fIOPTIONS\\fR]
.SH DESCRIPTION
Spotify is a digital music service that gives you access to millions of songs.
.SH OPTIONS
.TP
\\fB\\-\\-help\\fR
Show help options
.SH SEE ALSO
https://www.spotify.com/
"""

with open(output_path, "w", encoding="utf-8") as f:
    f.write(content)



# Adjust library permissions
base_path = os.path.join(INSTALL_DIR, "usr/share/spotify")

for root, dirs, files in os.walk(base_path):
    for filename in files:
        if ".so" in filename:  # equivalente ao '*.so*'
            filepath = os.path.join(root, filename)
            os.chmod(filepath, 0o755)


# Generate spec file
print('Create spec file')
output_path = f"{BUILD_DIR}/SPECS/spotify.spec"
content = f"""%global debug_package %{{nil}}
%global __strip /bin/true

Name:           spotify
Version:        {spotify_version}
Release:        1%{{?dist}}
Summary:        Spotify desktop client
License:        Proprietary
URL:            https://www.spotify.com/

Requires:       libatomic
Requires:       libayatana-appindicator-gtk3

%description
Spotify is a digital music service that gives you access to millions of songs.

%install
mkdir -p %{{buildroot}}
cp -a {INSTALL_DIR}/* %{{buildroot}}/

%post
chmod -R a+wr %{{_datadir}}/spotify/ || true


%files
%{{_bindir}}/spotify
%{{_datadir}}/spotify/
%{{_datadir}}/applications/spotify.desktop
%{{_datadir}}/icons/hicolor/*/apps/spotify.png
%{{_datadir}}/appdata/spotify.xml
%{{_mandir}}/man1/spotify.1*

%changelog
* {datetime.now().strftime("%a %b %d %Y")} Automated Build <builder@localhost> - {spotify_version}-1
- Automated build of Spotify client {spotify_version}
"""

with open(output_path, "w", encoding="utf-8") as f:
    f.write(content)


#Delete trash files
#os.system(f"rm -Rf {INSTALL_DIR}/usr/share/spotify/icons")
os.system(f"rm -f {INSTALL_DIR}/usr/share/spotify/spotify.desktop")
os.system(f"rm -Rf {INSTALL_DIR}/usr/share/spotify/apt-keys")


# Build the RPM
print('Building the RPM...')
os.system(f"rpmbuild -bb --define \"_topdir {BUILD_DIR}\" {BUILD_DIR}/SPECS/spotify.spec 2>&1 | grep -E '(^Wrote:|^error:|^Error)' || true")