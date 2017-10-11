#!/usr/bin/env bash

if
  [ "${COMMAND:0:4}" == "bash" ]
then
  figlet ${BINARY_NAME}
  printf "%-15s %s\n" "Project:" "${PROJECT_NAME}"
  printf "%-15s %s\n" "Environment:" "${PROJECT_ENVIRONMENT}"
  echo ""

  # display additional information
  echo "* Monitoring:"
  printf "%-15s %s\n" "  - Kibana:" "http://${CONTROL_NODE}:5601/"
  printf "%-15s %s\n" "  - ElasticSearch:" "http://${CONTROL_NODE}:9200/"
  printf "%-15s %s\n" "  - Grafana:" "https://grafana.${LOCAL_DOMAIN_DC}.${LOCAL_DOMAIN}/"

  echo "* Service Discovery:"
  printf "%-15s %s\n" "  - Consul:" "https://${CONTROL_NODE}:8500/ui/"
  printf "%-15s %s\n" "  - Consul DNS:" "${CONTROL_NODE}:8600"
  printf "%-15s %s\n" "  - DNSMasq DNS:" "${CONTROL_NODE}:53"

  echo "* Load Balancing"
  printf "%-15s %s\n" "  - Traefik:" "https://${EDGE_NODE}:8080"

  if
      [ ! -z "${VAULT_TOKEN}" ]
  then
      echo "* Security"
      printf "%-15s %s\n" "  - Vault:" "${VAULT_ADDR}"
  fi

  echo ""
fi
