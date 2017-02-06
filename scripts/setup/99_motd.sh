#!/usr/bin/env bash

cat /etc/motd

echo ""
printf "%-10s %s\n" "Project:" "${DAWN_PROJECT_NAME}"
printf "%-10s %s\n" "Environment:" "${DAWN_ENVIRONMENT}"
printf "%-10s %s\n" "Dashboard:" "${DAWN_ENVIRONMENT_DASHBOARD_URL}"
echo ""