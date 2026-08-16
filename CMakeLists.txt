# CMakeList.txt : CMake project for MyGame, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.10)

# Enable Hot Reload for MSVC compilers if supported.
if (POLICY CMP0141)
  cmake_policy(SET CMP0141 NEW)
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

project ("MyGame" VERSION 0.1
					DESCRIPTION "My game project"
					LANGUAGES C CXX)

					# Enable Debug/Release build types
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)

# Add src and resources directories
add_subdirectory(src)
add_subdirectory(resources)

# Add external libraries
add_subdirectory(libraries/whereami-master)
add_subdirectory(libraries/raylib/raylib)

if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET MyGame PROPERTY CXX_STANDARD 20)
endif()

# TODO: Add tests and install targets if needed.
