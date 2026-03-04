#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load "../helpers/common"

# =============================================================================
# HEALTHCHECK.SH - Validation du script de healthcheck Docker
# =============================================================================

@test "healthcheck.sh exists and is executable" {
  [[ -f "${PROJECT_ROOT}/scripts/healthcheck.sh" ]]
  [[ -x "${PROJECT_ROOT}/scripts/healthcheck.sh" ]]
}

@test "healthcheck.sh has valid bash shebang" {
  run head -1 "${PROJECT_ROOT}/scripts/healthcheck.sh"
  [[ "$output" =~ ^#!/bin/bash ]]
}

@test "healthcheck.sh uses strict error handling" {
  run grep -q "set -e" "${PROJECT_ROOT}/scripts/healthcheck.sh"
  [[ "$status" -eq 0 ]]
}
