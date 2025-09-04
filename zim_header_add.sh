#!/bin/bash
directory="/home/bo/test"
add_zim_header() {
    local file_path="$1"

    creation_date=$(date -r "$file_path" +"%Y-%m-%dT%H:%M:%S%z")

    header="Content-Type: text/x-zim-wiki\nWiki-Format: zim 0.4\nCreation-Date: $creation_date\n"

    temp_file=$(mktemp)
    echo -e "$header" > "$temp_file"
    cat "$file_path" >> "$temp_file"

    mv "$temp_file" "$file_path"
}
for file in "$directory"/*.txt "$directory"/*.md; do
    if [ -f "$file" ]; then
        add_zim_header "$file"
    fi
done
