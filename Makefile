.PHONY: test clean install help

# Default target
.DEFAULT_GOAL := help

help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

test: ## Run tests using Busted framework with vusted
	@echo "Running tests with Busted via vusted..."
	@vusted --coverage spec/


# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	@rm -f luacov.*.out
	@vusted spec/ --coverage
	@if command -v luarocks > /dev/null 2>&1; then \
		eval $$(luarocks path) && luacov; \
	else \
		echo "Error: luarocks not found. Please install luarocks first."; \
		exit 1; \
	fi
	@echo ""
	@echo "Coverage report generated in luacov.report.out"
	@grep -A 5 "^Summary$$" luacov.report.out || true

install: ## Install test dependencies (busted and vusted via luarocks)
	@echo "Checking for luarocks..."
	@which luarocks > /dev/null || (echo "Error: luarocks not found. Please install it first with: sudo apt-get install luarocks" && exit 1)
	@echo "Installing busted and vusted..."
	luarocks install --local busted
	luarocks install --local vusted
	luarocks install --local luacov
	@if luarocks install --local busted vusted 2>/dev/null; then \
		echo "Test dependencies installed locally in ~/.luarocks/"; \
		echo "You may need to add ~/.luarocks/bin to your PATH"; \
	else \
		echo "Local installation failed. Trying system-wide installation..."; \
		echo "This requires root privileges. You may be prompted for your password."; \
		sudo luarocks install busted; \
		sudo luarocks install vusted; \
		sudo luarocks install luacov; \
	fi
	@echo "Test dependencies installed successfully!"

clean: ## Clean up temporary files
	@echo "Cleaning up..."
	@find . -name "*.tmp" -type f -delete
	@find . -name ".luacov" -type f -delete
	@echo "Clean complete!"
