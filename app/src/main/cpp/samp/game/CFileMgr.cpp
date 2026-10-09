//
// Created by x1y2z on 14.04.2023.
//

#include "CFileMgr.h"
#include "main.h"
#include "../vendor/armhook/patch.h"

void CFileMgr::SetDir(const char *path) {
    ( ( void(*)(const char *path) )(g_libGTASA + 0x4921C4) )(path);
}

FILE* CFileMgr::OpenFile(const char *path, const char *mode) {
    if (g_pszStorage == nullptr || path == nullptr || mode == nullptr) return nullptr;
    const int written = snprintf(ms_path, sizeof(ms_path), "%s%s", g_pszStorage, path);
    if (written < 0 || static_cast<size_t>(written) >= sizeof(ms_path)) {
        Log("Fail open file: path is too long");
        return nullptr;
    }

    auto file = fopen(ms_path, mode);

    if(!file) {
        Log("Fail open file %s", ms_path);
    }
    return file;
}

int32_t CFileMgr::CloseFile(FILE* file) {
    return fclose(file);
}

void CFileMgr::Initialise() {
    CHook::CallFunction<void>("_ZN8CFileMgr10InitialiseEv"); // ������� ����� �����
}
