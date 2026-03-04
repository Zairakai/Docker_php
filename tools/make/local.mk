# Local Makefile targets for dockers/php
# PHP-specific commands and testing

##
## —— 🧪 Local Testing ——
.PHONY: test-config
test-config: ## Test configuration consistency
	@./scripts/validate-config.sh

.PHONY: test-security
test-security: ## Enhanced security testing
	@./scripts/validate-security.sh

.PHONY: test-docker
test-docker: ## Docker-specific tests
	@./scripts/validate-docker.sh

.PHONY: test-complete
test-complete: ci-full test-config test-security test-docker ## Complete project validation
