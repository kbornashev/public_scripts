#!/bin/bash
APP_CLASS="crx_ffpdhnednbmelagcknnegjemgooenfml.Google-chrome"
APP_WINDOW=$(wmctrl -lx | grep "$APP_CLASS")
if [ -n "$APP_WINDOW" ]; then

    APP_WIN_ID=$(echo $APP_WINDOW | awk '{print $1}')
    wmctrl -ia $APP_WIN_ID
else

    /opt/google/chrome/google-chrome "--profile-directory=Profile 1" --app-id=ffpdhnednbmelagcknnegjemgooenfml &
fi
