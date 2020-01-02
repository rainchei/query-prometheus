#!/bin/bash

# prometheus sub-queries:
# https://prometheus.io/blog/2019/01/28/subquery-support/

function main () {
  SERVER_URL="$1"
  C_NAME="$2"
  TIME="$3"

  # usage
  if [ -z $SERVER_URL ] || [ -z $C_NAME ] || [ -z $TIME ]; then
    echo "Usage: $0 <<prometheus_server>> <<container_name>> <<time>>"
    echo ""
    echo "Example:"
    echo "$0 http://localhost:9090 foo 2020-01-01T00:00:00.000Z"
    echo ""
    exit 1;
  fi

  # cpu
  QUERY_MAX_CPU='max_over_time(sum by (container) (rate(container_cpu_usage_seconds_total{container="'$C_NAME'"}[5m])) [1d:1m]) * 1000'
  MAX_CPU=$(python3 query-prometheus.py -s "$SERVER_URL" -q "$QUERY_MAX_CPU" -t "$TIME")
  R_CPU="$(round $MAX_CPU 0)m"

  # memory
  QUERY_MAX_MEMORY='max_over_time(sum by (container) (container_memory_working_set_bytes{container="'$C_NAME'"}) [1d:1m]) / 1024^2'
  MAX_MEM=$(python3 query-prometheus.py -s "$SERVER_URL" -q "$QUERY_MAX_MEMORY" -t "$TIME")
  R_MEM="$(round $MAX_MEM 0)Mi"

  RESULT='{ "container": "'$C_NAME'", "cpu": "'$R_CPU'", "memory": "'$R_MEM'" }'
  echo $RESULT | jq .
}

function round () {
  printf "%.$2f" "$1"
}


# run main func
main "$1" "$2" "$3"
