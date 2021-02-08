#!/bin/bash

#
# syncrclone.sh is a simple wrapper for rclone
# takes a shell file as a config for a remote and action
#

main() {
  RCLONE=$(which rclone)

  if [ -z ${RCLONE} ]
  then
    echo "Cannot find rclone."
    exit 1
  fi

  if [ $# -lt 1 ]
  then
    usage
    exit 1
  fi

  if [ ! -f ${1} ]
  then
    echo "Cannot find configfile ${1}."
    exit 1
  fi

  . ${1}
  err=$?
  if [ $err -gt 0 ]
  then
    echo "Something wrong sourcing ${1}. Error code: ${err}."
    exit 1
  else
    echo "File ${1} sourced."
  fi

  ${RCLONE} lsd ${REMOTE}:
  if [ $? -gt 0 ]
  then
    echo "Something was wrong with the remote ${REMOTE}."
    exit 1
  fi

  ${RCLONE} \
    --log-level=INFO \
    --log-file=${LOGFILE} \
    ${OPTS} \
    ${RCLONECMD} ${SOURCE} ${DEST}
}

usage () {
  echo ""
  echo "Usage:"
  echo " ${0} configfile"
  echo ""
}

main $@
