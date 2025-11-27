## 🚀 Dotfiles/Starship 環境構築と変更管理のフロー（完全統合版）

このガイドは、新しいマシンでのゼロからの環境構築（セットアップ）と、既存マシンでの設定変更をGitHubに同期する作業（変更管理）の両方を網羅しています。

### 段階 I: 新しい環境へのセットアップ (New Machine Setup)

新しいPCやサーバーにDotfilesを導入する際に、上から順に実行してください。

#### ステップ 1: 必須ツールのインストールと準備

| 環境 | コマンド |
| :--- | :--- |
| **Linux (Ubuntu/WSL)** | `sudo apt update && sudo apt install git stow curl` |
| **macOS** | `brew install git stow curl` |
| **MSYS2/MinGW64** | `pacman -Sy && pacman -S git stow` |

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

#### ステップ 3: Nerd Font (BlexMono) のインストールとターミナル設定 🎨

Starshipのアイコンや記号表示に必須です。

1.  **BlexMono Nerd Fontのインストール**
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

#### ステップ 4: Starshipのインストール（PATHの確保）

```bash
# Rust/Cargoのインストール
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env" # PATHを即座に反映
# Starshipのインストール
cargo install starship --locked
```

#### ステップ 5: 既存設定の退避と Dotfiles の適用 (Stow) 🔗

```bash
# 既存の .bashrc をバックアップして削除
if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.bak_$(date +%Y%m%d_%H%M%S)
    rm ~/.bashrc
fi

# Stowでシンボリックリンクを作成
cd ~/dotfiles
stow bash 
stow starship 
```

#### ステップ 6: 設定の最終反映

```bash
# .bashrcを再読み込みし、環境構築完了
source ~/.bashrc
```

-----

### 段階 II: 既存環境での設定変更と同期 (Change Management)

既にセットアップが完了している環境で、`.bashrc` や `starship.toml` を修正し、その変更をGitHubに保存する手順です。

#### ステップ A: 設定ファイルの編集と動作確認

1.  **設定ファイルを編集:**
    リポジトリ内の元のファイルを編集します（例: `~/dotfiles/bash/.bashrc`）。
    ```bash
    vim ~/dotfiles/bash/.bashrc 
    # 例: Starship初期化ブロックをファイル末尾に移動したり、新しいエイリアスを追加
    ```
2.  **動作確認:**
    設定を現在のシェルに適用し、変更が正しく動作するか確認します。
    ```bash
    source ~/.bashrc
    ```

#### ステップ B: 変更のコミットとGitHubへのプッシュ 🚀

1.  **作業ディレクトリへの移動:**
    ```bash
    cd ~/dotfiles
    ```
2.  **変更されたファイルをステージングエリアに追加:**
    ```bash
    git add bash/.bashrc starship/.config/starship.toml 
    # 変更したファイルを全て追加
    ```
3.  **変更をコミット:**
    ```bash
    git commit -m "refactor: optimize starship init block and add new alias"
    ```
4.  **GitHubへのプッシュ:**
    ```bash
    git push origin main
    ```

-----


この手順は、GitHubで管理している Dotfiles と Starship 環境を、**Linux/WSL/macOS/MSYS2**のどの環境でもシームレスに再現するための完全ガイドです。

### 準備: Dotfilesリポジトリの構造

Stowによる適用のため、以下の構造でリポジトリを準備していることを前提とします。

```
~/dotfiles/
├── bash/
│   └── .bashrc
└── starship/
    └── .config/
        └── starship.toml
```

-----

### ステップ 1: 環境の確認と必須パッケージのインストール

OSに応じて必要なパッケージマネージャーを使って `git` と `stow` を導入します。

#### 【Linux (Ubuntu/WSL) / macOS 環境の場合】

```bash
# Ubuntu/Debian/WSL の場合
sudo apt update
sudo apt install git stow curl

# macOS (Homebrewを使用) の場合
brew install git stow curl
```

#### 【Windows MSYS2/MinGW64 環境の場合】

MSYS2のターミナルで `pacman` を使用します。

```bash
# pacmanのデータベースを更新
pacman -Sy

# GitとStowをインストール
pacman -S git stow
```

-----

### ステップ 2: Dotfilesリポジトリのクローンと認証

GitHubからリポジトリをクローンし、ディレクトリに移動します。

```bash
# 1. ホームディレクトリに移動
cd ~

# 2. リポジトリをクローン
git clone <あなたのGitHubリポジトリのURL> dotfiles

# 3. リポジトリのディレクトリに移動
cd dotfiles
```

-----

### ステップ 3: 機密情報ファイル（APIキーなど）の作成と保護 🔒

Git管理外の機密情報ファイルを作成し、**`.bashrc`が読み込む**ように準備します。

```bash
# 1. 機密情報ファイルを作成・編集し、APIキーなどを記述
vim ~/.bashrc_secrets 

# 2. ファイルのパーミッションを設定し、自分だけが読み書きできるように保護
chmod 600 ~/.bashrc_secrets
```

-----

### ステップ 4: Nerd Font (BlexMono) のインストールと設定 🎨

Starshipのアイコン表示に必要なフォントをインストールし、ターミナルに適用します。

#### 4-1. BlexMono Nerd Fontのインストール

```bash
# 1. 一時ディレクトリを作成し、移動
mkdir -p /tmp/blex-font
cd /tmp/blex-font

# 2. BlexMono Nerd FontのZIPファイルをダウンロード
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/IBMPlexMono.zip

# 3. ファイルを解凍
unzip IBMPlexMono.zip

# 4. ユーザーのローカルフォントディレクトリにコピー
mkdir -p ~/.local/share/fonts/BlexMono
cp *.ttf ~/.local/share/fonts/BlexMono/

# 5. ダウンロード用の一時ディレクトリを削除
cd ~
rm -rf /tmp/blex-font

# 6. フォントキャッシュを更新し、システムに新しいフォントを認識させる (必須)
fc-cache -fv
```

#### 4-2. ターミナル設定の変更 (必須)

1.  **GNOME Terminal** (または使用中のターミナル) の**ウィンドウをすべて閉じ**ます。
2.  ターミナルを再起動し、**[設定]** → **[プロファイル]** → **[フォント設定]** を開きます。
3.  フォントを「**BlexMono Nerd Font**」に手動で変更します。

-----

### ステップ 5: Starshipのインストール（PATHの確保）

Starshipの実行ファイルとPATHを確保します。

#### 5-1. Rust/Cargo のインストール

```bash
# Rust/Cargo インストーラを実行
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# ⚠️ インストール中に選択肢が表示された場合 ⚠️
# 「1) Proceed with standard installation (default - just press enter)」を選択し、Enterキーを押す。

# 2. インストール後、PATHを即座に反映させる
source "$HOME/.cargo/env"
```

#### 5-2. Starship のインストール

```bash
cargo install starship --locked
```

-----

### ステップ 6: 既存設定の退避と Dotfiles の適用 (Stow) 🔗

Stowを実行し、Dotfilesをホームディレクトリにシンボリックリンクとして配置します。

#### 6-1. 既存のデフォルト設定の退避 (重要)

Stowによる上書きエラーを避けるため、デフォルトで存在する `.bashrc` をバックアップします。

```bash
if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.bak_$(date +%Y%m%d_%H%M%S)
    echo "既存の .bashrc をバックアップしました: ~/.bashrc.bak_..."
    rm ~/.bashrc
    echo "既存の .bashrc を削除しました。"
fi
```

#### 6-2. Stowによる Dotfiles の適用

```bash
# dotfilesディレクトリにいることを確認
cd ~/dotfiles

# bash設定を適用 ( -> ~/.bashrc )
stow bash 

# Starship設定を適用 ( -> ~/.config/starship.toml )
stow starship 
```

-----

### ステップ 7: 設定の最終反映

すべての設定を現在開いているシェルに適用し、環境構築を完了します。

```bash
# .bashrcを再読み込みし、新しい設定を適用
# これにより、Starshipの初期化が実行されプロンプトが切り替わります。
source ~/.bashrc
# または
. ~/.bashrc
```