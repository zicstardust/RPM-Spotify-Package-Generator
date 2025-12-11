import dnf, json, os
db = dnf.dnf.Base()
data = json.loads(json.dumps(db.conf.substitutions, indent=2))

releasever = data['releasever']

os.makedirs(f"/data/{releasever}/x86_64/stable", exist_ok=True)
os.system(f'cp -Rf /home/spotify/rpmbuild/RPMS/x86_64/* /data/{releasever}/x86_64/stable/Packages/')
