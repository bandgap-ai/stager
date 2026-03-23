cmake_minimum_required(VERSION 3.10)
project(StagerPlatform NONE)

# Detect Host OS and map to Flutter platform strings
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    set(FLUTTER_OS "linux")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(FLUTTER_OS "windows")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    set(FLUTTER_OS "macos")
else()
    set(FLUTTER_OS "chrome")
endif()

message(STATUS "Configuring Stager for target platform: ${FLUTTER_OS}")

# Find Executables
find_program(FLUTTER_EXE flutter REQUIRED)
find_program(DART_EXE dart REQUIRED)

# Define the source generation target (build_runner)
add_custom_target(generate
    COMMAND ${FLUTTER_EXE} pub get
    COMMAND ${DART_EXE} run build_runner build --delete-conflicting-outputs
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running source_gen code generation..."
)

# Define the test target
add_custom_target(test
    COMMAND ${FLUTTER_EXE} test
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running Stager unit tests..."
)

# Define the build target (example app)
# Depends on generate to ensure generated code exists
add_custom_target(build
    COMMAND ${FLUTTER_EXE} pub get
    COMMAND ${FLUTTER_EXE} build ${FLUTTER_OS} --debug --verbose
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/example
    DEPENDS generate
    COMMENT "Building Stager example for ${FLUTTER_OS}..."
)

# Define the run target
add_custom_target(run
    COMMAND ${FLUTTER_EXE} run -d ${FLUTTER_OS} lib/main.dart
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/example
    COMMENT "Launching Stager example on ${FLUTTER_OS}..."
)

# Convenience 'all' target
add_custom_target(stager_all
    DEPENDS generate build test
)
