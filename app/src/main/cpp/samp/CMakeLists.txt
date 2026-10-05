cmake_minimum_required(VERSION 3.12)
project(samp)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT ANDROID_ABI STREQUAL "arm64-v8a")
    message(FATAL_ERROR "BCG V019 supports only arm64-v8a; received ${ANDROID_ABI}")
endif()
add_compile_definitions(VER_x32=false)

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_LIST_DIR}/*.c"
        "${CMAKE_CURRENT_LIST_DIR}/*.cc"
        "${CMAKE_CURRENT_LIST_DIR}/*.cpp"
        "${CMAKE_CURRENT_LIST_DIR}/*.cxx"
)

include_directories(
        ${CMAKE_CURRENT_LIST_DIR}
        ${CMAKE_CURRENT_LIST_DIR}/util/
        ${CMAKE_CURRENT_LIST_DIR}/vendor/armhook
        ${CMAKE_CURRENT_LIST_DIR}/vendor/imgui
        ${CMAKE_CURRENT_LIST_DIR}/vendor/
        ${CMAKE_CURRENT_LIST_DIR}/game/RW/
        ${CMAKE_CURRENT_LIST_DIR}/game/Core/
)

add_library(samp SHARED ${SOURCES})

set(BCG_NATIVE_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/vendor/bass/libs/${ANDROID_ABI}")
foreach(BCG_LIB bass bass_fx bass_ssl)
    set(BCG_LIB_PATH "${BCG_NATIVE_LIB_DIR}/lib${BCG_LIB}.so")
    if(NOT EXISTS "${BCG_LIB_PATH}")
        message(FATAL_ERROR "Required native library is missing: ${BCG_LIB_PATH}")
    endif()
    add_library(${BCG_LIB} SHARED IMPORTED)
    set_target_properties(${BCG_LIB} PROPERTIES IMPORTED_LOCATION "${BCG_LIB_PATH}")
endforeach()

target_link_libraries(samp
        log
        android
        EGL
        GLESv3
        opus
        shadowhook::shadowhook
        bass
        bass_fx
        bass_ssl
)

target_compile_options(samp PRIVATE
        -O3
        -Wall
        -Wextra
        -Wno-unused-parameter
        -fexceptions
        -fstack-protector-strong
        -pthread
        $<$<CONFIG:Debug>:-fvisibility=default>
        $<$<CONFIG:Release>:-fvisibility=hidden>
)
target_link_options(samp PRIVATE "-Wl,-z,max-page-size=16384")
