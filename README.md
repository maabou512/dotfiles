## 🚀 Dotfiles/Starship/Vim 環境構築と変更管理のフロー（最終統合版）

このガイドは、新しいマシンでのゼロからのセットアップと、既存マシンでの設定変更をGitHubに同期する作業の両方を網羅しています。

### 段階 I: 新しい環境へのセットアップ (New Machine Setup)

新しいPCやサーバーにDotfilesを導入する際に、上から順に実行してください。

#### ステップ 1: 必須ツールのインストールと準備

| 環境 | コマンド |
| :--- | :--- |
| **Linux / macOS** | `sudo apt update && sudo apt install git stow curl` (Linux) / `brew install git stow curl` (macOS) |
| **Windows(Git Bash)** | **Git** がインストール済みであることを確認 |

-----

#### ステップ 2: Dotfilesリポジトリのクローンと機密情報ファイルの作成 🔒

```bash
cd ~
# リポジトリをクローン
git clone <あなたのGitHubリポジトリのURL> dotfiles
cd dotfiles

# 機密情報ファイルを作成・保護（Git管理外のAPIキーなどを記述）
vim ~/.bashrc_secrets
chmod 600 ~/.bashrc_secrets
```

-----

#### ステップ 3: Nerd Font (BlexMono) のインストールとターミナル設定 🎨

Starshipのアイコンや記号表示に必須です。

1.  **BlexMono Nerd Fontのインストール**
      * **Windowsの場合:** フォントファイルをダウンロードし、ダウンロードした `.ttf` ファイルまたは `.otf` ファイルを**右クリック**し、「**インストール**」を選択してインストールします。
      * **Linux / macOSの場合:**
        ```bash
        mkdir -p /tmp/blex-font && cd /tmp/blex-font
        curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/IBMPlexMono.zip
        unzip IBMPlexMono.zip
        mkdir -p ~/.local/share/fonts/BlexMono
        cp *.ttf ~/.local/share/fonts/BlexMono/
        cd ~ && rm -rf /tmp/blex-font
        fc-cache -fv
        ```
2.  **ターミナル設定の変更 (必須):**
    ターミナルアプリを再起動し、**[設定]** でフォントを「**BlexMono Nerd Font**」に手動で変更します。

-----

#### ステップ 4: Starshipのインストール（簡易版） 🚀

Rustをビルドせず、最も簡単な方法で導入します。

| 環境 | 推奨されるインストール方法 |
| :--- | :--- |
| **Windows(Winget)** | **PowerShell** または **Windows Terminal** で実行: `winget install Starship.Starship` |
| **Linux / Windows(Git Bash) / macOS** | **Bash/Zsh** で実行: `curl -sS https://starship.rs/install.sh | sh` |

-----

#### ステップ 5: Dotfilesの配置とシンボリックリンクの作成 🔗

`stow` を使わず、**`ln -s`** コマンドでシンボリックリンクを作成します。

1.  **Vimプラグイン管理システムのインストール (vim-plug 本体)**

    ```bash
    # Vimプラグインのautoloadディレクトリを作成
    mkdir -p ~/.vim/autoload

    # vim-plugをダウンロードし、autoload内に配置
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    ```

2.  **既存設定の退避とシンボリックリンクの作成:**

    ```bash
    cd ~
    # 既存ファイルの退避と削除（.bashrc, starship.toml, .vimrc）
    if [ -f ~/.bashrc ]; then cp ~/.bashrc ~/.bashrc.bak_$(date +%Y%m%d_%H%M%S); rm ~/.bashrc; fi
    if [ -f ~/.config/starship.toml ]; then cp ~/.config/starship.toml ~/.config/starship.toml.bak; rm ~/.config/starship.toml; fi
    if [ -f ~/.vimrc ]; then cp ~/.vimrc ~/.vimrc.bak_$(date +%Y%m%d_%H%M%S); rm ~/.vimrc; fi

    # Dotfilesからシンボリックリンクを作成
    ln -s ~/dotfiles/bash/.bashrc ~/.bashrc
    ln -s ~/dotfiles/vim/.vimrc ~/.vimrc
    mkdir -p ~/.config # 必要であれば作成
    ln -s ~/dotfiles/starship/.config/starship.toml ~/.config/starship.toml
    ```

3.  **プラグインのインストール:**
    Vimを起動し、`.vimrc`に記述されているプラグインをダウンロードします。

    ```bash
    vim
    # Vim内で以下のコマンドを実行
    :PlugInstall
    # (インストールが完了したら)
    :quitall
    ```

-----

#### ステップ 6: 設定の最終反映

##### 【Bash/Zsh 環境（Linux / Windows(Git Bash) / macOS）の場合】

```bash
source ~/.bashrc
```

##### 【PowerShell 環境の場合（Wingetインストール後）】

PowerShellのプロファイルに初期化コマンドを追加します。

1.  **プロファイルファイルを開く:** `notepad $PROFILE` または `code $PROFILE`
2.  **ファイルの末尾に追記:** `Invoke-Expression (&starship init powershell)`
3.  新しいPowerShellウィンドウを開くか、`.$PROFILE` で再読み込みします。

-----

### 段階 II: 既存環境での設定変更と同期 (Change Management)

既存環境で設定を修正し、その変更をGitHubに保存する手順です。

#### ステップ A: 設定ファイルの編集と動作確認

1.  **設定ファイルを編集:**
    リポジトリ内のファイルを直接編集します（例: `~/dotfiles/vim/.vimrc`）。
    ```bash
    vim ~/dotfiles/vim/.vimrc 
    ```
2.  **動作確認:**
    ```bash
    # Bash/Zshの場合、.bashrcを再読み込み
    source ~/.bashrc
    # Vimプラグインリストを変更した場合は、必ず実行
    vim +PlugInstall +qall 
    ```

#### ステップ B: 変更のコミットとGitHubへのプッシュ 🚀

1.  **作業ディレクトリへの移動:**
    ```bash
    cd ~/dotfiles
    ```
2.  **変更をステージングエリアに追加:**
    変更したファイルを全て追加します。
    ```bash
    git add bash/.bashrc starship/.config/starship.toml vim/.vimrc
    ```
3.  **変更をコミット:**
    ```bash
    git commit -m "feat: add .vimrc and optimize bashrc"
    ```
4.  **GitHubへのプッシュ:**
    ```bash
    git push origin main
    ```
