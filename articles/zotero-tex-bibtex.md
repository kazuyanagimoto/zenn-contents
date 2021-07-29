---
title: "私が教えて欲しかったLaTeXワークフロー"
emoji: "📝"
type: "tech" 
topics: ["tex", "latex", "bibtex", "zotero", "vscode"]
published: false
---

## はじめに

### $\LaTeX$は誰も教えてくれない
みなさん、 いつから$\LaTeX$を使いはじめたでしょうか。 大学一年生でしょうか。 ゼミや研究室に入った時でしょうか。 はたまた卒論や修論を執筆しはじめた時でしょうか。 

そのとき、 誰か今節丁寧に教えてくれましたか？ 少なくとも、私の周りではそんなことありませんでした。誰も教えてないのに、みんな元から知ってたかのような顔をして、当たり前のように使っている。でも使い方について話題に上がることもないから、みんながなんとなくで使っている。そんな感じじゃないでしょうか。

### BibTeXや文献管理ソフトはもっと教えてくれない
テンプレートを使いながら、コマンドをググればなんとか$\LaTeX$で文章を自力で作成することは可能です。しかし、文献引用についてはどうでしょう。世の中にはZoteroやMendeleyといった文献管理ソフトやBibTeXという文献引用のために便利なツールがあります。しかし、誰も教えてくれないから、修論を書き終わったり、Publicationをもっている人でさえも、使っていない人は少なくないのではないでしょうか。

この記事では、文献引用の自動化を主眼においた、$\LaTeX$執筆のワークフローを紹介します。みなさまが、退屈なことはすべてツールにまかせて、論文に集中できることを願ってやみません。


## 環境
### ソフトウェア
使用するソフトウェアは$\LaTeX$の他に以下の二つです
- [Zotero](https://www.zotero.org/) (文献管理、 BibTeX出力)
- [Visual Studio Code](https://code.visualstudio.com/) (主に$\LaTeX$のエディターとして)

どちらのソフトもWindows、 Mac、 Linuxで使えるためOSに関わらず使えるワークフローであると思います。^[$\LaTeX$のインストール方法だけは異なり苦労する箇所かもしれません。 近々Windows PCが支給される予定なので、 支給され次第、 加筆予定です。] なお、 私の実行環境は以下の通りです。
- MacBook Pro 13-inch, 2017. MacOS Big Sur 11.4

:::details なぜOverleafではないのか
近年$\LaTeX$の執筆環境としては[Overleaf](https://ja.overleaf.com/)が人気です。 たしかに、 面倒な$\LaTeX$環境のセットアップ要らずで、 同時編集も可能な点はとても魅力的です。 私自身も宿題程度の軽いコラボレーションなどで利用します。 しかし以下の点を不満に感じています。

- Dropbox、 GitHubとの連携が有料である
- BibTeX、 図表の細かい修正を行う際にいちいちアップロードをするのが面倒 (特にGitHubで管理している場合、 その度にpushする必要がある)
- プロジェクトあたりのファイル数に上限がある (大きいプロジェクトの後半はおそらくキツい)

VSCodeを利用した場合、
- 無料であり、 なんの制限もない
- 後述するLaTeX Workshop Extensionが高機能で、 Overleafと遜色ない
- 他の言語のエディターとしても優秀なので、 同じUIでさまざまな作業が行える

などのメリットを感じています。 

また、 ネックとなるTeXのインストールですが
- Macの場合、 Homebrewのコマンドで一発
- そもそも Docker + VSCode + Remote Containers でOSに依存しない環境構築できる^[Dockerさえ理解していれば、 人気のあるDocker Imageを利用するか、 `apt update && apt install texlive-full`で簡単にセットアップできます。]

などの理由で特に不便を感じておりません。 

しかしながら、 本ワークフローを行うにあたっては、 BibTeXファイルが適切にアップロードされていれば、 **Overleafを使っても問題ありません。**
:::


#### インストール (Mac)
[Zotero](https://www.zotero.org/) も[VSCode](https://code.visualstudio.com/)もそれぞれのサイトからインストール可能ですが、 Macの場合は[Homebrew](https://brew.sh/index_ja)を用いることもできます。 TeXのインストールもまとめて
```shell
brew update && brew install mactex-no-gui visual-studio-code zotero
```
のコマンドで一発です。おそらくTeXのパッケージ管理ツールである`tlmgr`のアップデートが必要なので、以下のコマンドも実行してください。
```shell
sudo tlmgr update --self
sudo tlmgr update --all
```

:::details Homebrewとは?
MacOS用のパッケージマネージャーです。 ターミナルからコマンドで、 ソフトウェアのインストール、 アップデート、 削除ができるようになります。 Homebrew自体のインストールは、 [Homebrewのサイト](https://brew.sh/index_ja)上のコマンドをコピーして、 ターミナルで実行するだけです。 
:::

### ファイル構成
このワークフローに対応したレポジトリを用意しました。 ファイル構成の例としてご活用ください。
また、 VSCodeのRemote Containersを利用することで、 OSに依存せずに完全な再現が可能です。^[ただし、 Zoteroのインストールを除きます。]

:::details Remote Containersとは?
Dockerを用いて仮想マシン上でVSCodeを実行する環境です。 仮想マシン上に同一の環境を構築することで、 OSによらず共通の環境で作業ができます。 Dockerについてはいずれ記事にする予定ですが、 少し説明が長くなるので、 ご存知ない方はここではとばしてください。
:::




## 文献引用ワークフロー
論文中での適切なフォーマットでの引用と参考文献リストの作成を自動化します。
ポイントは
- 引用する可能性のある論文をZoteroで一ヶ所にまとめる(引用しなくてもいい)
- 引用する際にBibTeXのキーを使う

だけで、 文献引用のあらゆる面倒ごとから解放されるという点です。 ほとんど自動化されているので、 **ミスもなくなります。** 

### Zotero
:::message
デモンストレーションのために`demo`というライブラリーをZotero内に作成していますが、普段はデフォルトの`My Library`を使います。
:::
#### 1. プロジェクト用のcollectionを作成
![](/images/zotero-tex-bibtex/create-collection.gif)

#### 2. 文献の追加
Zoteroにアイテムを追加するにはいくつか方法があります.
1. ドラッグ&ドロップ
2. ブラウザのZotero拡張([Chrome](https://chrome.google.com/webstore/detail/zotero-connector/ekhagklcjbdpajgpjgmbionohlpdbjgc?hl=ja), [Firefox](https://chrome.google.com/webstore/detail/zotero-connector/ekhagklcjbdpajgpjgmbionohlpdbjgc?hl=en))

![](/images/zotero-tex-bibtex/drag-drop.gif)
*ドラッグ&ドロップ*

これらの方法は、文献情報自体も自動で取得してくれるので便利なように見えます。しかし、私はあまりおすすめしません。理由は簡単で、文献情報が**取得できない**または**間違いがある**からです。

私がおすすめするのはやり方は以下です。
1. 版元のウェブサイトから`.ris`ファイルまたは`.bib`ファイルをダウンロードする
1. ZoteroのFile→Importから、ダウンロードしたアイテムを元にアイテムを作る
1. 作成されたアイテムにPDFファイルを追加する
![](/images/zotero-tex-bibtex/download-ris.gif)
*The Quarterly Journal of Economicsのウェブサイトからの`.ris`ファイルのダウンロード*
![](/images/zotero-tex-bibtex/add-from-ris.gif)
*`.ris`ファイルからアイテムの追加*
![](/images/zotero-tex-bibtex/pdf-on-item.gif)
*PDFファイルをアイテムに紐付ける*

:::message alert
アイテムをインポートした場合、Libraryにアイテムが追加されるようなので、Libraryを開いてドラッグ&ドロップなどでcollectionにも追加してください。
:::

#### 3. `.bib`ファイルの作成
1. collectionのフォルダを右クリックして`export collection`をクリック
1. `exportOption.keepUpdated`を選択して^[この名前はアップデートで変わることがあります]、OKをクリック
1. `main.tex`と同一のディレクトリに保存します^[`main.tex`内で相対パスを指定すればどこに保存してもいいです]
![](/images/zotero-tex-bibtex/export-bib.gif)

:::message
`exportOption.keepUpdated`のおかげで、新しくアイテムを追加した場合`.bib`ファイルも自動で変更されます。
:::

### $\LaTeX$

#### 1. 適切な`.bst`ファイルの設定

#### 2. `\bibliography{}`と`\bibliographystyle{}`を設定する

#### 3. BibTeXのキーを用いて引用する

#### 3. 補論: `subfiles`を使う



## VSCode LaTeX Workshop
