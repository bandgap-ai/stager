cmake_minimum_required(VERSION 3.10)

# Define the project and disable default language support.
project(StagerPlatform NONE)

# Detect Host OS and map to Flutter platform strings.
# This logic replicates the OS detection in the project's Makefile.
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(FLUTTER_OS "windows")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    set(FLUTTER_OS "linux")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    set(FLUTTER_OS "macos")
else()
    # Fallback default.
    set(FLUTTER_OS "linux")
endif()

message(STATUS "Configuring Stager for target platform: ${FLUTTER_OS}")

# Find required executables.
find_program(FLUTTER_EXE flutter REQUIRED)
find_program(DART_EXE dart REQUIRED)

# Overwrite the variables on Windows to prevent batch file termination.
# This prevents you from having to rewrite your COMMAND blocks below.
if(WIN32)
    set(FLUTTER_EXE cmd /c call ${FLUTTER_EXE})
    set(DART_EXE cmd /c call ${DART_EXE})
endif()

# Variables
set(GENERATOR_TESTS "generator_test")

# Target: stager_help
# Replicates the help output from the Makefile.
# 'stager_help' is used to avoid conflict with CMake's built-in help.
add_custom_target(stager_help
    COMMAND ${CMAKE_COMMAND} -E echo "Stager Platform Makefile"
    COMMAND ${CMAKE_COMMAND} -E echo "-----------------------"
    COMMAND ${CMAKE_COMMAND} -E echo "Detected Platform: ${FLUTTER_OS}"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Targets:"
    COMMAND ${CMAKE_COMMAND} -E echo "  stager_help - Generates this help message"
    COMMAND ${CMAKE_COMMAND} -E echo "  generate    - Run build_runner code generation"
    COMMAND ${CMAKE_COMMAND} -E echo "  analyze     - Run static analysis"
    COMMAND ${CMAKE_COMMAND} -E echo "  test        - Run all unit tests"
    COMMAND ${CMAKE_COMMAND} -E echo "  build       - Build the example app for ${FLUTTER_OS}"
    COMMAND ${CMAKE_COMMAND} -E echo "  run         - Run the example app on ${FLUTTER_OS}"
    COMMAND ${CMAKE_COMMAND} -E echo "  stager_all  - Run generate, build, and test"
    COMMAND ${CMAKE_COMMAND} -E echo "  clean       - Clean flutter build artifacts"
    VERBATIM
)

# Target: generate
add_custom_target(generate
    COMMAND ${FLUTTER_EXE} pub get
    COMMAND ${DART_EXE} run build_runner build
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running build_runner code generation"
    VERBATIM
)

# Target: analyze
add_custom_target(analyze
    COMMAND ${FLUTTER_EXE} analyze --no-fatal-infos --no-fatal-warnings
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running static analysis"
    VERBATIM
)

# Target: dart_test
add_custom_target(dart_test
    COMMAND ${DART_EXE} test ${GENERATOR_TESTS}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running specialized generator tests"
    VERBATIM
)

# Target: flutter_test
add_custom_target(flutter_test
    COMMAND ${FLUTTER_EXE} test --coverage
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running Flutter unit tests with coverage"
    VERBATIM
)

# Target: test (combines dart_test and flutter_test)
add_custom_target(test
    DEPENDS dart_test flutter_test
    COMMENT "Running all unit tests"
)

# Target: build
add_custom_target(build
    COMMAND ${FLUTTER_EXE} pub get
    COMMAND ${FLUTTER_EXE} build ${FLUTTER_OS} --debug --verbose
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/example
    DEPENDS generate
    COMMENT "Building the example app for ${FLUTTER_OS}"
    VERBATIM
)

# Target: run
add_custom_target(run
    COMMAND ${FLUTTER_EXE} run -d ${FLUTTER_OS} lib/main.dart
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/example
    COMMENT "Running the example app on ${FLUTTER_OS}"
    VERBATIM
)

# Target: stager_all (Makefile 'all')
add_custom_target(stager_all
    DEPENDS generate build test
    COMMENT "Running generate, build, and test"
)

# Target: clean_stager (Makefile 'clean')
add_custom_target(clean_stager
    COMMAND ${FLUTTER_EXE} clean
    COMMAND ${CMAKE_COMMAND} -E chdir example ${FLUTTER_EXE} clean
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Cleaning flutter build artifacts"
    VERBATIM
)
