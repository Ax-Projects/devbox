#!/bin/bash
# My own portable dev environment - with Portable Nix
# To run this script:   curl -fsSL https://github.com/Ax-Projects/devbox/raw/refs/heads/main/setup.sh | bash


# Prepare Neovim and BashRC

curl -fsSL https://get.jetify.com/devbox | bash && \
devbox init -q && \
cd && \
cat > devbox.json <<EOF
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.16.0/.schema/devbox.schema.json",
  "env": { "PROJECT_DIR": "$PWD" },
  "packages": [
	"git@latest",
    "fd@latest",
    "fish@latest",
    "fzf@latest",
    "ripgrep@latest",
    "bat@latest",
    "btop@latest",
    "yazi@latest",
    "neovim@latest",
    "lazydocker@latest",
    "lazygit@latest"
  ],
  "shell": {
    "init_hook": [
      "echo 'Amsalem Devbox!'",
      "source /tmp/amsrc"
    ],
    "scripts": {
      "set-nvim": [
        "bash ams-set-nvim.sh"
      ]
    }
  }
}
EOF

cat <<EOF > /tmp/amsrc
function y() {
	local tmp='\$(mktemp -t "yazi-cwd.XXXXXX")' cwd
	yazi "\$@" --cwd-file="\$tmp"
	IFS= read -r -d '' cwd < "\$tmp"
	[ -n "\$cwd" ] && [ "\$cwd" != "\$PWD" ] && builtin cd -- "\$cwd"
	rm -f -- "\$tmp"
}
EOF

cat > ams-set-nvim.sh << EOF
mkdir -p /tmp/ams-nvim &&
if [ ! -d ~/.config/nvim ]; then
ln -sf /tmp/ams-nvim ~/.config/nvim &&
git clone https://github.com/LazyVim/starter ~/.config/nvim &&
rm -rf ~/.config/nvim/.git
else
echo 'NeoVim config folder exists on this host. Skipping nvim setup'
fi
EOF

cat > ams-cleanup.sh << EOF
sudo rm -rf /nix
sudo rm -rf ~/.nix*
sudo rm -rf ~/.devbox
sudo rm /usr/local/bin/devbox
cd ~/.config && sudo rm -rf devbox fish yazi nvim /tmp/ams-nvim
cd ~/.cache && sudo rm -rf devbox fish nix nvim jetify tree-sitter
cd ~/.local/state/ && rm -rf devbox nvim yazi
cd && rm -f devbox.*
EOF

chmod u+x ams-set-nvim.sh ams-cleanup.sh
devbox install && \
devbox shell
