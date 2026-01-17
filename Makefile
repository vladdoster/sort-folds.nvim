.PHONY: test clean install help

# Default target
.DEFAULT_GOAL := help

help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

test: ## Run tests using Busted framework
	@echo "Running tests with Busted..."
	@busted spec/

install: ## Install test dependencies (busted and luarocks)
	@echo "Checking for luarocks..."
	@which luarocks > /dev/null || (echo "Error: luarocks not found. Please install it first." && exit 1)
	@echo "Installing busted and nlua..."
	@luarocks install --local busted nlua || sudo luarocks install busted nlua
	@echo "Test dependencies installed successfully!"

clean: ## Clean up temporary files
	@echo "Cleaning up..."
	@find . -name "*.tmp" -type f -delete
	@find . -name ".luacov" -type f -delete
	@echo "Clean complete!"
