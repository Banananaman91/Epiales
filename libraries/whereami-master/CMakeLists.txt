file(GLOB WHEREAMI_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/src/whereami.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/whereami.h
)

add_library(whereami-master ${WHEREAMI_SRC})

target_include_directories(whereami-master PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)