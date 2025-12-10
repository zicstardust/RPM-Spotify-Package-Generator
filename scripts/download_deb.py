from urllib import request


def download_deb_control_file(filename):
    request.urlretrieve("https://repository.spotify.com/dists/testing/non-free/binary-amd64/Packages", f'/build/{filename}')
    return filename



def parse_deb_control_file(path):
    data = {}
    
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            if ": " in line:
                key, value = line.split(": ", 1)

                if key in ("Depends", "Recommends", "Suggests"):
                    parts = [p.strip() for p in value.replace("|", ",").split(",")]
                    data[key] = [p for p in parts if p]
                elif key in ("Size",):
                    data[key] = int(value)
                else:
                    data[key] = value

    return data


def download_deb(url):
    request.urlretrieve(f'https://repository.spotify.com/{url}', f'{url.replace('pool/non-free/s/spotify-client/', '/build/')}')


if __name__ == "__main__":
    file = download_deb_control_file('spotify.info')
    result = parse_deb_control_file(file)

    download_deb(result['Filename'])

    #print(result['Filename'])
    #print(result['Version'])
