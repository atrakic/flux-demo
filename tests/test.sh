#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

HOST="${1:-static-sample.local}"
curl -fisk -H"Host: $HOST" -H "accept: application/json" -X GET "http://localhost"
