---
title: "はじめて論文を書く人のためのTeXワークフロー"
emoji: "📝"
type: "tech" 
topics: ["tex", "bibtex", "zotero"]
published: false
---

## 環境


### ソフトウェア
使用するソフトウェアは$\LaTeX$の他に以下の二つです
- [Zotero](https://www.zotero.org/) (文献管理, BibTeX出力)
- [Visual Studio Code](https://code.visualstudio.com/) (主に$\LaTeX$のエディターとして)

どちらのソフトもWindows, Mac, Linuxで使えるためOSに関わらず使えるワークフローであると思います.[^1] なお, 筆者の実行環境は以下の通りです.
- MacBook Pro 13-inch, 2017. MacOS Big Sur 11.4

#### インストール (Mac)
[Zotero](https://www.zotero.org/) も[VSCode](https://code.visualstudio.com/)もそれぞれのサイトからインストール可能ですが, Macの場合は[Homebrew](https://brew.sh/index_ja)[^2]を用いることもできます. TeXのインストールもまとめて
```shell
brew update && brew install mactex-no-gui visual-studio-code zotero
```
のコマンドで一発です. 

### ファイル構成
このワークフローに対応したレポジトリを用意しました. ファイル構成の例としてご活用ください.
また, VSCodeのRemote Containersを利用することで, OSに依存せずに完全な再現が可能です.[^3][^4]

### 補論: なぜOverleafではないのか
近年$\LaTeX$の執筆環境としては[Overleaf](https://ja.overleaf.com/)が人気です. たしかに, 面倒な$\LaTeX$環境のセットアップ要らずで, 同時編集も可能な点はとても魅力的です. 筆者自身も宿題程度の軽いコラボレーションなどで利用します. しかし以下の点を不満に感じています.

- Dropbox, GitHubとの連携が有料である
- BibTeX, 図表の細かい修正を行う際にいちいちアップロードをするのが面倒 (特にGitHubで管理している場合, その度にpushする必要がある)
- プロジェクトあたりのファイル数に上限がある (大きいプロジェクトの後半はおそらくキツい)

VSCodeを利用した場合,
- 無料であり, なんの制限もない
- 後述するLaTeX Workshop Extensionが高機能で, Overleafと遜色ない
- 他の言語のエディターとしても優秀なので, 同じUIでさまざまな作業が行える

などのメリットを感じています. 

また, ネックとなるTeXのインストールですが
- Macの場合, Homebrewのコマンドで一発
- そもそも Docker + VSCode + Remote Containers でOSに依存しない環境構築できる[^5]

などの理由で特に不便を感じておりません. 

しかしながら, 本ワークフローを行うにあたっては, BibTeXファイルが適切にアップロードされていれば, **Overleafを使っても問題ありません.**


[^1]: $\LaTeX$のインストール方法だけは異なり苦労する箇所かもしれません. 近々Windows PCが支給される予定なので, 支給され次第, 加筆予定です.
[^2]: MacOS用のパッケージマネージャーです. ターミナルからコマンドで, ソフトウェアのインストール, アップデート, 削除ができるようになります. Homebrew自体のインストールは, [Homebrewのサイト](https://brew.sh/index_ja)上のコマンドをコピーして, ターミナルで実行するだけです. 
[^3]: ただし, Zoteroのインストールを除きます.
[^4]: Dockerを用いて仮想マシン上で実行する環境です. Dockerについてはいずれ記事にする予定ですが, ご存知ない方はとばしてください.
[^5]: Dockerさえ理解していれば, 人気のあるDocker Imageを利用するか, `apt update && apt install texlive-full`で簡単にセットアップできます.


## 文献引用ワークフロー
論文中での適切なフォーマットでの引用と参考文献リストの作成を自動化します.
ポイントは
- 引用する可能性のある論文を一ヶ所にまとめる(引用しなくてもいい)
- 引用する際にBibTeXのキーを使う

だけで, 文献引用のあらゆる面倒ごとから解放されるという点です. ほとんど自動化されているので, **ミスもなくなります.** 

### プロジェクトごとに一度だけやること
1. Zotero上でプロジェクト用のcollectionを作成
1. BibTeXへの自動出力を設定
1. 適切な`.bst`ファイルの設定
1. メインの`.tex`ファイル内で`\bibliography{}`と`\bibliographystyle{}`を設定する

### 論文執筆中にやること
1. 上記のcollectionに引用する可能性のある論文のPDFを追加
1. 引用する際にBibTeXのキーを用いる

## VSCode LaTeXshop

## BibTeX
