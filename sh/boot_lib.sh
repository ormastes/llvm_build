set -v

source _pre.sh

#############################################################################################################################################
export COMPILER_FOLDER=""

export PROJECT=boot
export BIN_BUILD=0
export ADDITIONAL_INCLUDE=../llvm-project/llvm/include
export LIBC_PATH=""


export TARGET_TRIPLE=${LINUX_TARGET_TRIPLE}
export HOST_TRIPLE_SETTING="-DLLVM_HOST_TRIPLE=${LINUX_TARGET_TRIPLE} "
export TARGET_SETTING="-DLLVM_TARGETS_TO_BUILD=${X86_ARM_RISCV_CORE}"

export PICOLIB=0
export LIB_BASE=
export INC_BASE=
export LLVM_LIB=0
export LLVM_LIB_BASE=
export LLVM_INC_BASE=

export COMPILER=$INSTALLED_CLANG
export IS_GCC=1

export IS_BAREMETAL=0

export IS_LLD=0

export IS_LIBC=1

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

cmake ../../llvm-project/${CMAKE_START_MODULE} -DCMAKE_TOOLCHAIN_FILE=../../toolchain/linux_system_clang_nolld.cmake --fresh \
   -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_INCLUDE_TESTS=FALSE \
   -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" \
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
   ${LLDB_SETTING} \
   ${EMBEDDIG_LIB_SETTING} ${RT_STANDALONE} ${RT_INSTALL} ${RPATH_INSTALL} ${LIBCXX_INSTALL} \
   ${LINKER_SETTING} \
   ${LIBC_SETTING} 

   
set +x  # Turn off command echoing after running the above command (optional)
cmake --build . -j 32
cmake --build . --target install
popd

