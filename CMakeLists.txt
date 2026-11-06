cmake_minimum_required(VERSION 3.26)

if(POLICY CMP0141)
  cmake_policy(SET CMP0141 NEW)
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

project(MyGame
  VERSION 0.1
  DESCRIPTION "My game project"
  LANGUAGES C CXX)

set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_C_STANDARD 11)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "CMake")

# Runnable output: builds/<Config>/MyGame.exe + resources/
set(MYGAME_BUILDS_ROOT "${PROJECT_SOURCE_DIR}/builds")

# Libraries first so src/ can link MYGAME_LIBS.
# Skip vendor install() rules so raylib/GLFW do not add an INSTALL project.
set(CMAKE_SKIP_INSTALL_RULES ON)
include("${PROJECT_SOURCE_DIR}/cmake/Dependencies.cmake")
set(CMAKE_SKIP_INSTALL_RULES OFF)

add_subdirectory(src)

target_link_libraries(MyGame PRIVATE ${MYGAME_LIBS})

set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" PROPERTY VS_STARTUP_PROJECT MyGame)

include("${PROJECT_SOURCE_DIR}/cmake/Pack.cmake")
