import os
import configparser
from pathlib import Path
ssh_config_path = Path.home() / ".ssh" / "config"
goto_config_path = Path.home() / "goto"
remmina_config_dir = Path.home() / "/home/bo/snap/remmina/6419/.local/share" / "remmina"
identity_file = str(Path.home() / ".ssh" / "id_rsa")
def parse_ssh_config(ssh_config_path):
    hosts = {}
    if not ssh_config_path.exists():
        return hosts
    with open(ssh_config_path, 'r') as file:
        lines = file.readlines()
        host = None
        for line in lines:
            line = line.strip()
            if line.startswith('Host '):
                if host:
                    hosts[host['Host']] = host
                host = {'Host': line.split()[1]}
            elif line.startswith('HostName ') and host:
                host['HostName'] = line.split()[1]
            elif line.startswith('User ') and host:
                host['User'] = line.split()[1]
        if host:
            hosts[host['Host']] = host
    return hosts
def parse_goto_config(goto_config_path):
    hosts = {}
    if not goto_config_path.exists():
        return hosts
    with open(goto_config_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            line = line.strip()
            if '=' in line:
                host, hostname = line.split('=', 1)
                hosts[host] = {'Host': host, 'HostName': hostname}
    return hosts
def parse_remmina_config(remmina_config_dir):
    hosts = {}
    if not remmina_config_dir.exists():
        return hosts
    for remmina_file in remmina_config_dir.glob("*.remmina"):
        config = configparser.ConfigParser()
        config.read(remmina_file)
        if 'remmina' in config and config['remmina'].get('protocol') == 'SSH':
            host = config['remmina']['name']
            hostname = config['remmina']['server']
            username = config['remmina'].get('username', '')
            hosts[host] = {'Host': host, 'HostName': hostname, 'User': username}
    return hosts
def update_ssh_config(ssh_config_path, hosts):
    with open(ssh_config_path, 'w') as file:
        for host in hosts.values():
            file.write(f"Host {host['Host']}\n")
            file.write(f"  HostName {host['HostName']}\n")
            if 'User' in host:
                file.write(f"  User {host['User']}\n")
            file.write("\n")
def update_goto_config(goto_config_path, hosts):
    with open(goto_config_path, 'w') as file:
        for host in hosts.values():
            file.write(f"{host['Host']}={host['HostName']}\n")
def update_remmina_config(remmina_config_dir, hosts, identity_file):
    remmina_config_dir.mkdir(parents=True, exist_ok=True)
    for host in hosts.values():
        config = configparser.ConfigParser()
        remmina_file = remmina_config_dir / f"{host['Host']}.remmina"
        config['remmina'] = {
            'name': host['Host'],
            'group': '',
            'server': host['HostName'],
            'protocol': 'SSH',
            'username': host.get('User', ''),
            'ssh_auth': '3',  # 3 означает аутентификацию с помощью ключа
            'ssh_privatekey': identity_file,
        }
        with open(remmina_file, 'w') as configfile:
            config.write(configfile)
def main():
    ssh_hosts = parse_ssh_config(ssh_config_path)
    goto_hosts = parse_goto_config(goto_config_path)
    remmina_hosts = parse_remmina_config(remmina_config_dir)

    all_hosts = {**ssh_hosts, **goto_hosts, **remmina_hosts}
    update_ssh_config(ssh_config_path, all_hosts)
    update_goto_config(goto_config_path, all_hosts)
    update_remmina_config(remmina_config_dir, all_hosts, identity_file)
    print("Synchronization complete!")
if __name__ == "__main__":
    main()
