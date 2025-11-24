# ====================================================================
# Bash Startup Configuration: ~/.bashrc
# --------------------------------------------------------------------
# 実行者: Tani
# 目的: 非ログインシェル用の設定
# ====================================================================

# --------------------------------------------------------------------
# 1. 起動時の基本チェック
# --------------------------------------------------------------------

# 対話型シェルでない場合は何もしない (デフォルト設定)
case $- in
    *i*) ;;
      *) return;;
esac

# --------------------------------------------------------------------
# 2. History (履歴) 設定
# --------------------------------------------------------------------

# 重複行やスペースで始まる行を履歴に入れない
HISTCONTROL=ignoreboth

# 履歴を上書きせず、追記する (デフォルトはコメントアウトされていますが、こちらを有効に)
shopt -s histappend

# 履歴ファイルのサイズを大きくする (デフォルトを解除し、独自の大きな値に設定)
HISTSIZE=1000000
HISTFILESIZE=1000000
export HISTTIMEFORMAT="%Y-%m-%d %T "

# Historyの共有設定 (PROMPT_COMMANDとhistappendの解除を統合)
# 全ての端末でコマンド履歴を即座に共有するための設定
# ※ histappendは上記で有効化されているため、この行で'shopt -u histappend'は不要
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"


# --------------------------------------------------------------------
# 3. 基本的なシェル動作の設定
# --------------------------------------------------------------------

# ウィンドウサイズ変更時に LINES/COLUMNS を更新する (デフォルト)
shopt -s checkwinsize

# lesspipeの設定 (lessの拡張機能 - デフォルト)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ** 冗長な行を整理・統合 **
# シェル補完機能の有効化 (デフォルト設定)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# --------------------------------------------------------------------
# 4. プロンプト (PS1) & 色の設定
# --------------------------------------------------------------------

# chroot環境を識別する変数の設定 (デフォルト)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# プロンプトの色の設定 (デフォルトのロジックを使用)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    # PS1の定義 (オリジナルの最終設定を採用: \w (現在のディレクトリ名) ではなく $PWD (フルパス) を使用した改行プロンプト)
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$PWD\n\$ '
else
    # 非カラー時
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# xtermのタイトル設定 (デフォルト)
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Starship (カスタムプロンプト) の初期化 (一番最後に実行するのが推奨)
# プロンプトPS1の設定とStarshipは競合するため、Starshipを使用する場合は上記のPS1は無視されます。
# Starshipを使うなら、上記のPS1関連のコードをコメントアウトしてもOKですが、ここではそのまま残します。
eval "$(starship init bash)"

# --------------------------------------------------------------------
# 5. エイリアス (Alias)
# --------------------------------------------------------------------

# ** エイリアスを ~/.bash_aliases に分離することを推奨 (デフォルト設定のロジック) **
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# dircolors の設定と ls/grep のエイリアス (デフォルト)
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# よく使う ls のエイリアス (デフォルト + オリジナルの設定を維持)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# trash-put があれば rm を上書き (オリジナルの設定を維持)
if type trash-put &> /dev/null
then
    alias rm=trash-put
fi

# alert エイリアス (デフォルト設定を維持)
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# --------------------------------------------------------------------
# 6. カスタム関数 (acd_func: cd拡張機能)
# --------------------------------------------------------------------

# cd_func の本体
cd_func ()
{
    local x2 the_new_dir adir index
    local -i cnt

    if [[ $1 ==  "--" ]]; then
        dirs -v
        return 0
    fi

    the_new_dir=$1
    [[ -z $1 ]] && the_new_dir=$HOME

    if [[ ${the_new_dir:0:1} == '-' ]]; then
        # Extract dir N from dirs
        index=${the_new_dir:1}
        [[ -z $index ]] && index=1
        adir=$(dirs +$index)
        [[ -z $adir ]] && return 1
        the_new_dir=$adir
    fi
    # '~' has to be substituted by ${HOME}
    [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

    # Now change to the new dir and add to the top of the stack
    pushd "${the_new_dir}" > /dev/null
    [[ $? -ne 0 ]] && return 1
    the_new_dir=$(pwd)

    # Trim down everything beyond 11th entry
    popd -n +11 2>/dev/null 1>/dev/null

    # Remove any other occurence of this dir, skipping the top of the stack
    for ((cnt=1; cnt <= 10; cnt++)); do
        x2=$(dirs +${cnt} 2>/dev/null)
        [[ $? -ne 0 ]] && return 0
        [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
        if [[ "${x2}" == "${the_new_dir}" ]]; then
            popd -n +$cnt 2>/dev/null 1>/dev/null
            cnt=cnt-1
        fi
    done

    return 0
}

alias cd=cd_func

if [[ $BASH_VERSION > "2.05a" ]]; then
    # ctrl+w shows the menu
    bind -x "\"\C-w\":cd_func -- ;"
fi


# --------------------------------------------------------------------
# 7. 環境変数 (Exports) の定義
# --------------------------------------------------------------------

# APIキーなどの機密情報ファイルを読み込む (前回の提案通り、分離された設定)
if [ -f "$HOME/.bashrc_secrets" ]; then
    . "$HOME/.bashrc_secrets"
fi

# Google Cloud 認証情報 (GOOSGLE_APPLICATION_CREDENTIALS)
export GOOGLE_APPLICATION_CREDENTIALS="/home/tani/.config/gcloud/cte-hackmd-trial-52c9ecf3cc7e.json"

# Golang の設定
export GOPATH=$HOME/go/

# Wasmtime の設定
. "$HOME/.cargo/env" # Rust/Cargo の環境変数読み込み
export WASMTIME_HOME="$HOME/.wasmtime"
export PATH="$WASMTIME_HOME/bin:$PATH"

# Pyenv の設定
export PYENV_ROOT="$HOME/.pyenv"
# PATHを再設定 (既存のPATHに追加するため、重複を避けるために一括で再定義)
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# カスタムPATHの追加/再定義
# 重複していた長いPATHの定義を、必要なものだけ残してスッキリさせました。
# Golang, Wasmtime, Pyenvのbinは既に上で追加済み
export PATH=$PATH:/usr/local/go/bin:/home/tani/bin:$HOME/go/bin

# --------------------------------------------------------------------
# 8. デバイス固有の設定 (コメントアウトで整理)
# --------------------------------------------------------------------

# Wayland/X11でのTrackPoint無効化 (デバイス固有の設定として残す)
# #xinput list
# #xinput set-prop "TPPS/2 Elan TrackPoint" "Device Enabled" 0 # for 20.04 (X11)
# #grep -a2 TrackPoint /proc/bus/input/devices
# #echo 1 > /sys/devices/rmi4-00/rmi4-00.fn03/serio2/input/input9/inhibited

# Keymap変更 (xmodmapはX11環境固有のためコメントアウト)
# #xmodmap -e 'keycode 66 = Zenkaku_Hankaku'
# #xmodmap -e 'keycode 49 = Escape'
# #xmodmap -e 'remove lock = Zenkaku_Hankaku'

# tmux launch as default (非ログインシェルでtmuxを起動するのは一般的に bash_profile/zshrc の役割ですが、残しておきます)
# #if [ $SHLVL = 1 ]; then
# #    tmux -2
# #fi

# --------------------------------------------------------------------
# 9. 未使用・冗長な設定 (コメントアウト済み)
# --------------------------------------------------------------------

# globstar: **でディレクトリを再帰的にマッチさせる機能 (現在コメントアウトされています)
# #shopt -s globstar

# LESS関連の設定: 複数の設定があり冗長だったので、すべてコメントアウトし、必要に応じて一つだけ有効化してください。
# #alias rless='less -R'
# #export LESSOPEN="| /usr/share//source-highlight/src-hilite-lesspipe.sh %s"
# #export LESS=' -R '
# #export LESSOPEN="| /usr/local/bin/lesspipej.sh %s"
# #export LESS="-j10 -R --no-init --quit-if-one-screen"

# GCCの色設定 (現在コメントアウトされています)
# #export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

