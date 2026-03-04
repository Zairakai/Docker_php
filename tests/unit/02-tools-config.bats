#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load "../helpers/common"

# =============================================================================
# CONFIG.SH - Configuration centralisée du tooling
# =============================================================================

@test "config.sh exists and is executable" {
  [[ -f "${PROJECT_ROOT}/tools/scripts/config.sh" ]]
  [[ -x "${PROJECT_ROOT}/tools/scripts/config.sh" ]]
}

@test "config.sh has valid bash shebang with env" {
  run head -1 "${PROJECT_ROOT}/tools/scripts/config.sh"
  [[ "$output" =~ ^#!/usr/bin/env\ bash ]]
}

@test "config.sh uses strict error handling with pipefail" {
  run grep -q "set -euo pipefail" "${PROJECT_ROOT}/tools/scripts/config.sh"
  [[ "$status" -eq 0 ]]
}

@test "config.sh can be sourced without errors" {
  run bash -c "PROJECT_ROOT='${PROJECT_ROOT}' source '${PROJECT_ROOT}/tools/scripts/config.sh'"
  [[ "$status" -eq 0 ]]
}

@test "config.sh defines color variables" {
  run bash -c "source '${PROJECT_ROOT}/tools/scripts/config.sh' && echo \$GREEN"
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ \\033 ]]
}

@test "config.sh defines log_info function" {
  run bash -c "source '${PROJECT_ROOT}/tools/scripts/config.sh' && declare -F log_info"
  [[ "$status" -eq 0 ]]
}

@test "config.sh defines log_success function" {
  run bash -c "source '${PROJECT_ROOT}/tools/scripts/config.sh' && declare -F log_success"
  [[ "$status" -eq 0 ]]
}

@test "config.sh defines log_error function" {
  run bash -c "source '${PROJECT_ROOT}/tools/scripts/config.sh' && declare -F log_error"
  [[ "$status" -eq 0 ]]
}

@test "config.sh defines command_exists function" {
  run bash -c "source '${PROJECT_ROOT}/tools/scripts/config.sh' && declare -F command_exists"
  [[ "$status" -eq 0 ]]
}

@test "config.sh defines error counter functions" {
  run bash -c "source '${PROJECT_ROOT}/tools/scripts/config.sh' && declare -F init_error_counter"
  [[ "$status" -eq 0 ]]
}

@test "config.sh command_exists function works correctly" {
  run bash -c "source '${PROJECT_ROOT}/tools/scripts/config.sh' && command_exists bash"
  [[ "$status" -eq 0 ]]
}
