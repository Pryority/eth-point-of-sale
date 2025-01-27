# Makefile for EPOS contract interactions

# Variables
FORGE = forge
CAST = cast
SCRIPT_DIR = script
DEPLOY_SCRIPT = DeployEPOS.s.sol
RPC_URL ?= http://localhost:8545
CONTRACT ?= 0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82
SENDER ?= 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
V ?= vv
MT ?=
MT_FLAG := $(if $(MT),--mt,)
id =

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
	cd foundry && $(FORGE) test --via-ir -$(V) $(MT_FLAG) $(MT)

# Deploy command
deploy:
	@echo "Deploying EPOS contract..."
	cd foundry && $(FORGE) script $(SCRIPT_DIR)/$(DEPLOY_SCRIPT) --via-ir -vvvvv --fork-url $(RPC_URL) --broadcast --sender $(SENDER)

# Deploy command
get:
	@echo "Getting a product..."
	cd foundry && $(CAST) call $(CONTRACT) "getProduct(uint256)" $(id)

# Clean command
clean:
	@echo "Cleaning build artifacts..."
	@$(FORGE) clean

# Phony targets
.PHONY: help deploy test clean
