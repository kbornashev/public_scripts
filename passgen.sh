read -p "len: " len; pwgen -s $len 1 | tr -d "\n" | xsel --clipboard
