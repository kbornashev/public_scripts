import sys
import ssl
import socket
from datetime import datetime, timedelta
import OpenSSL.crypto as crypto
def get_cert_dates(hostname):
    try:
        context = ssl.create_default_context()
        with socket.create_connection((hostname, 443)) as sock:
            with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                cert = ssock.getpeercert(binary_form=True)
                x509 = crypto.load_certificate(crypto.FILETYPE_ASN1, cert)
                start_date = datetime.strptime(x509.get_notBefore().decode('utf-8'), '%Y%m%d%H%M%SZ')
                expiry_date = datetime.strptime(x509.get_notAfter().decode('utf-8'), '%Y%m%d%H%M%SZ')
                return start_date, expiry_date
    except ssl.SSLError as e:
        if 'certificate has expired' in str(e):
            return datetime.utcnow(), datetime.utcnow()  # Для просроченного сертификата возвращаем текущую дату
        else:
            return None, None
    except socket.gaierror as e:
        return None, None
    except Exception as e:
        raise e
def print_colored_date(date, expired=False):
    if expired:
        print(f"\033[91m{date}\033[0m")
    else:
        print(f"\033[92m{date}\033[0m")
def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py <domain_list_file>")
        return
    filename = sys.argv[1]
    with open(filename, 'r') as file:
        domains = file.readlines()
    for domain in domains:
        domain = domain.strip()
        start_date, expiry_date = get_cert_dates(domain)
        if start_date and expiry_date:
            today = datetime.utcnow()
            expiry_warning_date = today + timedelta(days=30)
            print(f"Site: {domain}")
            print("Start Date:", end=" ")
            if start_date < today:
                print_colored_date(start_date)
            else:
                print_colored_date(start_date, expired=True)
            print()
            print("Expiry Date:", end=" ")
            if expiry_date > expiry_warning_date:
                print_colored_date(expiry_date)
            else:
                print_colored_date(expiry_date, expired=True)
            print()
        else:
            print_colored_date(f"Error occurred while fetching SSL certificate for {domain}: {e}", expired=True)
            print(f"{domain} error")
            print()
if __name__ == "__main__":
    main()
