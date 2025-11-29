"========================================
" 環境設定 (General Settings)
"========================================

" メッセージ表示を簡略化 ('a' は startup や filetype detection のメッセージを非表示)
set shortmess=a

" コマンドラインの高さを2行にする
set cmdheight=2

" 行番号を表示する
set number

" クリップボードの内容をOSのクリップボードと共有する (yank/put が外部と連携)
set clipboard=unnamedplus

" 自動でカレントディレクトリを編集中のファイルがあるディレクトリに変更する
set autochdir

" 全角文字の幅を2倍にする (日本語環境などで文字化けを防ぐ)
set ambiwidth=double

" 検索結果をハイライト表示する
set hlsearch


"========================================
" コマンド設定 (Command Customization)
"========================================

" :w!! で sudo 権限で上書き保存できるようにする
cmap w!! w !sudo tee > /dev/null %

" Windows環境などで Ctrl+v がペーストになるのを回避するため、
" ノーマルモードで \v を押すとブロックビジュアルモードに入るように設定
nmap \v <C-v>


"----------------------------------------
" タイムアウト設定 (Timeout Settings)
"----------------------------------------

" キーコードのタイムアウト時間を0ミリ秒に設定 (キー入力の即時性を高める)
set ttimeoutlen=0
" 'timeout' や 'ttimeout' の設定確認 (コメントアウト)
""set timeout? ttimeout?


"========================================
" プラグイン設定 (Plugin Management - vim-plug)
"========================================

" プラグイン管理の開始
call plug#begin('~/.vim/plugged')

"--- 有効なプラグイン ---
" ( )で囲む操作を簡単にするプラグイン
Plug 'tmsvg/pear-tree'
" 囲まれたテキストを簡単に変更/削除/追加できるプラグイン
Plug 'tpope/vim-surround'

"--- コメントアウトされたプラグイン ---
" Plug 'jacoborus/tender.vim' (カラースキーム)
" Plug 'tpope/vim-commentary' (コメントアウトを簡単にする)
" ddc.vim 関連
"" Plug 'Shougo/ddc.vim'
"" Plug 'vim-denops/denops.vim'
"" Plug 'Shougo/pum.vim'
"" Plug 'Shougo/ddc-around'
"" Plug 'LumaKernel/ddc-file'
"" Plug 'Shougo/ddc-matcher_head'
"" Plug 'Shougo/ddc-sorter_rank'
"" Plug 'Shougo/ddc-converter_remove_overlap'

" プラグイン管理の終了
call plug#end()


"----------------------------------------
" 未使用・コメントアウト設定 (Unused/Commented Settings)
"----------------------------------------
" set listchars=tab:»-,space:･,trail:･,eol:↲,nbsp:⍽,extends:»,precedes:«
" autocmd Colorscheme * highlight FullWidthSpace ctermbg=white
" autocmd VimEnter * match FullWidthSpace /　/
" colorscheme desert
" inoremap <expr> ,df strftime('%Y-%m-%d %H:%M')
" inoremap <expr> ,dd strftime('%Y-%m-%d')
" inoremap <expr> ,dt strftime('%H:%M')
" let weeks = [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ]
" let wday = strftime("%w")
" inoremap <expr> ,ds strftime('%Y-%m-%d ').weeks[wday]
" cd /home/tani/vim

"========================================
" ハイライトとカラー設定 (最終調整版)
"========================================
augroup InsertHook
    autocmd!
    
    " 通常モードの色を確実に設定する関数を定義
    function! SetNormalColors()
        " 通常モード時: Normalの背景色を253番 (少し暗い色) に設定
        " ※他のハイライトグループによる上書きを防ぐため、常に実行
        hi Normal ctermbg=253
    endfunction
    
    " 1. Vim起動時、カラースキーム読み込み時、挿入モード終了時に通常モードの色をセット
    autocmd VimEnter,ColorScheme,InsertLeave * call SetNormalColors()
    
    " 2. 挿入モードに入ったときに背景色を設定
    autocmd InsertEnter * hi Normal ctermbg=231
augroup END

