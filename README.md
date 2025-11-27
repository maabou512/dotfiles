## 🚀 DotfilesとStarshipの環境構築手順（最終統合版）

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