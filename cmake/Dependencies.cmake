# Third-party libraries. Include this from the root CMakeLists before src/.
#
# To add a library:
#   1. add_subdirectory(...) EXCLUDE_FROM_ALL  (or FetchContent below)
#   2. append the CMake target name to MYGAME_LIBS
#   3. mygame_set_library_folder(<target>) so it lands under "Libraries" in VS

include(FetchContent)

# Disable vendor extras before any add_subdirectory so they never become
# ALL_BUILD / INSTALL / example projects in the Visual Studio solution.
set(BUILD_EXAMPLES OFF CACHE BOOL "Build raylib examples" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build dependencies as shared libs" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)

function(mygame_set_library_folder target_name)
  if(TARGET "${target_name}")
    set_target_properties("${target_name}" PROPERTIES FOLDER "Libraries")
  endif()
endfunction()

# --- whereami ---
FetchContent_Declare(whereami
  GIT_REPOSITORY https://github.com/gpakosz/whereami.git
  GIT_TAG master
)
FetchContent_GetProperties(whereami)
if(NOT whereami_POPULATED)
  FetchContent_MakeAvailable(whereami)
endif()

add_library(whereami STATIC ${whereami_SOURCE_DIR}/src/whereami.c)
target_include_directories(whereami PUBLIC ${whereami_SOURCE_DIR}/src)

message(STATUS "whereami_SOURCE_DIR = ${whereami_SOURCE_DIR}")
message(STATUS "whereami.c = ${whereami_SOURCE_DIR}/src/whereami.c")

# --- raylib ---
set(RAYLIB_VERSION 6.2)
find_package(raylib ${RAYLIB_VERSION} QUIET) # QUIET or REQUIRED
if(NOT raylib_FOUND)
  FetchContent_Declare(raylib
    GIT_REPOSITORY https://github.com/raysan5/raylib.git
    GIT_TAG 5.5
    GIT_SHALLOW TRUE
  )
  FetchContent_GetProperties(raylib)
  if(NOT raylib_POPULATED)
    FetchContent_MakeAvailable(raylib)
    set(BUILD_SHARED_LIBS ON CACHE BOOL "" FORCE)
    #add_subdirectory(${raylib_SOURCE_DIR} ${raylib_BINARY_DIR} EXCLUDE_FROM_ALL)
  endif()
endif()

#add_library(raylib SHARED)
#target_include_directories(raylib INTERFACE ${raylib_SOURCE_DIR} EXCLUDE_FROM_ALL)

mygame_set_library_folder(whereami)
mygame_set_library_folder(raylib)
mygame_set_library_folder(glfw)
mygame_set_library_folder(uninstall)

# Game links only this list. Append new library targets here.
set(MYGAME_LIBS
  whereami
  raylib
)

if(TARGET whereami)
    message(STATUS "whereami target exists")
else()
    message(FATAL_ERROR "whereami target does not exist")
endif()
