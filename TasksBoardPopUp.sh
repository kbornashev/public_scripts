#!/bin/bash
APP_CLASS="crx_ffpdhnednbmelagcknnegjemgooenfml.Google-chrome"
APP_WINDOW=$(wmctrl -lx | grep "$APP_CLASS")
if [ -n "$APP_WINDOW" ]; then

    APP_WIN_ID=$(echo $APP_WINDOW | awk '{print $1}')

    while true; do

        ACTIVE_WIN_ID=$(xdotool getactivewindow)

        if [ "$ACTIVE_WIN_ID" != "$APP_WIN_ID" ]; then
            wmctrl -ic "$APP_WIN_ID"
            break
        fi

        sleep 0.1
    done
fi
