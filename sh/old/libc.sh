set -v
export COMPILER_SETTING="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ "
#export LIKER_SETTING="-DCLANG_DEFAULT_LINKER=lld"
export COMMON="-G Ninja -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR "

export LIBC_COMPILER_RT_SETTING=" \
    -DCOMPILER_RT_BUILD_SCUDO_STANDALONE_WITH_LLVM_LIBC=ON \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
    -DCOMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF"
export LIBC_SETTING="\
    -DLLVM_LIBC_FULL_BUILD=ON \
    -DLLVM_LIBC_INCLUDE_SCUDO=ON"
export LIBC_LLVM=
#"-DLLVM_ENABLE_SPHINX=ON"
#export LIBC_CLANG_SETTING="-DCLANG_DEFAULT_RTLIB=compiler-rt"

# libc > LLVM_ENABLE_PROJECTS::compiler-rt
# both libc and compiler-rt should be on LLVM_ENABLE_PROJECTS. currently, header file setup is not set properly with runtimes.

export PROJECT=libc

export BUILD_DIR=${PROJECT}_build
export INSTALL_DIR=${PROJECT}_install

rm -rf ../$BUILD_DIR
mkdir ../$BUILD_DIR
pushd ../$BUILD_DIR

cmake ../llvm-project/llvm  \
   -DCMAKE_BUILD_TYPE=Debug -DLLVM_INCLUDE_TESTS=FALSE \
   -DLLVM_ENABLE_PROJECTS="libc;compiler-rt" \
   ${COMMON} \
   ${COMPILER_SETTING} \
   ${LIBC_LLVM} \
   ${LIBC_SETTING} \
   ${LIBC_COMPILER_RT_SETTING}       \
   ${LIKER_SETTING} \
   ${LIBC_CLANG_SETTING} 

cmake --build . -j 30
popd

