#!/bin/bash

# --- CONFIGURATION (HARDCODED FOR STABILITY) ---
SDK_DIR="/data/data/com.termux/files/home/opt/android-sdk"
NDK_DIR="/data/data/com.termux/files/home/opt/android-ndk-r29"
CMAKE_BIN="$SDK_DIR/cmake/bin/cmake"
NINJA_BIN=$(which ninja)

# --- FLAGS & OPTIMIZATION ---
ABI="arm64-v8a"
API_LEVEL="29"
BUILD_DIR="build_android"

# --- COLORS FOR BETTER READABILITY ---
BLUE='\033[1;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- SECURITY CHECK ---
clear
echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}   ANDROID NATIVE BUILDER - UNIVERSAL v2.0   ${NC}"
echo -e "${BLUE}=============================================${NC}"

# Validasi Keberadaan Tool
[[ ! -d "$NDK_DIR" ]] && { echo -e "${RED}[!] NDK Tidak Ditemukan!${NC}"; exit 1; }
[[ -z "$NINJA_BIN" ]] && { echo -e "${RED}[!] Ninja belum terinstall (pkg install ninja)${NC}"; exit 1; }

# Bersihkan build lama secara aman
if [ -d "$BUILD_DIR" ]; then
    echo -e "${YELLOW}[*] Membersihkan cache build lama...${NC}"
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

# --- CORE EXECUTION ---
echo -e "${YELLOW}[*] Menjalankan Konfigurasi CMake...${NC}"

# Note: Flag -Wno-dev ditambahkan untuk menyembunyikan warning CMake Deprecation
$CMAKE_BIN \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_DIR/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM="android-$API_LEVEL" \
    -DCMAKE_BUILD_TYPE=Release \
    -DANDROID_STL=c++_static \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_MAKE_PROGRAM="$NINJA_BIN" \
    -G Ninja \
    -Wno-dev \
    -DCMAKE_CXX_FLAGS="-fPIC -O3 -fstack-protector-all" \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,--exclude-libs,ALL -Wl,--gc-sections -Wl,--strip-all" \
    ..

# --- COMPILATION PHASE ---
THREADS=$(nproc)
echo -e "${GREEN}[*] Memulai Kompilasi dengan $THREADS Thread...${NC}"

$NINJA_BIN -j"$THREADS"

# --- FINAL VALIDATION ---
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✔ BUILD SELESAI DENGAN SUKSES!${NC}"
    # Cari file .so yang dihasilkan
    SO_FILES=$(find . -name "*.so")
    echo -e "${BLUE}Output File:${NC}"
    echo -e "$SO_FILES"
    echo -e "${GREEN}=============================================${NC}"
else
    echo -e "\n${RED}✘ BUILD GAGAL! Periksa kembali kode sumber kamu.${NC}"
    exit 1
fi