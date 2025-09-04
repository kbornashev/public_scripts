#!/bin/bash
while getopts ":h:" opt; do
  case $opt in
    h)
      host="OPTARG"
      ;;
    \?)
      echo "invalid: -$OPTARG" >&2
      ;;
    :)
      echo "Option -$OPTARG requies an argument." >&2
      ;;
  esac
done
shift $((OPTIND-1))
ssh $host
