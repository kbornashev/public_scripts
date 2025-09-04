import ipaddress
def get_ip_addresses():

    subnet_str = input("subnet (0.0.0.0/0): ")
    try:

        subnet = ipaddress.IPv4Network(subnet_str, strict=False)
    except ValueError:
        print("Ошибка: Неверный формат подсети.")
        return

    for ip in subnet.hosts():
        print(ip)
if __name__ == "__main__":
    get_ip_addresses()
