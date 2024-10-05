set -v



export LINUX_TARGET_TRIPLE=x86_64-unknown-linux-gnu
export WIN_MSVC_TARGET_TRIPLE=x86_64-pc-windows-msvc
export WIN_MINGW_TARGET_TRIPLE=x86_64-w64-mingw32
export ARM_BAREMETAL_TARGET_TRIPLE=arm-none-eabi
export RISCV_BAREMETAL_TARGET_TRIPLE=riscv32-unknown-elf

export X86_CORE=X86
export ARM_CORE=ARM
export RISCV_CORE=RISCV
export X86_ARM_RISCV_CORE="X86;ARM;RISCV"

#############################################################################################################################################
export COMPILER_FOLDER=''

export PROJECT=baremetal_riscv
export BIN_BUILD=0
export ADDITIONAL_INCLUDE=../llvm-project/llvm/include

export TARGET_TRIPLE=${RISCV_BAREMETAL_TARGET_TRIPLE}
export COMPILER_RT_OS="-DCOMPILER_RT_OS_DIR=baremetal"
export FLAG="--target=${ARM_BAREMETAL_TARGET_TRIPLE}"
export HOST_TRIPLE_SETTING="-DLLVM_HOST_TRIPLE=${LINUX_TARGET_TRIPLE} "
export TARGET_SETTING="-DLLVM_TARGETS_TO_BUILD=${RISCV_CORE}"


#############################################################################################################################################
FILENAME=$(basename "$0")
FILENAME_WO_EXT="_${FILENAME%.*}"

# to full path
export COMPILER_FOLDER=$(realpath $COMPILER_FOLDER)

export INSTALL_DIR=../install/${PROJECT}

mkdir $INSTALL_DIR
export BUILD_DIR=../${FILENAME_WO_EXT}_build

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
pushd $BUILD_DIR

if [ $BIN_BUILD -eq 1 ]; then
    export CMAKE_START_MODULE="llvm"
else
    export CMAKE_START_MODULE="runtimes"
    export COMMON=$COMPILER_RT_OS
fi
if [ $IS_BAREMETAL -eq 1 ]; then
    export BAREMETAL_SETTING="-DLIBCXXABI_BAREMETAL=ON -DLIBCXX_BAREMETAL=ON  \
     -DLIBCXX_USE_COMPILER_RT=ON -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_THREADS=OFF -DLIBCXX_ENABLE_MONOTONIC_CLOCK=OFF -DLIBCXXABI_USE_LLVM_UNWINDER=ON -DLIBCXX_CXX_ABI=libcxxabi -DLIBCXX_ENABLE_FILESYSTEM=OFF \
     -DLIBCXXABI_ENABLE_THREADS=OFF -DLIBCXXABI_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXXABI_USE_COMPILER_RT=ON -DLIBCXXABI_ENABLE_EXCEPTIONS=ON "
fi

export TARGET_TRIPLE_SETTING="-DLLVM_DEFAULT_TARGET_TRIPLE=${TARGET_TRIPLE} -DLIBC_TARGET_TRIPLE=${TARGET_TRIPLE} "
export COMPILER_TRIPLE_SETTING="-DCMAKE_C_COMPILER_TARGET=${TARGET_TRIPLE} -DCMAKE_CXX_COMPILER_TARGET=${TARGET_TRIPLE} "
export RUNTIME_TRIPLE_SETTING="-DLLVM_RUNTIME_TARGETS=${TARGET_TRIPLE} "
export TRIPLE_SETTING="${HOST_TRIPLE_SETTING} ${TARGET_TRIPLE_SETTING} ${COMPILER_TRIPLE_SETTING} ${RUNTIME_TRIPLE_SETTING} "

export LLVM_ENABLE_LLD="-DLLVM_ENABLE_LLD=ON "  # same as -DCLANG_DEFAULT_LINKER=lld but ensure lld built before second stage link.
export LLD_SETTING="${LLVM_ENABLE_LLD}"
export LINK_FLAG="" # -threads need LLD enable

if [ -z "$COMPILER_FOLDER" ]; then
    export COMPILER_SETTING="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ "
    export LIB_INCLUDE_SETTING=""
    #export LIKER_SETTING="-DCLANG_DEFAULT_LINKER=lld"
    export COMMON="-G Ninja -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR $COMMON "

else
    COMPILER_BIN_FOLDER=$COMPILER_FOLDER/bin
    export CC=${COMPILER_BIN_FOLDER}/clang
    export CXX=${COMPILER_BIN_FOLDER}/clang++
    export COMPILER_SETTING="-DCMAKE_SYSROOT=$COMPILER_FOLDER -DCMAKE_C_COMPILER=${COMPILER_BIN_FOLDER}/clang \
        -DCMAKE_CXX_COMPILER=${COMPILER_BIN_FOLDER}/clang++ -DCMAKE_ASM_COMPILER=${COMPILER_BIN_FOLDER}/clang \
        -DCMAKE_AR=${COMPILER_BIN_FOLDER}/llvm-ar -DCMAKE_RANLIB=${COMPILER_BIN_FOLDER}/llvm-ranlib -DCMAKE_LINKER=${COMPILER_BIN_FOLDER}/lld \
        -DCMAKE_CXX_COMPILER_ID=Clang -DCMAKE_C_COMPILER_ID=Clang "

    export LD_LIBRARY_PATH=${COMPILER_FOLDER}/lib
    export LIB_INCLUDE_SETTING=" 
        -DLLVM_INCLUDE_DIRS=${COMPILER_FOLDER}/${TARGET_TRIPLE}/include/c++/v1;${COMPILER_FOLDER}/include;${COMPILER_FOLDER}/include/c++/v1;/usr/include;${ADDITIONAL_INCLUDE} "
    export COMMON="-G Ninja -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR $COMMON "
    export LINK_FLAG="${LINK_FLAG} -Wl,-stdlib=libc++ -Wl,-lc++abi "

fi

export LINK_EXE_FLAG="-fuse-ld=lld  -Wl,--threads=8 ${LINK_FLAG}" # -threads need LLD enable


export EXCEPTION_OFF=" \
    -DLLVM_ENABLE_EH=OFF \
    -DCOMPILER_RT_USE_LLVM_UNWINDER=OFF \
    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
    -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
    -DCOMPILER_RT_HAS_FNO_EXCEPTIONS_FLAG=OFF -DASAN_HAS_EXCEPTIONS=OFF -DXRAY_HAS_EXCEPTIONS=OFF -DBENCHMARK_ENABLE_EXCEPTIONS=OFF \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF -DCOMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF "


export COMPILER_RT_BAREMETAL="-DCOMPILER_RT_BUILD_BUILTINS=ON \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    -DCOMPILER_RT_BAREMETAL_BUILD=ON \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON "


export LIBCXX_WITHOUT_UNWIND=${EXCEPTION_OFF}

#    -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=OFF \
#    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \

export LIBGCC_SETTING=" \
    -DLLVM_LIBGCC_EXPLICIT_OPT_IN=Yes \
    -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF \
    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
    -DCOMPILER_RT_BUILTINS_HIDE_SYMBOLS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_MEMPROF=OFF \
    -DCOMPILER_RT_BUILD_ORC=OFF \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF "
export ENABLE_STATIC="-DLIBCXXABI_ENABLE_STATIC=ON -DLIBCXX_ENABLE_STATIC=ON -DCOMPILER_RT_STATIC_CXX_LIBRARY=ON \
    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY "
export LIBC_COMPILER_RT_SETTING=" \
    -DCOMPILER_RT_BUILD_SCUDO_STANDALONE_WITH_LLVM_LIBC=ON \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
    -DCOMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF"
# delete crti and crtn from cmakefile llvm/libc/startup/CMakeLists.txt
# set(startup_components crt1 crti crtn) >> set(startup_components crt1)
export LIBC_SETTING="\
    -DLLVM_LIBC_FULL_BUILD=ON \
    -DLLVM_LIBC_INCLUDE_SCUDO=ON \
    -DLIBC_INCLUDE_DOCS=ON"
export LIBUNWIND_OFF_SETTING=" -DLLVM_ENABLE_SPHINX=ON -DLIBUNWIND_INCLUDE_DOCS=OFF"  # pip install sphinx  
export VERBOSE_SETTING="-DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DLIBC_CMAKE_VERBOSE_LOGGING=ON"
export DEBUG_SETTING="-Wdev, --debug-output --trace"
#"-DLLVM_ENABLE_SPHINX=ON"
#export LIBC_CLANG_SETTING="-DCLANG_DEFAULT_RTLIB=compiler-rt"

# libc > LLVM_ENABLE_PROJECTS::compiler-rt
# both libc and compiler-rt should be on LLVM_ENABLE_PROJECTS. currently, header file setup is not set properly with runtimes.

# libc/CMakelists.txt >   INCLUDE_DIRECTORIES "${LLVM_INCLUDE_DIR} ${LLVM_MAIN_INCLUDE_DIR}" line 20 should be added

# https://www.collabora.com/news-and-blog/blog/2023/01/17/a-brave-new-world-building-glibc-with-llvm/
# glibc -> compiler-rt -> glibc
# glibc -> llvm-libunwind -> glibc
# compiler-rt -> libxcrypt -> glibc -> compiler-rt
# compiler-rt -> libcxx -> llvm-libunwind -> glibc -> compiler-rt
#
# 1. Install headers for libxcrypt, glibc, and linux kernel
# 2. Build compiler-rt without sanitizers for required builtins
# 3. Build glibc with -unwindlib=none
# 4. Build llvm-libunwind
# 5. Build full glibc against libunwind
# 6. Build libcxx
# 7. Build full compiler-rt against glibc and libcxx


# https://gist.github.com/nidefawl/80e5677c224d45bcae2c36fa3b173d01

#    -DLLVM_STATIC_LINK_CXX_STDLIB=OFF 

############################################################################################################################################


#    -DLLVM_ENABLE_PROJECTS="libc;compiler-rt;clang;lld" 
#   -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" 

export BUILD_FIX_SETTING="-DLIBCXX_INCLUDE_BENCHMARKS=OFF -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
-DLLVM_LIBSTDCXX_MIN=ON -DLLVM_LIBSTDCXX_SOFT_ERROR=ON -DHAVE_CXX_ATOMICS_WITH_LIB=ON -DHAVE_CXX_ATOMICS64_WITH_LIB=ON -D_WCHAR_H_CPLUSPLUS_98_CONFORMANCE_=ON"
#export LIB_INCLUDE_SETTING=" -DLLVM_INCLUDE_DIRS=../llvm-project/llvm/include " # libc build bug fix
# when build runtime with projects options not sent properly.

# embedded build for libc++ https://llvm.org/devmtg/2020-09/slides/Qadeer-LLVM_in_a_Bare_Metal_Environment.pdf

set -x  # Echo the next command and then run it
cmake ../llvm-project/${CMAKE_START_MODULE}  \
   -DCMAKE_BUILD_TYPE=Release -DLLVM_INCLUDE_TESTS=FALSE  \
   -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
   ${TRIPLE_SETTING} \
   ${TARGET_SETTING} \
   ${BUILD_FIX_SETTING} \
   ${COMMON} \
   -DCMAKE_C_FLAGS=${FLAG} -DCMAKE_CXX_FLAGS=${FLAG} -DCMAKE_ASM_FLAGS=${FLAG} \
   -DCMAKE_STATIC_LINKER_FLAGS="${LINK_FLAG}" -DCMAKE_EXE_LINKER_FLAGS="${LINK_EXE_FLAG}" \
   ${ENABLE_STATIC} \
   ${BAREMETAL_SETTING} \
   ${COMPILER_SETTING} \
   ${LIB_INCLUDE_SETTING} \
   ${LIBUNWIND_OFF_SETTING} \
   ${LIBCXX_WITHOUT_UNWIND} \
   ${LLD_SETTING} ${LIKER_SETTING} \
   ${LIBC_CLANG_SETTING} 
set +x  # Turn off command echoing after running the above command (optional)
cmake --build . -j 32
cmake --build . --target install
popd

