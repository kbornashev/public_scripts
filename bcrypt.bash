#!/bin/bash

# Спрашиваем пароль без отображения на экране
echo -n "Введите пароль: "
read -s password
echo

# Запускаем скрипт Python для хэширования пароля
hashed_password=$(python3 -c "import bcrypt; print(bcrypt.hashpw('$password'.encode('utf-8'), bcrypt.gensalt(4)).decode('utf-8'))")

# Теперь можно использовать переменную $hashed_password для сохранения в базе данных или других целях
echo "Хэшированный пароль: $hashed_password"

