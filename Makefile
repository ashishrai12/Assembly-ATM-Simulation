# Makefile

# Variables
PYTHON ?= python3
PIP ?= pip

# Directories
SRC_DIR = src
BUILD_DIR = build
TEST_DIR = tests
DOCS_DIR = docs

# Default target
.PHONY: all
all: build test

# Build assembly source into HEX
.PHONY: build
build:
	@mkdir -p $(BUILD_DIR)
# Check if as31 is installed (or use pip/apt)
	as31 -Fhex $(SRC_DIR)/atm_system.asm
	mv $(SRC_DIR)/atm_system.hex $(BUILD_DIR)/atm.hex

# Run Python simulation and generate plots
.PHONY: sim
sim:
	$(PYTHON) $(TEST_DIR)/simulator.py

# Run unit tests (Python + optional assembly emulator tests)
.PHONY: test
test:
	$(PYTHON) -m pytest $(TEST_DIR)

# Clean build artefacts
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) __pycache__ *.hex *.obj *.lst *.log

# Docker build and run
.PHONY: docker-build
docker-build:
	docker build -t assembly-atm-sim .

.PHONY: docker-run
docker-run:
	docker run --rm -it assembly-atm-sim
