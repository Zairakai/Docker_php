#!/bin/bash

# Simple health check script for dockers/php
set -euo pipefail

# Health check
if curl -f -s "http://localhost:9000/ping" >/dev/null; then
    echo "✅ Health check passed"
    exit 0
else
    echo "❌ Health check failed"
    exit 1
fi
