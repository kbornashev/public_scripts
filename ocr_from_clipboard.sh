#!/bin/bash
TMP_IMAGE="/tmp/clipboard_image.png"
xclip -selection clipboard -t image/png -o > "$TMP_IMAGE"
gimagereader-gtk "$TMP_IMAGE"
