#!/bin/bash
function getvariables () {
  VARIABLE=$2
  variable=${VARIABLE}
  read -p "$1: (${VARIABLE}): " VARIABLE
  local VARIABLE=${VARIABLE:-$variable}
  echo ${VARIABLE}
}
LOGIN="One"
export LOGIN="$(getvariables "test" ${LOGIN})"
#export $LOGIN
echo $LOGIN
