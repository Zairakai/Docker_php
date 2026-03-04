#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load "../helpers/common"

# =============================================================================
# DOCKER TARGETS - Validation des cibles Docker dans le Dockerfile
# =============================================================================

@test "Dockerfile defines all required targets" {
  run grep -q "AS base" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -q "AS prod" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -q "AS dev" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -q "AS test" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Production target copies correct configuration files" {
  run grep -q "COPY --chown=root:root config/prod/php.ini" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -q "COPY --chown=root:root config/prod/fpm.conf" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -q "COPY --chown=root:root config/prod/opcache.ini" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Development target copies correct configuration files" {
  run grep -q "COPY --chown=root:root config/dev/php.ini" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -q "COPY --chown=root:root config/dev/xdebug.ini" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Test target copies correct configuration files" {
  run grep -q "COPY --chown=root:root config/test/php.ini" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -q "COPY --chown=root:root config/test/pcov.ini" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Production target runs as non-root user" {
  run grep -B3 "# STAGE 2" "${PROJECT_ROOT}/Dockerfile"
  [[ "$output" =~ "USER www" ]]
}

@test "Development target runs as non-root user" {
  run grep -B3 "# STAGE 3" "${PROJECT_ROOT}/Dockerfile"
  [[ "$output" =~ "USER www" ]]
}

@test "Test target runs as non-root user" {
  run bash -c 'tac "${PROJECT_ROOT}/Dockerfile" | head -1'
  [[ "$output" =~ "USER www" ]]
}

@test "Base target creates required directories" {
  run grep -A2 "adduser.*www" "${PROJECT_ROOT}/Dockerfile"
  [[ "$output" =~ "/var/lib/php/sessions" ]]
}

@test "Base target copies essential scripts" {
  run grep -q "scripts/entrypoint.sh" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -q "scripts/healthcheck.sh" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Base target installs Composer" {
  run grep -q "COPY.*composer" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Base target has proper health check" {
  run grep -q "HEALTHCHECK" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -A1 "HEALTHCHECK" "${PROJECT_ROOT}/Dockerfile"
  [[ "$output" =~ healthcheck.sh ]]
}

@test "Base target exposes correct port" {
  run grep -q "EXPOSE 9000" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Base target sets correct working directory" {
  run grep -q "WORKDIR /var/www/html" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Base target has proper labels" {
  run grep -q "LABEL maintainer" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -q "org.opencontainers.image.source" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]

  run grep -q "org.opencontainers.image.licenses" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}
