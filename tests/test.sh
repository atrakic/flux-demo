#!/usr/bin/env bash
set -o errexit
curl -f -i -sk -H"Host: httpbin.local" -H "accept: application/json" -X GET "http://localhost/get"
curl -f -i -sk -H"Host: httpbin.local" -H "accept: application/json" -X GET "http://localhost/headers"

curl -f -i -sk -H"Host: httpbin.local" -H "accept: application/json" -X PATCH "http://localhost/patch"
curl -f -i -sk -H"Host: httpbin.local" -H "accept: application/json" -X POST "http://localhost/post"
curl -f -i -sk -H"Host: httpbin.local" -H "accept: application/json" -X PUT "http://localhost/put"
