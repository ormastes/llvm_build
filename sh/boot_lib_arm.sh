set -v

source _pre.sh

#############################################################################################################################################
export COMPILER_FOLDER=""

export PROJECT=boot
export BIN_BUILD=0
export ADDITIONAL_INCLUDE=../llvm-project/llvm/include
export LIBC_PATH=""


export TARGET_TRIPLE=${ARM_BAREMETAL_TARGET_TRIPLE}
export HOST_TRIPLE_SETTING="-DLLVM_HOST_TRIPLE=${LINUX_TARGET_TRIPLE} "
export TARGET_SETTING="-DLLVM_TARGETS_TO_BUILD=${ARM_CORE}"

export PICOLIB=1
export LIB_BASE=/usr/local/picolibc
export INC_BASE=/usr/local/picolibc
export LLVM_LIB=0
export LLVM_LIB_BASE=
export LLVM_INC_BASE=

export COMPILER=$ARM_GCC
export IS_GCC=1

export IS_BAREMETAL=1

export IS_LLD=1

export IS_LIBC=0

#############################################################################################################################################

source _post.sh

############################################################################################################################################

mkdir $INSTALL_DIR
rm -rf $BUILD_DIR
rm $BUILD_DIR/CMakeCache.txt
mkdir $BUILD_DIR
pushd $BUILD_DIR

#    -DLLVM_ENABLE_PROJECTS="libc;compiler-rt;clang;lld;lldb;clang-tools-extra" \
#   -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" 


#   -fprofile-instr-generate=${GEN_FOLDER}/code-$(date +%Y-%m-%d-%H-%M-%S)-$$.profraw

set -x  # Echo the next command and then run it

cmake ../../llvm-project/${CMAKE_START_MODULE}  --fresh \
   -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_INCLUDE_TESTS=FALSE  \
   -DLLVM_ENABLE_RUNTIMES="compiler-rt;libcxx;libcxxabi" \
   ${TRIPLE_SETTING} \
   ${TARGET_SETTING} \
   ${BUILD_FIX_SETTING} \
   ${COMMON} \
   -DCMAKE_C_FLAGS="${FLAG}" \
   -DCMAKE_CXX_FLAGS="${FLAG}" \
   -DCMAKE_ASM_FLAGS="${FLAG}" \
   -DCMAKE_STATIC_LINKER_FLAGS="${LINK_FLAG}" -DCMAKE_EXE_LINKER_FLAGS="${LINK_EXE_FLAG}" \
   ${ENABLE_STATIC} \
   ${COMPILER_SETTING} \
   ${CLANG_RT_SETTING} \
   ${LIBUNWIND_OFF} \
   ${LIBCXX_WITHOUT_UNWIND} \
   ${EMBEDDIG_LIB_SETTING} ${RT_STANDALONE} ${RT_INSTALL} ${LIBCXX_INSTALL} \
   ${LINKER_SETTING} \
   ${LIBC_SETTING} 

   
set +x  # Turn off command echoing after running the above command (optional)
cmake --build . -j 32
cmake --build . --target install
popd

 cp /usr/local/picolibc -r ../install/boot/lib