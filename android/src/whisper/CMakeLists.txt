cmake_minimum_required(VERSION 3.10)

project(whisper_flutter_library LANGUAGES C CXX)
set(CMAKE_CXX_STANDARD 20)

# Optimization flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -fdata-sections -ffunction-sections")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -fdata-sections -ffunction-sections")

include_directories(src)
include_directories(src/include)
include_directories(src/src)
include_directories(src/ggml/include)
include_directories(src/ggml/src)
include_directories(src/ggml/src/ggml-cpu)
include_directories(json)

# Whisper core
set(WHISPER_CORE_SRC
    src/src/whisper.cpp
)

# GGML core
file(GLOB GGML_CORE_SRC
    src/ggml/src/*.c
    src/ggml/src/*.cpp
)

# GGML-CPU core
file(GLOB GGML_CPU_SRC
    src/ggml/src/ggml-cpu/*.c
    src/ggml/src/ggml-cpu/*.cpp
)

# GGML-CPU arch-specific (ARM for Android)
file(GLOB GGML_CPU_ARCH_ARM_SRC
    src/ggml/src/ggml-cpu/arch/arm/*.c
    src/ggml/src/ggml-cpu/arch/arm/*.cpp
)

# x86 arch (for x86 Android emulators)
file(GLOB GGML_CPU_ARCH_X86_SRC
    src/ggml/src/ggml-cpu/arch/x86/*.c
    src/ggml/src/ggml-cpu/arch/x86/*.cpp
)

# AMX (Intel x86 only)
file(GLOB GGML_CPU_AMX_SRC
    src/ggml/src/ggml-cpu/amx/*.cpp
)

# Combine all sources
set(ALL_WHISPER_SRC
    ${WHISPER_CORE_SRC}
    ${GGML_CORE_SRC}
    ${GGML_CPU_SRC}
    ${GGML_CPU_ARCH_ARM_SRC}
    ${GGML_CPU_ARCH_X86_SRC}
    ${GGML_CPU_AMX_SRC}
)

add_library(whisper ${ALL_WHISPER_SRC})

# Architecture-specific compiler flags
if (${ANDROID_ABI} STREQUAL "arm64-v8a")
    target_compile_options(whisper PRIVATE -march=armv8.2-a+fp16)
elseif (${ANDROID_ABI} STREQUAL "armeabi-v7a")
    target_compile_options(whisper PRIVATE -mfpu=neon-vfpv4)
endif ()


add_library(whisper_flutter SHARED main.cpp)
target_link_libraries(whisper_flutter PRIVATE whisper log)
target_compile_definitions(whisper_flutter PUBLIC DART_SHARED_LIB)

set_target_properties(whisper_flutter PROPERTIES
    PUBLIC_HEADER src/include/whisper.h
    OUTPUT_NAME "whisper"
)

# Fix: whisper.cpp uses WHISPER_VERSION without including whisper-version.h
target_compile_options(whisper PRIVATE
    -include "${CMAKE_CURRENT_SOURCE_DIR}/src/include/whisper-version.h"
)

# Fix: main.cpp uses __android_log_print without including android/log.h  
target_compile_options(whisper_flutter PRIVATE
    -include android/log.h
)

# Fix: NDK applies -fvisibility=hidden by default; override for whisper_flutter
# so that extern "C" request() symbol is actually exported from libwhisper.so
target_compile_options(whisper_flutter PRIVATE -fvisibility=default)

