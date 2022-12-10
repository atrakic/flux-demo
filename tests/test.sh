#!/usr/bin/env bash
set -o errexit
curl -f -i -skX GET "localhost" -o /dev/null -H"Host: httpbin.local" && echo "ok: httpbin.local"
