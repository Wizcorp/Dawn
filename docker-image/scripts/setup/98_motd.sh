#!/usr/bin/env bash

if
  [ "${COMMAND:0:4}" == "bash" ]
then
  cat /etc/motd

  echo ""
  printf "%-10s %s\n" "Project:" "${DAWN_PROJECT_NAME}"
  printf "%-10s %s\n" "Environment:" "${DAWN_ENVIRONMENT}"
  echo ""
fi
