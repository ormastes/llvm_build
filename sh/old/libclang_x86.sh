pushd ../build
#   -DCMAKE_SYSROOT=$SYSROOT \
SYSROOT=/usr/local/common/bin/llvm_linux-18.1.8
FLAG="-I/usr/include"
#export LD=ld.lld
export CC=gcc
export CXX=g++
export CXXFLAG="-I/usr/include"
export CFLAG="-I/usr/include"
cmake ../llvm-project/llvm  \
   -G Ninja  \
   -DLLVM_TARGETS_TO_BUILD="X86;ARM;RISCV" \
   -DCMAKE_BUILD_TYPE=Release  \
   -DLLVM_ENABLE_PROJECTS="all" \
   -DLLVM_ENABLE_RUNTIMES="all"  \
   -DCMAKE_CXX_FLAGS=${FLAG} -DCMAKE_C_FLAGS=${FLAG} \
   -DCMAKE_C_COMPILER=clang \
   -DCMAKE_CXX_COMPILER=clang++ \
       -DLLVM_LIBGCC_EXPLICIT_OPT_IN=ON \
   -DLLVM_ENABLE_RTTI=OFF \
      -DLLVM_ENABLE_EH=OFF \
      -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
      -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
      -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
   -DCLANG_DEFAULT_LINKER=lld \
   -DCLANG_DEFAULT_RTLIB=compiler-rt \
   -DCMAKE_INSTALL_PREFIX=$SYSROOT
cmake --build . -j 37
cmake --build . --target install
popd

