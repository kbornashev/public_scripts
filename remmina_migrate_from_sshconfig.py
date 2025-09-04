import os
import configparser
ssh_config_path = os.path.expanduser("~/.ssh/config")
remmina_config_path = os.path.expanduser("/home/bo/snap/remmina/6419/.local/share/remmina")
if not os.path.exists(remmina_config_path):
    os.makedirs(remmina_config_path)
def parse_ssh_config(file_path):
    with open(file_path) as f:
        content = f.readlines()
    hosts = {}
    current_host = None
    for line in content:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if line.startswith("Host "):
            current_host = line.split()[1]
            hosts[current_host] = {}
        elif current_host:
            parts = line.split(None, 1)
            if len(parts) == 2:
                key, value = parts
                hosts[current_host][key] = value
    return hosts
def create_remmina_profile(hostname, config):
    profile = configparser.ConfigParser()
    profile['remmina'] = {
        'protocol': 'SSH',
        'name': hostname,
        'server': config.get('HostName', hostname),
        'port': config.get('Port', '22'),
        'username': config.get('User', os.getenv('USER')),
        'password': '',
        'group': '',
        'ssh_auth': '0',
        'ssh_privatekey': config.get('IdentityFile', '')
    }
    profile_filename = os.path.join(remmina_config_path, f"{hostname}.remmina")
    with open(profile_filename, 'w') as configfile:
        profile.write(configfile)
hosts = parse_ssh_config(ssh_config_path)
for hostname, config in hosts.items():
    create_remmina_profile(hostname, config)
print("Profiles created successfully.")
