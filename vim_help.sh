#!/bin/bash
read file
if [[ -z $file ]]
then
				gnome-terminal -- bash -c "vim /home/bo/om/{$file}; exec bash -i"
fi
