import os
import configparser
ssh_config_path = os.path.expanduser("~/.ssh/config")
remmina_config_path = os.path.expanduser("~/.local/share/remmina/")
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
def update_remmina_profile(hostname, config):
    profile_filename = os.path.join(remmina_config_path, f"{hostname}.remmina")
    profile = configparser.ConfigParser()

    if os.path.exists(profile_filename):
        profile.read(profile_filename)

    if 'remmina' not in profile:
        profile['remmina'] = {}
    profile['remmina']['protocol'] = 'SSH'
    profile['remmina']['name'] = hostname
    profile['remmina']['server'] = config.get('HostName', hostname)
    profile['remmina']['port'] = config.get('Port', '22')
    profile['remmina']['username'] = config.get('User', os.getenv('USER'))
    profile['remmina']['password'] = profile['remmina'].get('password', '')  # Сохраните существующий пароль, если он есть
    profile['remmina']['group'] = profile['remmina'].get('group', '')        # Сохраните существующую группу, если она есть

    if 'IdentityFile' in config:
        profile['remmina']['ssh_auth'] = '2'  # Использовать ключ
        profile['remmina']['ssh_privatekey'] = config['IdentityFile']
    else:
        profile['remmina']['ssh_auth'] = '2'  # Использовать ключ по умолчанию
        profile['remmina']['ssh_privatekey'] = '~/.ssh/id_rsa'
    with open(profile_filename, 'w') as configfile:
        profile.write(configfile)
hosts = parse_ssh_config(ssh_config_path)
for hostname, config in hosts.items():
    update_remmina_profile(hostname, config)
print("Profiles updated successfully.")
