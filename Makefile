# Makefile for EPOS contract interactions

# Variables
FORGE = forge
SCRIPT_DIR = script
DEPLOY_SCRIPT = DeployEPOS.s.sol
RPC_URL ?= http://localhost:8545
SENDER ?= 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
V ?= vv

# Default goal
.DEFAULT_GOAL := help

# Help command
help:
	@echo "Available commands:"
	@echo "  make deploy  - Deploy the EPOS contract"
	@echo "  make test    - Run the test suite"
	@echo "  make clean   - Remove build artifacts"

# Anvil start command
anvil:
	@echo "Starting Anvil..."
	cd foundry && anvil

# Test command
test:
	@echo "Running tests..."
	cd foundry && $(FORGE) test --via-ir -$(V)

# Deploy command
deploy:
	@echo "Deploying EPOS contract..."
	cd foundry && $(FORGE) script $(SCRIPT_DIR)/$(DEPLOY_SCRIPT) --via-ir -vvvvv --fork-url $(RPC_URL) --broadcast --sender $(SENDER)

# Clean command
clean:
	@echo "Cleaning build artifacts..."
	@$(FORGE) clean

# Phony targets
.PHONY: help deploy test clean
