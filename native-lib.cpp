#include <jni.h>
#include <string>
#include <thread>
#include <cstdint>
#include "Engine/Includes.hpp"
#include "Logger.h"

ProcMap map;

// ==========================================
// 1. CanSight Hook
// ==========================================
bool (*old_CanSight)(void* self, void* fighter) = nullptr;
bool new_old_CanSight(void* self, void* fighter) {
    LOGI("MLBB - CanSight bypassed");
    return true; 
}

// ==========================================
// 2. Quit Hook (Supaya game tidak bisa di-force close oleh script)
// ==========================================
void (*old_Quit)(void*) = nullptr;
void new_old_Quit(void* self) {
    LOGI("MLBB - Prevent Application.Quit");
    // Sengaja dikosongkan agar fungsi Quit tidak berjalan
}

// ==========================================
// 3. SetActive Hook
// ==========================================
void (*old_SetActive)(void*, bool) = nullptr;
void new_old_SetActive(void* self, bool active) {
    old_SetActive(self, active); // Wajib panggil fungsi asli agar tidak crash
}

// ==========================================
// Main Loader
// ==========================================
__attribute__((constructor))
void lib_main() {
    std::thread([]() {
        do {
            map = KittyMemory::getElfBaseMap("libil2cpp.so");
            sleep(1);
        } while (!map.isValid() && !map.isValidELF());

        if (Il2Cpp::Init("libil2cpp.so") == -1) {
            LOGE("Il2Cpp::Init Failed!");
            return;
        }

        LOGI("=== MLBB Loader Started ===");

        // Perhatikan angka 1 di ujung (karena method CanSight punya 1 parameter di C#)
        setPointer(old_CanSight, "Assembly-CSharp.dll", "", "ShowEntity", "CanSight", 1);
        setHook(old_CanSight, "CanSight");

        setPointer(old_Quit, "UnityEngine.CoreModule.dll", "UnityEngine", "Application", "Quit", 0);
        setHook(old_Quit, "Quit");

        setPointer(old_SetActive, "UnityEngine.CoreModule.dll", "UnityEngine", "GameObject", "SetActive", 1);
        setHook(old_SetActive, "SetActive");

    }).detach();
}