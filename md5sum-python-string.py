import hashlib, getpass; print(hashlib.md5(getpass.getpass('Введите строку: ').encode()).hexdigest())
