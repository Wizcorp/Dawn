if
    [ ! -f ./inventory ]
then
    echo "You must first run Vagrant locally!"
    exit 1
fi

ln -s ${DAWN_ENVIRONMENT_FILES_PATH}/inventory /etc/ansible/hosts

cat << EOF
* Docker Swarm:
  - Leader-1: 10.0.0.50:2376
  - Worker-1: 10.0.0.100:2376
  - Worker-2: 10.0.0.101:2376
  - Balancer: 10.0.0.200:2376
* Monitoring:
  - Kibana: http://10.0.0.20:5601/
  - ElasticSearch: http://10.0.0.20:9200/
  - Grafana: http://10.0.0.20:3000/ (admin:admin)
* Service Discovery:
  - Consul: http://10.0.0.20:8500/ui/
  - Consul DNS: 10.0.0.20:8600
  - DNSMasq DNS: 10.0.0.20:53
* Load Balancing:
  - Traefik: http://10.0.0.200
EOF
