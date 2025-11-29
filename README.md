## 🚀 Dotfiles/Starship 環境構築と変更管理のフロー（最終統合版）

このガイドは、新しいマシンでのゼロからのセットアップと、既存マシンでの設定変更をGitHubに同期する作業の両方を網羅しています。

### 段階 I: 新しい環境へのセットアップ (New Machine Setup)

新しいPCやサーバーにDotfilesを導入する際に、上から順に実行してください。

#### ステップ 1: 必須ツールのインストールと準備

| 環境 | コマンド |
| :--- | :--- |
| **Linux (Ubuntu/WSL)** | `sudo apt update && sudo apt install git stow curl` |
| **macOS** | `brew install git stow curl` |
| **Windows (Git Bash/Winget)** | **Git** がインストール済みであることを確認 |

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
      * **Linux/WSLの場合:**
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

**Rustをビルドせず、最も簡単な方法で導入します。**

| 環境 | 推奨されるインストール方法 |
| :--- | :--- |
| **Windows (Winget)** | **PowerShell** または **Windows Terminal** で実行: `winget install Starship.Starship` |
| **Windows (Git Bash)** | **Git Bash** で実行: `curl -sS https://starship.rs/install.sh | sh` |
| **Linux/macOS** | **Bash/Zsh** で実行: `curl -sS https://starship.rs/install.sh | sh` |

-----

#### ステップ 5: Dotfilesの配置とシンボリックリンクの作成 🔗

Stowを使わず、**`ln -s`** コマンドでシンボリックリンクを作成します。

1.  **既存設定の退避 (重要):**

    ```bash
    cd ~
    # .bashrc の退避
    if [ -f ~/.bashrc ]; then
        cp ~/.bashrc ~/.bashrc.bak_$(date +%Y%m%d_%H%M%S)
        rm ~/.bashrc
    fi
    # starship.toml の退避
    if [ -f ~/.config/starship.toml ]; then
        cp ~/.config/starship.toml ~/.config/starship.toml.bak
        rm ~/.config/starship.toml
    fi
    ```

2.  **シンボリックリンクの作成:**

    ```bash
    # .bashrc のリンク
    ln -s ~/dotfiles/bash/.bashrc ~/.bashrc

    # Starship設定ディレクトリのリンク (必要に応じて .config も作成)
    mkdir -p ~/.config
    ln -s ~/dotfiles/starship/.config/starship.toml ~/.config/starship.toml
    ```

-----

#### ステップ 6: 設定の最終反映

##### 【Bash/Zsh 環境（Linux/macOS/Git Bash）の場合】

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
    リポジトリ内のファイルを直接編集します（例: `~/dotfiles/bash/.bashrc`）。
    ```bash
    vim ~/dotfiles/bash/.bashrc 
    ```
2.  **動作確認:**
    ```bash
    source ~/.bashrc
    ```

#### ステップ B: 変更のコミットとGitHubへのプッシュ 🚀

1.  **作業ディレクトリへの移動:**
    ```bash
    cd ~/dotfiles
    ```
2.  **変更をステージングエリアに追加:**
    ```bash
    git add bash/.bashrc starship/.config/starship.toml 
    ```
3.  **変更をコミット:**
    ```bash
    git commit -m "feat: updated settings for better performance"
    ```
4.  **GitHubへのプッシュ:**
    ```bash
    git push origin main
    ```
