# Install layout matches a runnable folder:
#   MyGame.exe
#   resources/textures/...
#   resources/audio/...
#
# From the vs/ build dir:
#   cmake --build . --config Release
#   cpack -C Release -B ../dist

install(TARGETS MyGame RUNTIME DESTINATION .)
install(DIRECTORY "${PROJECT_SOURCE_DIR}/resources/"
  DESTINATION resources
  PATTERN "CMakeLists.txt" EXCLUDE
  PATTERN ".resource_manifest.json" EXCLUDE
)

set(CPACK_GENERATOR ZIP)
set(CPACK_PACKAGE_NAME "MyGame")
set(CPACK_PACKAGE_VENDOR "IWheelBarrows")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY ON)
include(CPack)
