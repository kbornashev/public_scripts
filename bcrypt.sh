#!/bin/bash
echo -n "Введите пароль: "
read -s password
echo
hashed_password=$(python -c "import bcrypt; print(bcrypt.hashpw('$password'.encode('utf-8'), bcrypt.gensalt()).decode('utf-8'))")
echo "Хэшированный пароль: $hashed_password"
