#! /usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$SCRIPT_DIR"

if command -v brew >/dev/null 2>&1 ; then
  echo "Homebrew already installed"
else
  echo "Installing Homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install tools through Homebrew
brew bundle

# If not logged in to Quay.io, do so.
if jq --raw-output --exit-status '.auths."quay.io"' ~/.docker/config.json >/dev/null 2>&1 ; then
  echo "Already logged in to quay.io"
else
  echo "docker login to Quay"
  docker login --username russell@hashicorp.com quay.io
fi

# If not logged in to DockerHub, do so
if jq --raw-output --exit-status '.auths."https://index.docker.io/v1/"' ~/.docker/config.json >/dev/null 2>&1 ; then
  echo "Already logged in to DockerHub"
else
  echo "docker login to DockerHub"
  docker login --username rustyfe
fi

mkdir -p "${HOME}/bin"

# git branch auto-completion
if [ ! -f "${HOME}/bin/git-completion.bash" ]; then 
  curl --silent --output \
    "${HOME}/bin/git-completion.bash" \
    "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
fi

# Set up gpg
echo "Symlinking GPG configuration to use ours."
gpgconf --launch gpg-agent
rm -rf "${HOME}/.gnupg/gpg.conf"
ln -s "$(pwd)/gpg.conf" "${HOME}/.gnupg/gpg.conf"
rm -rf "${HOME}/.gnupg/gpg-agent.conf"
ln -s "$(pwd)/gpg-agent.conf" "${HOME}/.gnupg/gpg-agent.conf"
rm -rf "${HOME}/.gnupg/scdaemon.conf"
ln -s "$(pwd)/gpg-scdaemon.conf" "${HOME}/.gnupg/scdaemon.conf"

# Dirty hack.
set +e
pkill gpg-agent; pkill ssh-agent; pkill pinentry-mac; pkill pinentry
set -e

# Set up .bash_profile
echo "Symlinking .bash_profile to use ours."
rm -rf "${HOME}/.bash_profile"
ln -s "$(pwd)/bash_profile" "${HOME}/.bash_profile"

# Set up git
echo "Symlinking in Git configuration."
rm -rf "${HOME}/.gitconfig"
ln -s "$(pwd)/gitconfig" "${HOME}/.gitconfig"
rm -rf "${HOME}/.gitignore"
ln -s "$(pwd)/gitignore" "${HOME}/.gitignore"

# Source .bash_profile, make sure it is working / can be used for later steps.
source "${HOME}/.bash_profile"

# Terraform plz
if command -v terraform >/dev/null 2>&1 ; then
  echo "Terraform installed..."
else
  echo "Installing Terraform"
  curl --silent --output tf.zip "https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_darwin_amd64.zip"
  unzip -o -d "${HOME}/bin" tf.zip
  rm -rf tf.zip
fi

# Golang too plz
if command -v go >/dev/null 2>&1 ; then
  echo "Go installed..."
else
  echo "Installing Go"
  curl --silent --output go.tar.gz "https://dl.google.com/go/go1.13.darwin-amd64.tar.gz"
  tar -C "${HOME}/bin" -xzf go.tar.gz
  rm -rf go.tar.gz
fi

# golangci-lint is also cool
if command -v golangci-lint >/dev/null 2>&1 ; then
  echo "golangci-lint installed..."
else
  echo "Installing golangci-lint"
  go get -u github.com/golangci/golangci-lint/cmd/golangci-lint
fi

# can't live without goimports
if command -v goimports >/dev/null 2>&1 ; then
  echo "goimports installed..."
else
  echo "Installing goimports"
  go get -v golang.org/x/tools/cmd/goimports
fi

# CircleCI CLI is useful
if command -v circleci >/dev/null 2>&1 ; then
  echo "circleci installed..."
else
  echo "Installing CircleCI CLI"
  curl -fLSs https://circle.ci/cli | bash
fi

# Grab FiraCode fonts:
if ls "${HOME}/Library/Fonts/otf" | grep -i "fira" >/dev/null 2>&1 ; then
  echo "FiraCode fonts already installed..."
else
  echo "Installing FiraCode fonts"
  curl --silent --location --output fc.zip \
    "https://github.com/tonsky/FiraCode/releases/download/2/FiraCode_2.zip"
  unzip -o -d "${HOME}/Library/Fonts" fc.zip "otf/*"
  rm -rf fc.zip
fi

# Import VSCode settings
echo "Symlinking in VSCode configuration."
rm -rf "${HOME}/Library/Application Support/Code/User/settings.json"
ln -s "$(pwd)/vscode_settings.json" "${HOME}/Library/Application Support/Code/User/settings.json"

# Install VSCode extensions
echo "Installing VSCode extensions"
code --install-extension timonwong.shellcheck
code --install-extension vscodevim.vim
code --install-extension ms-vscode.go

# Silly one, set desktop background
echo "Setting desktop background"
if [ ! -f "${HOME}/Pictures/ksbd.jpg" ]; then
  curl --silent --ouput \
    "${HOME}/Pictures/ksbd.jpg" \
    "https://killsixbilliondemons.com/wp-content/uploads/2017/02/SOT32-33.jpg"
fi
osascript -e \
  "tell application \"System Events\" to tell every desktop to set picture to POSIX file \"${HOME}/Pictures/ksbd.jpg\""

# Set scrolling to be not stupid
if [ "$(defaults read -g com.apple.swipescrolldirection)" -eq "1" ]; then
  defaults write -g com.apple.swipescrolldirection -bool NO
  sudo shutdown -r now "Rebooting to pick up scroll fix..."
fi
