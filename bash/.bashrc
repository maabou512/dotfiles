# ====================================================================
# Bash Startup Configuration: ~/.bashrc
# --------------------------------------------------------------------
# 目的: 非ログインシェル用の設定
# 特徴: Starship互換、History共有、機密情報(.bashrc_secrets)分離
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
# 2. 環境変数 (Exports) の定義 & PATHの追加
# --------------------------------------------------------------------
# 🚨 必須: Starshipなどのツールを使用する前に、実行ファイルへのPATHを設定します。

# Cargo/Rust の環境変数読み込み（Starshipの実行に必要）
# Cargoのインストール時に生成されるファイルを参照
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# Pyenv の設定
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
    # PATHを再設定 (既存のPATHに追加するため、重複を避けるために一括で再定義)
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# Wasmtime の設定
export WASMTIME_HOME="$HOME/.wasmtime"
export PATH="$WASMTIME_HOME/bin:$PATH"

# カスタムPATHの追加 (Golang, ~/bin などを追加)
export GOPATH=$HOME/go/
export PATH=$PATH:/usr/local/go/bin:/home/tani/bin:$HOME/go/bin

# Google Cloud 認証情報 (GOOSGLE_APPLICATION_CREDENTIALS)
# 環境移行を考慮し、もし ~/.bashrc_secrets に移動可能ならそちらを推奨
export GOOGLE_APPLICATION_CREDENTIALS="/home/tani/.config/gcloud/cte-hackmd-trial-52c9ecf3cc7e.json"

# APIキーなどの機密情報ファイルを読み込む (前回の手順で分離したファイル)
if [ -f "$HOME/.bashrc_secrets" ]; then
    . "$HOME/.bashrc_secrets"
fi

# --------------------------------------------------------------------
# 3. History (履歴) 設定
# --------------------------------------------------------------------

# 重複行やスペースで始まる行を履歴に入れない
HISTCONTROL=ignoreboth

# 履歴を上書きせず、追記する
shopt -s histappend

# 履歴ファイルのサイズ設定
HISTSIZE=1000000
HISTFILESIZE=1000000
export HISTTIMEFORMAT="%Y-%m-%d %T "

# Historyの共有設定 (全ターミナルで即座にコマンド履歴を共有)
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"


# --------------------------------------------------------------------
# 4. プロンプト (PS1) & Starship
# --------------------------------------------------------------------

# Starship (カスタムプロンプト) の初期化
if command -v starship > /dev/null; then
    # 🚨 修正ポイント: 既存のプロンプト定義をクリアし、Starshipを強制適用する
    unset PS1 
    eval "$(starship init bash)"
fi

# Starshipを使用しない場合のデフォルトプロンプト（Starshipが有効な場合は無視される）
if ! command -v starship > /dev/null; then
    # chroot環境を識別する変数の設定 (デフォルト)
    if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi

    # デフォルトのカラフルな改行プロンプト (既存の設定を維持)
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$PWD\n\$ '

    # xtermのタイトル設定 (デフォルト)
    case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
    esac
fi

# --------------------------------------------------------------------
# 5. エイリアス & ls/grep の色の設定
# --------------------------------------------------------------------

# エイリアスファイルを読み込む (推奨される分離方法)
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# dircolors の設定と ls/grep のエイリアス
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# よく使う ls のエイリアス
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# trash-put があれば rm を上書き
if type trash-put &> /dev/null
then
    alias rm=trash-put
fi

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
    # ... (元の長い cd_func のロジックが続く)
    the_new_dir=$1
    [[ -z $1 ]] && the_new_dir=$HOME
    if [[ ${the_new_dir:0:1} == '-' ]]; then
        index=${the_new_dir:1}
        [[ -z $index ]] && index=1
        adir=$(dirs +$index)
        [[ -z $adir ]] && return 1
        the_new_dir=$adir
    fi
    [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"
    pushd "${the_new_dir}" > /dev/null
    [[ $? -ne 0 ]] && return 1
    the_new_dir=$(pwd)
    popd -n +11 2>/dev/null 1>/dev/null
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
# 7. その他のデフォルト/便利な設定
# --------------------------------------------------------------------

# ウィンドウサイズ変更時に LINES/COLUMNS を更新する (デフォルト)
shopt -s checkwinsize

# lesspipeの設定 (lessの拡張機能 - デフォルト)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# シェル補完機能の有効化 (デフォルト設定)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# --------------------------------------------------------------------
# 8. デバイス固有の設定 (コメントアウト)
# --------------------------------------------------------------------
# Keymap変更、TrackPoint無効化など、マシンごとに異なる設定はここに残し、必要に応じて有効化してください。
# #xinput set-prop "TPPS/2 Elan TrackPoint" "Device Enabled" 0
# #xmodmap -e 'keycode 49 = Escape'
