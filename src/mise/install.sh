#!/bin/sh
set -e

echo "Activating feature 'mise'"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
# echo "The effective dev container remoteUser is '$_REMOTE_USER'"
# echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

# echo "The effective dev container containerUser is '$_CONTAINER_USER'"
# echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

INSTALL_SCRIPT_URL="https://mise.run"
OPT_PATH="/opt/mise"

# Download binary & put it on the path
mkdir -p $OPT_PATH
curl $INSTALL_SCRIPT_URL | MISE_INSTALL_PATH="/usr/local/bin/mise" sh

# Global activation
echo 'eval "$(mise activate bash)"' >> "${_REMOTE_USER_HOME}/.bashrc"
echo 'eval "$(mise activate zsh)"' >> "${_REMOTE_USER_HOME}/.zshrc"
mkdir -p /etc/fish/conf.d/ && echo 'mise activate fish | source' >> /etc/fish/conf.d/mise.fish

# Shell completion
# `mise` uses `usage` in it's shell completions
mise install usage@latest
usage_path=$(mise where usage@latest)
# put usage on path regardles of mise activation
sudo ln -s "${usage_path}/bin/usage" /usr/local/bin/
# TODO: make sure these paths work in non-Debian distros as well
mkdir -p /usr/share/bash-completion/completions/ && mise completions bash > /usr/share/bash-completion/completions/mise
mkdir -p /usr/share/zsh/vendor-completions/ && mise completions zsh > /usr/share/zsh/vendor-completions/_mise
mkdir -p /etc/fish/completions/ && mise completion fish > /etc/fish/completions/mise.fish

chown -R "${_REMOTE_USER}" "${OPT_PATH}"
