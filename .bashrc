# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
fastfetch
# tmux
# Alias
alias vi=nvim
alias sysupd='sudo dnf upgrade -y'
#alias gitc="git clone git@github.com:Denellyne/$1.git"

gitcp() {
  git clone --recursive git@github.com:Denellyne/"$1".git
}

# Bindings

bind -x '"\C-l":clear'
export PATH="$HOME/.cargo/bin:$PATH"

[ -f "/home/santos/.ghcup/env" ] && . "/home/santos/.ghcup/env" # ghcup-env
export GPG_TTY=$(tty)

tm() {
  tmux new-session -As "$(basename "$PWD")"
}
# Auto-load ESP-IDF only in project folders
esp-get() {
  . ~/code/esp-idf/export.sh
}
esp-build(){
  idf.py build && idf.py flash monitor
}

