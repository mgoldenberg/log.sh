#!/usr/bin/env bash

set -o nounset

# TODO: verify log levels set in environment variables (in init function maybe?)
# TODO: add NONE option to turn off logging

export LOG_LEVEL_STDERR="${LOG_LEVEL_STDERR:-"ERROR"}"
export LOG_LEVEL_FILE="${LOG_LEVEL_FILE:-"DEBUG"}"
export LOG_LEVEL_DEFAULT="${LOG_LEVEL_DEFAULT:-"INFO"}"

declare -A LOG_LEVEL
LOG_LEVEL[ERROR]=0
LOG_LEVEL[WARN]=1
LOG_LEVEL[INFO]=2
LOG_LEVEL[DEBUG]=3
LOG_LEVEL[TRACE]=4

export LOG_DIRNAME="${LOG_DIRNAME:-"."}"
export LOG_FILENAME="${LOG_FILENAME:-"experiment.log"}"
export LOG_PATH="${LOG_PATH:-"${LOG_DIRNAME}/${LOG_FILENAME}"}"

log_init () {
    echo -n &> "${LOG_PATH}"
    echo "initializing log (path=${LOG_PATH}) ... " | LOG_CALLER="$(caller 0)" log
}

log () {
    local timestamp="$(date --utc --iso-8601=ns)"
    local level="${1:-"${LOG_LEVEL_DEFAULT}"}"
    read -r lineno function file <<< "${LOG_CALLER:-"$(caller 0)"}"
    while read -r message; do
        local line="[${timestamp} ${level} (pid=${$}) ${file}:${function}:${lineno}] ${message}"
        [[ ${LOG_LEVEL[${LOG_LEVEL_STDERR^^}]} -ge ${LOG_LEVEL[${level^^}]} ]] &&
            echo "${line}" 1>&2
        [[ ${LOG_LEVEL[${LOG_LEVEL_FILE^^}]}   -ge ${LOG_LEVEL[${level^^}]} ]] &&
            echo "${line}" >> "${LOG_PATH}"
    done
}

log_error () { LOG_CALLER="$(caller 0)" log "ERROR"; }
log_warn  () { LOG_CALLER="$(caller 0)" log "WARN";  }
log_info  () { LOG_CALLER="$(caller 0)" log "INFO";  }
log_debug () { LOG_CALLER="$(caller 0)" log "DEBUG"; }
log_trace () { LOG_CALLER="$(caller 0)" log "TRACE"; }
