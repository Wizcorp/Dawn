#!/usr/bin/env bash

if
  [ "${COMMAND:0:4}" == "bash" ]
then
  figlet ${BINARY_NAME}
  printf "%-15s %s\n" "Project:" "${PROJECT_NAME}"
  printf "%-15s %s\n" "Environment:" "${PROJECT_ENVIRONMENT}"
  echo ""
fi
