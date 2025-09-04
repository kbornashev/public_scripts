import socket
import requests
def check_domain(domain):
    try:

        ip = socket.gethostbyname(domain)
        return True  # Домен доступен
    except socket.error:
        return False  # Домен недоступен
def check_website(domain):
    try:

        http_response = requests.get(f"http://{domain}", timeout=5)
        https_response = requests.get(f"https://{domain}", timeout=5)

        if http_response.status_code == 200 or https_response.status_code == 200:
            return True
        else:
            return False
    except requests.RequestException:
        return False
def check_and_update_domains(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
    updated_lines = []
    for line in lines:
        domain = line.strip()

        if not domain or domain.startswith('#'):
            updated_lines.append(line)
            continue
        if check_domain(domain) and check_website(domain):
            print(f"{domain} is reachable and the website is accessible")
            updated_lines.append(line)
        else:
            print(f"{domain} is not reachable or the website is not accessible and will be removed")

            updated_lines.append('\n')

    with open(file_path, 'w') as file:
        file.writelines(updated_lines)
file_path = '/home/bo/Optimacros_ssl_list.md'
check_and_update_domains(file_path)
