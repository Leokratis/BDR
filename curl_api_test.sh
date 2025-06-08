#!/bin/bash
# Simple script to test the Blood Donation Registry API using curl.

BASE_URL="https://service.bdr.gr/blood-donor-registry-web-public/rest"
TOKEN="$1"
USER_ID="$2"

if [ -z "$TOKEN" ] || [ -z "$USER_ID" ]; then
  echo "Usage: $0 <X-Auth-Token> <userId>" >&2
  exit 1
fi

set -e

echo "Testing captcha endpoint..."
curl -s "$BASE_URL/captcha" | head -c 200 && echo -e "\n"

echo "Testing donations endpoint..."
curl -s -H "X-Auth-Token: $TOKEN" \
  "$BASE_URL/blooddonor/$USER_ID/donation/history" | head -c 200 && echo -e "\n"

echo "Testing coverages endpoint..."
curl -s -H "X-Auth-Token: $TOKEN" \
  "$BASE_URL/blooddonor/$USER_ID/coverageDonation/history" | head -c 200 && echo -e "\n"
