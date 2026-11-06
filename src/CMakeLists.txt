# Gather all .cpp and .h files recursively
file(GLOB_RECURSE SRC_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/*.h
)

# Create the main executable target
add_executable(MyGame ${SRC_FILES})

source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" PREFIX "Source" FILES
  MyGame.cpp
  MyGame.h
)

set_target_properties(MyGame PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY_DEBUG "${MYGAME_BUILDS_ROOT}/Debug"
  RUNTIME_OUTPUT_DIRECTORY_RELEASE "${MYGAME_BUILDS_ROOT}/Release"
)

target_compile_definitions(MyGame PRIVATE
  RESOURCE_PATH="$<TARGET_FILE_DIR:MyGame>/resources/"
  $<$<CONFIG:Debug>:DEBUG_BUILD>
)

target_include_directories(MyGame PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

target_link_libraries(MyGame PRIVATE ${MYGAME_LIBS})

# Copy data-only resources next to the exe (same layout CPack installs).
add_custom_command(TARGET MyGame POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
    "${PROJECT_SOURCE_DIR}/resources"
    "$<TARGET_FILE_DIR:MyGame>/resources"
  COMMENT "Copy resources next to MyGame"
  VERBATIM
)

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
