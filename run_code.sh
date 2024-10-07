#!/bin/bash
# --no-sandbox --user-data-dir /root/.code 
code tunnel --name develop --no-sleep --accept-server-license-terms \
 --install-extension ms-vscode.cmake-tools   --install-extension ms-vscode.cpptools-extension-pack --install-extension ms-azuretools.vscode-docker --install-extension llvm-vs-code-extensions.vscode-clangd --install-extension mads-hartmann.bash-ide-vscode --install-extension github.copilot --install-extension github.copilot-chat \
 --install-extension ms-vscode-remote.remote-containers --install-extension DavidAnson.vscode-markdownlint --install-extension vadimcn.vscode-lldb --install-extension redhat.vscode-xml --install-extension tamasfe.even-better-toml --install-extension rust-lang.rust-analyzer --install-extension ms-python.python --install-extension ms-python.debugpy
