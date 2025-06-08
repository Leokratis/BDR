#!/bin/bash
# Simple script to test the Blood Donation Registry API using curl.

BASE_URL="https://service.blooddonorregistry.gr/v2"
TOKEN="$1"

if [ -z "$TOKEN" ]; then
  echo "Usage: $0 <X-Auth-Token>" >&2
  exit 1
fi

set -e

echo "Testing captcha endpoint..."
curl -s "$BASE_URL/captcha" | head -c 200 && echo -e "\n"

echo "Testing donations endpoint..."
curl -s -H "X-Auth-Token: $TOKEN" "$BASE_URL/donations" | head -c 200 && echo -e "\n"

echo "Testing coverages endpoint..."
curl -s -H "X-Auth-Token: $TOKEN" "$BASE_URL/coverages" | head -c 200 && echo -e "\n"
