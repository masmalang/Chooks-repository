include_directories(.)

if(NOT BUILDING_KERNEL)
  set(SOURCE_FILE_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/cxxlogging.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/logging.c
  )
else()
  set(SOURCE_FILE_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/cxxlogging.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/kernel_logging.c
    )
endif()

# 1. Definisikan library 'logging' hanya dengan file sumbernya saja
add_library(logging SHARED
  ${SOURCE_FILE_LIST}
)

# 2. Hubungkan library 'log' milik Android ke target 'logging'
# Ini adalah bagian krusial untuk memperbaiki error __android_log_vprint
target_link_libraries(logging
  log
)