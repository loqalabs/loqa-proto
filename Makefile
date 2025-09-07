.PHONY: generate lint lint-fix format validate quality-check clean install-tools help

# Protocol buffer generation and validation

generate: ## Generate protocol buffer bindings
	./generate.sh

generate-commit: ## Generate protocol buffer bindings and commit changes
	./generate.sh --commit

# Linting and formatting
lint: ## Lint protocol buffer files with buf
	buf lint

format: ## Format protocol buffer files with buf
	buf format -w

validate: ## Validate protocol buffer compilation
	protoc --go_out=/tmp --go-grpc_out=/tmp \
		--go_opt=paths=source_relative \
		--go-grpc_opt=paths=source_relative \
		*.proto
	@echo "✅ Protocol buffer files compile successfully"

breaking: ## Check for breaking changes with buf
	buf breaking --against '.git#branch=main'

# Development helpers
clean: ## Clean generated files and caches
	rm -rf go/audio/*.pb.go
	buf cache clear
	@echo "✅ Cleaned generated files and caches"

# Install development tools
install-tools: ## Install protocol buffer development tools
	@echo "Installing buf..."
	@if ! command -v buf &> /dev/null; then \
		curl -sSL "https://github.com/bufbuild/buf/releases/download/v1.25.0/buf-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/buf && \
		chmod +x /usr/local/bin/buf; \
	fi
	@echo "Installing protoc..."
	@if ! command -v protoc &> /dev/null; then \
		echo "Please install protoc manually: https://grpc.io/docs/protoc-installation/"; \
	fi

# Pre-commit checks (run before committing)
pre-commit: format lint validate ## Run all pre-commit checks

# Complete quality validation (run before pushing) 
quality-check: format lint validate breaking ## Run comprehensive quality checks

# Help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)