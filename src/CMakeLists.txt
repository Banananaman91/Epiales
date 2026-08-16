# Gather all .cpp and .h files recursively
file(GLOB_RECURSE SRC_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/*.h
)

# Create the main executable target
add_executable(MyGame ${SRC_FILES})

# Put final executables into MyGame/builds/<Configuration>
# Use CMAKE_SOURCE_DIR so builds/ is created next to the source tree.
set(BUILDS_ROOT "${CMAKE_SOURCE_DIR}/builds")

set_target_properties(MyGame PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY_DEBUG "${BUILDS_ROOT}/Debug"
  RUNTIME_OUTPUT_DIRECTORY_RELEASE "${BUILDS_ROOT}/Release"
)

# Prevent Visual Studio from generating unwanted build targets
set(CMAKE_SKIP_INSTALL_RULES TRUE)
set(CMAKE_SKIP_PACKAGE_RULES TRUE)

# Ensure Visual Studio uses MyGame as the startup project
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT MyGame)

# Define PROJECT_ROOT path for runtime loading
target_compile_definitions(MyGame PRIVATE
    PROJECT_ROOT="${CMAKE_SOURCE_DIR}"
)

# Define RESOURCE_PATH for runtime loading
target_compile_definitions(MyGame PRIVATE
    RESOURCE_PATH="$<TARGET_FILE_DIR:MyGame>/resources/"
)

# Add debug-only logging macro
target_compile_definitions(MyGame PRIVATE
    $<$<CONFIG:Debug>:DEBUG_BUILD>
)

# Include src folder for headers
target_include_directories(MyGame PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Link external libraries
target_link_libraries(MyGame PRIVATE
    whereami-master
    raylib
)

# --- build-time resource sync and conditional reconfigure ---

# Require Python3 interpreter (or set Python3_EXECUTABLE externally)
find_package(Python3 COMPONENTS Interpreter REQUIRED)

# Paths to scripts
set(SYNC_SCRIPT "${CMAKE_SOURCE_DIR}/cmake/sync_resources.py")
set(RECONF_SCRIPT "${CMAKE_SOURCE_DIR}/cmake/reconfigure_if_needed.py")

# Destination resources folder next to the runtime executable
set(RES_SRC_DIR "${CMAKE_SOURCE_DIR}/resources")
set(DEST_RES_DIR "${BUILDS_ROOT}/$<CONFIG>/resources")

# copy_resources: always run at build time to pick up new/changed assets
add_custom_target(copy_resources
  COMMAND ${CMAKE_COMMAND} -E echo "SYNC: Python = ${Python3_EXECUTABLE}"
  COMMAND ${CMAKE_COMMAND} -E echo "SYNC: RES_SRC_DIR = ${RES_SRC_DIR}"
  COMMAND ${CMAKE_COMMAND} -E echo "SYNC: DEST_RES_DIR = ${DEST_RES_DIR}"
  COMMAND ${CMAKE_COMMAND} -E make_directory "${DEST_RES_DIR}"
  COMMAND ${Python3_EXECUTABLE} "${SYNC_SCRIPT}" "${RES_SRC_DIR}" "${DEST_RES_DIR}"
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
  COMMENT "Syncing resources to ${DEST_RES_DIR}"
  VERBATIM
)

# reconfigure_if_needed: run before build to re-run CMake only when sources/CMake changed
# Pass any extra CMake args you normally use (e.g., -D flags) by appending them to RECONFIGURE_CMAKE_ARGS
set(RECONFIGURE_CMAKE_ARGS "")  # e.g. "-DMyOption=ON"
add_custom_target(reconfigure_if_needed
  COMMAND ${Python3_EXECUTABLE} "${RECONF_SCRIPT}" "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}" "${CMAKE_COMMAND}" ${RECONFIGURE_CMAKE_ARGS}
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
  COMMENT "Checking sources and reconfiguring CMake if needed"
  VERBATIM
)

# Ensure the reconfigure check runs before copying resources and before building MyGame
add_dependencies(copy_resources reconfigure_if_needed)
add_dependencies(MyGame copy_resources)

# Automatically compile shaders from MyGame/shaders/ into MyGame/shaders/compiled/
find_program(GLSLANG_VALIDATOR glslangValidator)

if (GLSLANG_VALIDATOR)
    file(GLOB SHADERS
        ${CMAKE_SOURCE_DIR}/shaders/*.glsl
    )

    foreach(SHADER ${SHADERS})
        get_filename_component(SHADER_NAME ${SHADER} NAME_WE)

        add_custom_command(
            TARGET MyGame POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory
                ${CMAKE_SOURCE_DIR}/shaders/compiled
            COMMAND ${GLSLANG_VALIDATOR} -V ${SHADER}
                -o ${CMAKE_SOURCE_DIR}/shaders/compiled/${SHADER_NAME}.spv
            COMMENT "Compiling shader: ${SHADER_NAME}"
        )
    endforeach()
endif()