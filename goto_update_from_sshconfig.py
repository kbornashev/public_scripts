import re
import os
ssh_config_path = os.path.expanduser("~/.ssh/config")
goto_config_path = os.path.expanduser("~/.config/goto/hosts.yaml")
try:
    with open(ssh_config_path, "r") as ssh_config_file:
        ssh_config_content = ssh_config_file.read()
except FileNotFoundError:
    print(f"Файл конфигурации SSH не найден по пути {ssh_config_path}")
    exit(1)
host_block_regex = re.compile(r"(Host\s+\S+(?:\n\s+\w+\s+.+)*)", re.M)
hosts = host_block_regex.findall(ssh_config_content)
if os.path.exists(goto_config_path):
    try:
        with open(goto_config_path, "r") as goto_config_file:
            goto_config_content = goto_config_file.read()
    except Exception as e:
        print(f"Ошибка чтения файла конфигурации Goto: {e}")
        exit(1)
else:
    goto_config_content = ""
goto_config_blocks = goto_config_content.strip().split("\n\n")
current_goto_config = {}
for block in goto_config_blocks:
    lines = block.strip().split("\n")
    if lines:
        title = lines[0].strip().split(":")[1].strip()
        host_details = {}
        for line in lines[1:]:
            key, value = line.strip().split(":")
            host_details[key.strip()] = value.strip()
        current_goto_config[title] = host_details
updated_goto_config = []
for host_block in hosts:
    lines = host_block.strip().split("\n")
    if lines:
        alias_line = lines[0]
        alias_match = re.match(r"Host\s+(\S+)", alias_line)
        if alias_match:
            alias_name = alias_match.group(1)
            current_host = {
                "address": None,
                "network_port": None,
                "username": None
            }
            for line in lines[1:]:
                key_value_match = re.match(r"\s*(\w+)\s+(.+)", line)
                if key_value_match:
                    key, value = key_value_match.groups()
                    if key.lower() == "hostname":
                        current_host["address"] = value
                    elif key.lower() == "port":
                        current_host["network_port"] = value
                    elif key.lower() == "user":
                        current_host["username"] = value

            if alias_name in current_goto_config:

                updated_host = current_goto_config[alias_name]
                updated_host.update(current_host)
                updated_goto_config.append(f"  - host:")
                for key, value in updated_host.items():
                    updated_goto_config.append(f"      {key}: {value}")
            else:

                updated_goto_config.append(f"  - host:")
                updated_goto_config.append(f"      title: {alias_name}")
                for key, value in current_host.items():
                    updated_goto_config.append(f"      {key}: {value}")
try:
    with open(goto_config_path, "w") as goto_config_file:
        goto_config_file.write("\n".join(updated_goto_config) + "\n")  # Добавляем конечный перевод строки
    print(f"Алиасы успешно перенесены из {ssh_config_path} в {goto_config_path}")
except Exception as e:
    print(f"Ошибка записи в файл конфигурации Goto: {e}")
    exit(1)
