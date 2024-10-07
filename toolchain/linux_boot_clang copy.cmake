# default clang setting

set(LANG C)
set(MY_LLVM_PATH "/home/ormastes/dev/llvm")
set(COMPILER_PATH "${MY_LLVM_PATH}/install/boot")
set(COMPILER_FOLDER ${COMPILER_PATH})
set(SYSROOT "${MY_LLVM_PATH}/install/boot")
set(TARGET_TRIPLE "x86_64-unknown-linux-gnu")

set(LIB "")
set(OS_INCLUDE "-isystem /usr/local/include -isystem /usr/include/x86_64-linux-gnu -isystem /usr/include")
set(CLANG_INCLUDE "-isystem /usr/lib/llvm-18/lib/clang/18/include")
set(COMPILER_BIN_FOLDER "${COMPILER_PATH}/bin")
set(CMAKE_INSTALL_LIBDIR "${COMPILER_PATH}/lib")
set(Clang_DIR "/usr/lib/cmake/clang")
set(LLVM_DIR "/usr/lib/cmake/llvm")
set(ENV{PATH} "${COMPILER_BIN_FOLDER}:$ENV{PATH}")
set(CC "${COMPILER_BIN_FOLDER}/clang")
set(CXX "${COMPILER_BIN_FOLDER}/clang++")
set(ASM "${COMPILER_BIN_FOLDER}/clang")
set(AR "${COMPILER_BIN_FOLDER}/llvm-ar")
set(RANLIB "${COMPILER_BIN_FOLDER}/llvm-ranlib")
set(LINKER "${COMPILER_BIN_FOLDER}/ld.lld")
set(INCLUDE_PATH "-isystem ${COMPILER_FOLDER}/include/${TARGET_TRIPLE}/c++/v1 -isystem ${COMPILER_FOLDER}/include -isystem ${COMPILER_FOLDER}/include/c++/v1"  )
set(FLAG " ${INCLUDE_PATH} -I${MY_LLVM_PATH}/llvm-project/llvm/include ")
set(OS_LINKPATH " -Wl,-L/usr/lib/gcc/x86_64-linux-gnu/12 -Wl,-L/usr/lib64 \
      -Wl,-L/lib/x86_64-linux-gnu -Wl,-L/lib64 -Wl,-L/usr/lib/x86_64-linux-gnu -Wl,-L/usr/lib64 -Wl,-L/lib -Wl,-L/usr/lib")
set(CLANG_LIB "-stdlib=libc++ -rtlib=compiler-rt")
set(LINK_FLAG " " )
# -static ${CLANG_LINK_PATH} -Wl,-L${COMPILER_FOLDER}/lib -Wl,-rpath,${COMPILER_FOLDER}/lib ${OS_LINKPATH} ${LIB} 
set(LINK_NO_STATIC_FLAG "-fuse-ld=lld  -Wl,--threads=8")
set(LLVM_ENABLE_LLD ON )
set(CMAKE_CXX_COMPILER_ID "Clang")
set(CMAKE_C_COMPILER_ID "Clang")
set(CMAKE_ASM_COMPILER_ID "Clang")
set(CMAKE_AR_ID "LLVM")
set(CMAKE_RANLIB_ID "LLVM")
set(CMAKE_LINKER_ID "LLD")
set(CMAKE_SYSROOT "${SYSROOT}")
set(CMAKE_C_COMPILER "${CC}")
set(CMAKE_CXX_COMPILER "${CXX}")
set(CMAKE_ASM_COMPILER "${ASM}")
set(CMAKE_AR "${AR}")
set(CMAKE_RANLIB "${RANLIB}")
set(CMAKE_LINKER "${LINKER}")
set(CMAKE_CXX_FLAGS "${FLAG}")
set(CMAKE_C_FLAGS "${FLAG}")
set(CMAKE_ASM_FLAGS "${FLAG}")
set(CMAKE_EXE_LINKER_FLAGS "${LINK_NO_STATIC_FLAG}")
set(CMAKE_SHARED_LINKER_FLAGS "${LINK_NO_STATIC_FLAG}")
set(CMAKE_MODULE_LINKER_FLAGS "${LINK_NO_STATIC_FLAG}")
set(CMAKE_STATIC_LINKER_FLAGS "${LINK_FLAGS}")

