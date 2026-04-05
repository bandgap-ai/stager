# Detect Host OS and map to Flutter platform strings
ifeq ($(OS),Windows_NT)
    FLUTTER_OS := windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        FLUTTER_OS := linux
    endif
    ifeq ($(UNAME_S),Darwin)
        FLUTTER_OS := macos
    endif
endif

# Commands
FLUTTER_EXE := flutter
DART_EXE := dart

.PHONY: help generate test build run all clean

help:
	@echo "Stager Platform Makefile"
	@echo "-----------------------"
	@echo "Detected Platform: $(FLUTTER_OS)"
	@echo ""
	@echo "Targets:"
	@echo "  generate - Run build_runner code generation"
	@echo "  test     - Run unit tests"
	@echo "  build    - Build the example app for $(FLUTTER_OS)"
	@echo "  run      - Run the example app on $(FLUTTER_OS)"
	@echo "  all      - Run generate, build, and test"
	@echo "  clean    - Clean flutter build artifacts"

generate:
	$(FLUTTER_EXE) pub get
	$(DART_EXE) run build_runner build --delete-conflicting-outputs

dart_test:
	$(DART_EXE) test generator_test

flutter_test:
	$(FLUTTER_EXE) test

test: dart_test flutter_test

build: generate
	cd example && $(FLUTTER_EXE) pub get
	cd example && $(FLUTTER_EXE) build $(FLUTTER_OS) --debug --verbose

run:
	cd example && $(FLUTTER_EXE) run -d $(FLUTTER_OS) lib/main.dart

all: generate build test

clean:
	$(FLUTTER_EXE) clean
	cd example && $(FLUTTER_EXE) clean