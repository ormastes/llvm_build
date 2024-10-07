FROM ubuntu:24.04

WORKDIR /workspace
USER root

# assume keys directory has instKeys.sh file which install ssh key
# assume make_users.sh make users 
# you can remove next 3 lines
COPY keys/ /workspace/keys
RUN cd /workspace/keys && chmod 777 instKey.sh && ./instKey.sh
RUN cd /workspace/keys/users && chmod 777 make_users.sh && ./make_users.sh

RUN apt update
RUN apt upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt install -y curl git software-properties-common apt-transport-https wget 


# install code
RUN DEBIAN_FRONTEND=noninteractive wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add -
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
RUN apt update -y
RUN apt install code -y

# it need interactive input. I don't know how it to automate it.
#RUN cd /workspace && curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz
#RUN cd /workspace && tar -xf vscode_cli.tar.gz
# code tunnel user login --provider <provider>
# --no-sandbox --user-data-dir /root/.code 
RUN cd /workspace && code tunnel rename build

# install basic tools
RUN DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common openssh-server net-tools 
RUN DEBIAN_FRONTEND=noninteractive apt install -y autoconf automake autotools-dev python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat1-dev ninja-build python3 python3-pip python3-setuptools  python3-wheel ninja-build python3-full
RUN DEBIAN_FRONTEND=noninteractive apt install -y cmake libmimalloc-dev vim 

RUN pip install --break-system-packages sphinx 

RUN mkdir /workspace/downloads

# install llvm-mingw
RUN cd /workspace/downloads && git clone --depth 1 --branch 20241001 https://github.com/mstorsjo/llvm-mingw
RUN cd /workspace/downloads/llvm-mingw && ./build-all.sh ../llvm-mingw-build

# riscv gcc compiler
RUN cd /workspace/downloads && git clone --depth 1 --branch 2024.09.03 https://github.com/riscv/riscv-gnu-toolchain
RUN mkdir /workspace/downloads/riscv-gnu-toolchain/build
RUN cd /workspace/downloads/riscv-gnu-toolchain/build && ../configure --with-arch=rv32imac --with-abi=ilp32
RUN cd /workspace/downloads/riscv-gnu-toolchain/build && make -j$(nproc)

# arm gcc compiler
RUN DEBIAN_FRONTEND=noninteractive apt install -y gcc-arm-none-eabi 

RUN cd /workspace/downloads && wget https://apt.llvm.org/llvm.sh
ENV LLVM_VERSION=18
RUN cd /workspace/downloads && chmod +x llvm.sh
RUN /workspace/downloads/llvm.sh ${LLVM_VERSION}
RUN apt update
RUN apt-get install -y clang-format clang-tidy clang-tools clang clangd libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python3-clang python3-llvmlite
RUN apt-get install -y libllvm-${LLVM_VERSION}-ocaml-dev libllvm${LLVM_VERSION} llvm-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-doc llvm-${LLVM_VERSION}-examples llvm-${LLVM_VERSION}-runtime clang-${LLVM_VERSION} clang-tools-${LLVM_VERSION} clang-${LLVM_VERSION}-doc libclang-common-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev libclang1-${LLVM_VERSION} clang-format-${LLVM_VERSION} python3-clang-${LLVM_VERSION} clangd-${LLVM_VERSION} clang-tidy-${LLVM_VERSION} 
RUN apt-get install -y libclang-rt-${LLVM_VERSION}-dev libpolly-${LLVM_VERSION}-dev libfuzzer-${LLVM_VERSION}-dev lldb-${LLVM_VERSION} lld-${LLVM_VERSION}  libc++-${LLVM_VERSION}-dev libc++abi-${LLVM_VERSION}-dev libomp-${LLVM_VERSION}-dev  libclc-${LLVM_VERSION}-dev  libunwind-${LLVM_VERSION}-dev  libmlir-${LLVM_VERSION}-dev mlir-${LLVM_VERSION}-tools  libbolt-${LLVM_VERSION}-dev bolt-${LLVM_VERSION} flang-${LLVM_VERSION} 
RUN apt-get install -y libclang-rt-${LLVM_VERSION}-dev-wasm32 libclang-rt-${LLVM_VERSION}-dev-wasm64 libc++-${LLVM_VERSION}-dev-wasm32 libc++abi-${LLVM_VERSION}-dev-wasm32 libclang-rt-${LLVM_VERSION}-dev-wasm32 libclang-rt-${LLVM_VERSION}-dev-wasm64
RUN
RUN apt upgrade -y

# arm riscv libc (picolibc)
RUN pip3 install --break-system-packages meson
RUN cd /workspace/downloads &&  git clone  --depth 1 --branch 1.8.8-1 https://github.com/picolibc/picolibc.git
COPY picolibc_cross_file/cross-arm-none-eabi.txt /workspace/downloads/picolibc/cross-arm-none-eabi.txt
COPY picolibc_cross_file/cross-riscv32-unknown-elf.txt /workspace/downloads/picolibc/cross-riscv32-unknown-elf.txt
RUN cd /workspace/downloads/picolibc &&  meson build_arm -Dincludedir=picolibc/arm-none-eabi/include -Dlibdir=picolibc/arm-none-eabi/lib --cross-file cross-arm-none-eabi.txt
RUN cd /workspace/downloads/picolibc/build_arm && ninja
RUN cd /workspace/downloads/picolibc/build_arm && ninja install
RUN cd /workspace/downloads/picolibc &&  meson build_riscv -Dincludedir=picolibc/riscv32-unknown-elf/include -Dlibdir=picolibc/riscv32-unknown-elf/lib --cross-file cross-riscv32-unknown-elf.txt
RUN cd /workspace/downloads/picolibc/build_riscv && ninja
RUN cd /workspace/downloads/picolibc/build_riscv && ninja install

RUN git config --global user.email "ormastes@gmail.com"
RUN git config --global user.name "Jonghyun Yoon"

COPY run_code.sh /workspace/run_code.sh
RUN cd /workspace && chmod 777 run_code.sh

# --no-sleep --server-data-dir /root/.code --extensions-dir /root/.code/ext --cli-data-dir /root/.code/cli
#RUN code tunnel --install-extension ms-vscode.cmake-tools   --install-extension ms-vscode.cpptools-extension-pack --install-extension ms-azuretools.vscode-docker --install-extension llvm-vs-code-extensions.vscode-clangd --install-extension mads-hartmann.bash-ide-vscode --install-extension github.copilot --install-extension github.copilot-chat \
# --install-extension ms-vscode-remote.remote-containers --install-extension DavidAnson.vscode-markdownlint --install-extension vadimcn.vscode-lldb --install-extension redhat.vscode-xml --install-extension tamasfe.even-better-toml --install-extension rust-lang.rust-analyzer --install-extension ms-python.python --install-extension ms-python.debugpy


# Setup default command and/or parameters.
EXPOSE 22
#CMD ["/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]
