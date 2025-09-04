import re
import os
ssh_config_path = os.path.expanduser("~/.ssh/config")
goto_config_path = os.path.expanduser("~/.config/goto/hosts.yml")
try:
    with open(ssh_config_path, "r") as ssh_config_file:
        ssh_config_content = ssh_config_file.read()
except FileNotFoundError:
    print(f"Файл конфигурации SSH не найден по пути {ssh_config_path}")
    exit(1)
host_block_regex = re.compile(r"(Host\s+\S+(?:\n\s+\w+\s+.+)*)", re.M)
hosts = host_block_regex.findall(ssh_config_content)
goto_config_content = []
for host_block in hosts:
    lines = host_block.strip().split("\n")
    if lines:
        alias_line = lines[0]
        alias_match = re.match(r"Host\s+(\S+)", alias_line)
        if alias_match:
            alias_name = alias_match.group(1)
            current_host = {"title": alias_name}
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
            goto_config_content.append("  - host:")
            for key, value in current_host.items():
                goto_config_content.append(f"      {key}: {value}")
            goto_config_content.append("")  # Добавляем пустую строку после каждого блока
try:
    with open(goto_config_path, "w") as goto_config_file:
        goto_config_file.write("\n".join(goto_config_content) + "\n")  # Добавляем конечный перевод строки
    print(f"Алиасы успешно перенесены из {ssh_config_path} в {goto_config_path}")
except Exception as e:
    print(f"Ошибка записи в файл конфигурации Goto: {e}")
    exit(1)
