#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

HOST="${1:-httpbin.local}"

curl -fisk -H"Host: $HOST" -H "accept: application/json" -X GET "http://localhost/get"
curl -fisk -H"Host: $HOST" -H "accept: application/json" -X GET "http://localhost/headers"
curl -fisk -H"Host: $HOST" -H "accept: application/json" -X PATCH "http://localhost/patch"
curl -fisk -H"Host: $HOST" -H "accept: application/json" -X POST "http://localhost/post"
curl -fisk -H"Host: $HOST" -H "accept: application/json" -X PUT "http://localhost/put"
