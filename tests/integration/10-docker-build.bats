#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load "../helpers/common"

# =============================================================================
# DOCKERFILE - Structure et bonnes pratiques
# =============================================================================

@test "Dockerfile exists at repository root" {
  [[ -f "${PROJECT_ROOT}/Dockerfile" ]]
}

@test "Dockerfile copies healthcheck.sh to /usr/local/bin" {
  run grep -q "COPY.*healthcheck.sh /usr/local/bin/healthcheck.sh" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Dockerfile sets execute permissions on scripts" {
  run grep -q "chmod +x /usr/local/bin/\*.sh" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Dockerfile defines HEALTHCHECK instruction" {
  run grep -q "HEALTHCHECK" "${PROJECT_ROOT}/Dockerfile"
  [[ "$status" -eq 0 ]]
}

@test "Dockerfile HEALTHCHECK uses healthcheck.sh" {
  run grep -A1 "HEALTHCHECK" "${PROJECT_ROOT}/Dockerfile"
  [[ "$output" =~ healthcheck.sh ]]
}
