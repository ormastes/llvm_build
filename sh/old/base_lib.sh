set -v

export COMPILER_FOLDER=''

#############################################################################################################################################

export LLVM_ENABLE_LLD="-DLLVM_ENABLE_LLD=ON "  # same as -DCLANG_DEFAULT_LINKER=lld but ensure lld built before second stage link.
export LLD_SETTING="${LLVM_ENABLE_LLD}"
export LINK_FLAG="-Wl,--threads=8" # -threads need LLD enable
export LINK_SETTING="-DCMAKE_STATIC_LINKER_FLAGS='${LINK_FLAG}' -DCMAKE_EXE_LINKER_FLAGS='${LINK_FLAG}' "


if [ $COMPILER_FOLDER=='' ]; then
    export COMPILER_SETTING="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ "
    export LIB_INCLUDE_SETTING=""
    #export LIKER_SETTING="-DCLANG_DEFAULT_LINKER=lld"
    export COMMON="-G Ninja -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR "
else
    COMPILER_BIN_FOLDER=$COMPILER_FOLDER/bin
    export COMPILER_SETTING="-DCMAKE_C_COMPILER=${COMPILER_BIN_FOLDER}/clang -DCMAKE_CXX_COMPILER=${COMPILER_BIN_FOLDER}/clang++ -DCMAKE_ASM_COMPILER=${COMPILER_BIN_FOLDER}/clang \
        -DCMAKE_AR=${COMPILER_BIN_FOLDER}/llvm-ar -DCMAKE_RANLIB=${COMPILER_BIN_FOLDER}/llvm-ranlib -DCMAKE_LINKER=${COMPILER_BIN_FOLDER}/lld "
    #export LIKER_SETTING="-DCLANG_DEFAULT_LINKER=lld"
    export LIB_INCLUDE_SETTING=" \
        -DCMAKE_LIBRARY_PATH=${COMPILER_FOLDER}/lib \
        -DCMAKE_INCLUDE_PATH=${COMPILER_FOLDER}/include"
    export COMMON="-G Ninja -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR "
fi

export EXCEPTION_OFF=" \
    -DLLVM_ENABLE_EH=OFF \
    -DCOMPILER_RT_USE_LLVM_UNWINDER=OFF \
    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
    -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
    -DCOMPILER_RT_HAS_FNO_EXCEPTIONS_FLAG=OFF -DASAN_HAS_EXCEPTIONS=OFF -DXRAY_HAS_EXCEPTIONS=OFF -DBENCHMARK_ENABLE_EXCEPTIONS=OFF "


export X86_CORE=X86
export X86_ARM_RISCV_CORE="X86;ARM;RISCV"

export LIBCXX_WITHOUT_UNWIND=${EXCEPTION_OFF}

#    -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=OFF \
#    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \

export LIBGCC_SETTING=" \
    -DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-unknown-linux-gnu \
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
export ENABLE_STATIC="-DLIBCXXABI_ENABLE_STATIC=ON -DLIBCXX_ENABLE_STATIC=ON -DCOMPILER_RT_STATIC_CXX_LIBRARY=ON "
export LIBC_COMPILER_RT_SETTING=" \
    -DCOMPILER_RT_BUILD_SCUDO_STANDALONE_WITH_LLVM_LIBC=ON \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
    -DCOMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF"
export LIBC_SETTING="\
    -DLLVM_LIBC_FULL_BUILD=ON \
    -DLLVM_LIBC_INCLUDE_SCUDO=ON"
export LIBUNWIND_SETTING=" -DLLVM_ENABLE_SPHINX=ON -DLIBUNWIND_INCLUDE_DOCS=ON"  # pip install sphinx  
export LIBC_LLVM=
#"-DLLVM_ENABLE_SPHINX=ON"
#export LIBC_CLANG_SETTING="-DCLANG_DEFAULT_RTLIB=compiler-rt"

# libc > LLVM_ENABLE_PROJECTS::compiler-rt
# both libc and compiler-rt should be on LLVM_ENABLE_PROJECTS. currently, header file setup is not set properly with runtimes.

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


#    -DLLVM_ENABLE_PROJECTS="libc;compiler-rt;clang;lld" \
#   -DLLVM_ENABLE_RUNTIMES="llvm-libgcc;libcxx;libcxxabi" \
#    -DCLANG_DEFAULT_LINKER=lld \-DCLANG_DEFAULT_CXX_STDLIB=libc++ \-DLLVM_ENABLE_LIBCXX=ON \
#    -DCLANG_DEFAULT_RTLIB=compiler-rt    -DLIBCXX_USE_COMPILER_RT=ON -DLIBCXXABI_USE_COMPILER_RT=ON \
#    -DLLVM_BUILD_TOOLS=ON \
#    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
#    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
#    -DLLVM_TARGETS_TO_BUILD=X86 \
#    -DCMAKE_CROSSCOMPILING=OFF \
#    -DCMAKE_SYSTEM_NAME="Linux" \
#    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-unknown-linux-gnu" \
#    -DLLVM_HOST_TRIPLE="x86_64-unknown-linux-gnu" \
#    -DCMAKE_C_COMPILER_TARGET="x86_64-unknown-linux-gnu" \
#    -DCMAKE_CXX_COMPILER_TARGET="x86_64-unknown-linux-gnu" \
#    -DLLVM_BUILD_TOOLS=ON \
 #    -DLLVM_USE_RELATIVE_PATHS_IN_DEBUG_INFO=ON \
#    -DSANITIZER_CXX_ABI=libcxxabi \

#    -DLIBUNWIND_USE_COMPILER_RT=ON \
#    -DLIBUNWIND_ENABLE_STATIC=ON \


############################################################################################################################################

export PROJECT=base

export BUILD_DIR=../${PROJECT}_build
export INSTALL_DIR=../install/${PROJECT}
export TARGET_SETTING="-DLLVM_TARGETS_TO_BUILD=${X86_ARM_RISCV_CORE}"

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
# rm -rf $INSTALL_DIR
mkdir $INSTALL_DIR
pushd $BUILD_DIR

#    -DLLVM_ENABLE_PROJECTS="libc;compiler-rt;clang;lld" 
#   -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" 

cmake ../llvm-project/runtimes  \
   -DCMAKE_BUILD_TYPE=Release -DLLVM_INCLUDE_TESTS=FALSE \
   -DLLVM_ENABLE_RUNTIMES="libc;compiler-rt;libcxx;libcxxabi;libunwind"  \
   ${TARGET_SETTING} \
   ${COMMON} \
   ${ENABLE_STATIC} \
   ${COMPILER_SETTING} \
   ${LIB_INCLUDE_SETTING} \
   ${LIBCXX_WITHOUT_UNWIND} \
   ${LIBC_LLVM} \
   ${LIBC_SETTING} \
   ${LIKER_SETTING} \
   ${LIBC_CLANG_SETTING} 

cmake --build . -j 32
popd

