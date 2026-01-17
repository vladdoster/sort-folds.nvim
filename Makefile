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
	@which luarocks > /dev/null || (echo "Error: luarocks not found. Please install it first with: sudo apt-get install luarocks" && exit 1)
	@echo "Installing busted and nlua..."
	@if luarocks install --local busted nlua 2>/dev/null; then \
		echo "Test dependencies installed locally in ~/.luarocks/"; \
		echo "You may need to add ~/.luarocks/bin to your PATH"; \
	else \
		echo "Local installation failed. Trying system-wide installation..."; \
		echo "This requires root privileges. You may be prompted for your password."; \
		sudo luarocks install busted nlua || (echo "Error: Failed to install dependencies. Please install manually." && exit 1); \
	fi
	@echo "Test dependencies installed successfully!"

clean: ## Clean up temporary files
	@echo "Cleaning up..."
	@find . -name "*.tmp" -type f -delete
	@find . -name ".luacov" -type f -delete
	@echo "Clean complete!"
