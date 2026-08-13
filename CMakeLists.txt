cmake_minimum_required(VERSION 3.22.1)

# Set the project name
project("AntiCheatBypass")

# C++ Standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ==========================================
# 1. Dobby Hook Setup
# ==========================================
macro(SET_OPTION option value)
    set(${option} ${value} CACHE INTERNAL "" FORCE)
endmacro()

# Matikan plugin dan build shared Dobby agar menyatu di static
SET_OPTION(DOBBY_GENERATE_SHARED OFF)
SET_OPTION(Plugin.SymbolResolver OFF)
SET_OPTION(Plugin.ImportTableReplace OFF)

# Tambahkan sub-directory Dobby
add_subdirectory(External/Dobby)

# ==========================================
# 2. Source Files Gathering
# ==========================================
# Tanpa Keystone Assembler
add_compile_definitions(kNO_KEYSTONE)

# Ambil semua file source dari KittyMemory
file(GLOB_RECURSE KITTY_MEMORY_SOURCES "External/KittyMemory/KittyMemory/*.cpp")

# Ambil semua file source dari Engine/API
file(GLOB_RECURSE ENGINE_SOURCES "Engine/API/*.cpp")

# Gabungkan semua file ke dalam shared library utama
add_library(${CMAKE_PROJECT_NAME} SHARED
        native-lib.cpp
        ${ENGINE_SOURCES}
        ${KITTY_MEMORY_SOURCES}
)

# ==========================================
# 3. Include Directories
# ==========================================
target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC
        Engine
        External/Dobby/include
        External/KittyMemory
        External/KittyMemory/KittyMemory
        Utils
)

# ==========================================
# 4. Link Libraries
# ==========================================
# 'log' ditaruh di awal untuk memastikan fungsi __android_log_vprint terbaca oleh Dobby
target_link_libraries(${CMAKE_PROJECT_NAME} 
        log 
        dobby
)