apt -y install  gcc-arm-none-eabi autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build
mkdir build
mkdir build/riscv
mkdir build/arm
mkdir arm-gnu-toolchain

git clone https://github.com/riscv/riscv-gnu-toolchain
wget https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/srcrel/arm-gnu-toolchain-src-snapshot-13.3.rel1.tar.xz


pushd build
pushd riscv
#rv32imac/ilp32
../../riscv-gnu-toolchain/configure --with-arch=rv32imac --with-abi=ilp32
make -j$(nproc)
popd

pushd arm
# 32-bit ARM
../../arm-gnu-toolchain/gcc/configure --target=arm-none-eabi --enable-multilib --with-newlib 
make -j$(nproc)
../../arm-gnu-toolchain/gcc/configure --target=arm-none-eabi --enable-multilib --with-newlib 
popd
popd



export GCC_ARM_VERSION=13.3.rel1
wget https://developer.arm.com/-/media/Files/downloads/gnu/${GCC_ARM_VERSION}/binrel/arm-gnu-toolchain-${GCC_ARM_VERSION}-x86_64-arm-none-eabi.tar.xz

# for arm
sudo apt remove gcc-arm-none-eabi
# arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi.tar.xz
export GCC_ARM_VERSION=13.3.rel1
wget https://developer.arm.com/-/media/Files/downloads/gnu/${GCC_ARM_VERSION}/binrel/arm-gnu-toolchain-${GCC_ARM_VERSION}-x86_64-arm-none-eabi.tar.xz

sudo tar -xf arm-gnu-toolchain-${GCC_ARM_VERSION}-x86_64-arm-none-eabi.tar.xz 
sudo mv arm-gnu-toolchain-${GCC_ARM_VERSION}-x86_64-arm-none-eabi /usr/share/gcc-arm-none-eabi-${GCC_ARM_VERSION}

sudo ln -s /usr/share/gcc-arm-none-eabi-${GCC_ARM_VERSION}/bin/arm-none-eabi-gcc /usr/bin/arm-none-eabi-gcc 
sudo ln -s /usr/share/gcc-arm-none-eabi-${GCC_ARM_VERSION}/bin/arm-none-eabi-g++ /usr/bin/arm-none-eabi-g++
sudo ln -s /usr/share/gcc-arm-none-eabi-${GCC_ARM_VERSION}/bin/arm-none-eabi-gdb /usr/bin/arm-none-eabi-gdb
sudo ln -s /usr/share/gcc-arm-none-eabi-${GCC_ARM_VERSION}/bin/arm-none-eabi-size /usr/bin/arm-none-eabi-size
sudo ln -s /usr/share/gcc-arm-none-eabi-${GCC_ARM_VERSION}/bin/arm-none-eabi-objcopy /usr/bin/arm-none-eabi-objcopy
sudo ln -s /usr/share/gcc-arm-none-eabi-${GCC_ARM_VERSION}/bin/arm-none-eabi-ar /usr/bin/arm-none-eabi-ar
sudo ln -s /usr/share/gcc-arm-none-eabi-${GCC_ARM_VERSION}/bin/arm-none-eabi-as /usr/bin/arm-none-eabi-as
sudo ln -s /usr/share/gcc-arm-none-eabi-${GCC_ARM_VERSION}/bin/arm-none-eabi-ld /usr/bin/arm-none-eabi-ld
sudo ln -s /usr/share/gcc-arm-none-eabi-${GCC_ARM_VERSION}/bin/arm-none-eabi-strip /usr/bin/arm-none-eabi-strip

