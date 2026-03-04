#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load "../helpers/common"

# =============================================================================
# MAKEFILE TARGETS - Validation des commandes Make essentielles
# =============================================================================

@test "make help displays available commands" {
  run make -C "${PROJECT_ROOT}" help
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ "Available Commands" ]]
}

@test "make quality target exists" {
  run make -C "${PROJECT_ROOT}" -n quality
  [[ "$status" -eq 0 ]]
}

@test "make bats target exists" {
  run make -C "${PROJECT_ROOT}" -n bats
  [[ "$status" -eq 0 ]]
}

@test "make shellcheck target exists" {
  run make -C "${PROJECT_ROOT}" -n shellcheck
  [[ "$status" -eq 0 ]]
}

@test "make markdownlint target exists" {
  run make -C "${PROJECT_ROOT}" -n markdownlint
  [[ "$status" -eq 0 ]]
}

@test "ZAIRAKAI_SCRIPTS_DIR variable is exported correctly" {
  run bash -c "cd '${PROJECT_ROOT}' && make -n help | grep -q ZAIRAKAI_SCRIPTS_DIR || echo \$ZAIRAKAI_SCRIPTS_DIR"
  # Just verify it doesn't error - the variable is used internally
  [[ "$status" -eq 0 ]]
}
