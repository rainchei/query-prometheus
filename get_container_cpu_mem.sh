#!/bin/bash

# prometheus sub-queries:
# https://prometheus.io/blog/2019/01/28/subquery-support/

SERVER_URL="$1"
C_NAME="$2"

# usage
if [ -z ${SERVER_URL} ] || [ -z ${C_NAME} ]; then
  echo "Usage: $0 <<prometheus_server>> <<container_name>>"
  echo ""
  echo "Example:"
  echo "$0 http://localhost:9090 foo"
  echo ""
  exit 1;
fi

# cpu
QUERY_MAX_CPU='max_over_time(sum by (container) (rate(container_cpu_usage_seconds_total{container="'$C_NAME'"}[5m])) [1d:1m]) * 1000'
MAX_CPU=$(python3 query-prometheus.py -s "$SERVER_URL" -q "$QUERY_MAX_CPU")

# memory
QUERY_MAX_MEMORY='max_over_time( container_memory_working_set_bytes{container="'$C_NAME'"} [1d:1m]) / 1024^2'
MAX_MEM=$(python3 query-prometheus.py -s "$SERVER_URL" -q "$QUERY_MAX_MEMORY")

RESULT='{ "container": "'$C_NAME'", "cpu": "'$MAX_CPU'", "memory": "'$MAX_MEM'" }'
echo $RESULT | jq .
