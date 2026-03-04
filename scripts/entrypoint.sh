#!/bin/bash
set -e

echo "zairakai/php:${IMAGE_VERSION} (PHP $(php -v | head -n 1 | awk '{print $2}')) [${GIT_COMMIT:0:7}]"

exec "$@"
