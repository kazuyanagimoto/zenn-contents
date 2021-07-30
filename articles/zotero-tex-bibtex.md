---
title: "VSCode + Zotero + BibTeXによる論文執筆ワークフロー"
emoji: "📝"
type: "tech" 
topics: ["tex", "latex", "bibtex", "zotero", "vscode"]
published: true
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
https://github.com/nicetak/bibtex-demo
また、VSCodeのRemote Containersを用いて、OSに依存しない完全な再現が可能です。^[ただし、 Zoteroのインストールを除きます。]

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

これらの方法は、文献情報自体も自動で取得してくれるので便利なように見えます。しかし、私はあまりおすすめしません。理由は簡単で、文献情報が**取得できない**または**間違いがある**場合があるからです。

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

### BibTeX
#### 1. `natbib`の設定
「著者名(年)」のような引用の形式を扱うために`natbib.sty`を読みこみます。これは`.bst`ファイルの依存にもよるので分野ごとに違う可能性があります。後述する`econ-aea.bst`の前提となっているのが`natbib`のため、ここで読み込みます。

プリアンブルに以下を追加
```tex: main.tex
\usepackage[longnamefirst]{natbib}
```

#### 2. `\bibliography{}`と`\bibliographystyle{}`を設定する
BibTeXの設定は簡単で、
- `\bibliography{}` → `.bib`ファイルの名前
- `\bibliographystyle{}` → 参考文献や引用の形式。`.bst`ファイル
の二つを`.tex`ファイルに記述するだけです。^[拡張子の`.bib`や`.bst`はなくても構いません。]
```tex: main.tex
\bibliography{bibtex-demo.bib}
\bibliographystyle{econ-aea.bst}
```
私の専門は経済学なので、ここでは`econ-aea.bst`を使います。それぞれの専門や投稿先に合わせて変更してください。ひとまず`main.tex`と同じディレクトリにおいておけば問題ありません。
:::details econ-aea.bstとは？
American Economic Association (AEA)の出版するジャーナルに準拠した形式の`.bst`ファイル。作者の武田史郎先生による解説を読むことをおすすめします。
[経済学におけるBibTeXの利用](https://qiita.com/shiro_takeda/items/92adf0b20c501548355e)
:::

#### 3. BibTeXのキーを用いて引用する
`natbib`では引用の際に`\citet`または`\citep`を用います。この時使用するキーはZotero内の文献情報の一番上にある`Citation Key:`の部分です。
![](/images/zotero-tex-bibtex/citation-key.png)
*Piketty et al. (2018)のCitation Key*

```tex
\citet{pikettyDistributionalNationalAccounts2018b}
```
なお、このキーはZoteroの設定によって出力形式を変えることができます。
(例：`piketty2018b:distributional`)

BibTeXの便利な点として、文中で**引用された文献だけ**が参考文献リストにのることです。したがって、Zoteroのcollectionには最終的な引用の可能性を考えずに関連する文献を**どんどん追加しましょう。**

::::details 補論: subfilesを使う場合
論文を書く際に、章や節ごとに`.tex`ファイルを分けたいということがあるでしょう。その際、よく使われるパッケージが`subfiles`です。しかし、`\bibliography{}`は一度しか宣言できないため、`subfiles`とは相性が悪いです。これは`ifthen`文を用いれば解決できます。
```tex: main.tex
\documentclass{article}
\usepackage{subfiles}
\usepackage{ifthen}

% BibTeX
\usepackage[longnamesfirst]{natbib}
\usepackage{hyperref}

\begin{document}

% For Subfiles with BibTeX
\newboolean{isMain}
\setboolean{isMain}{true}

% Body
\subfile{1_intro}
\subfile{2_body}
\subfile{3_concl}

% Reference
\newpage
\bibliography{bibtex-demo.bib}
\bibliographystyle{econ-aea.bst}

\end{document}
```

```tex: 1_intro.tex
\documentclass[./main]{subfiles}
\newboolean{isMain}
\setboolean{isMain}{false}

\begin{document}
\section{Introduction}
% 中略

\ifthenelse{\boolean{isMain}}{ %pass 
}{ %else 
    \bibliography{bibtex-demo.bib}
    \bibliographystyle{econ-aea.bst} 
}

\end{document}
```

これは`subfiles`において個別ファイルのプリアンブルが無視されることを利用して
- 個別ファイルのコンパイルでは`isMain`が`false`なので、個別ファイル内の`\bibligoraphy{}`が宣言される
- `main.tex`のコンパイルでは`isMain`が`true`なので、個別ファイルの`\bibliography{}`は無視される

ことによって達成されています。
::::


## VSCode LaTeX Workshop Extension
VSCodeで$\LaTeX$を使う場合、LaTeX Workshop Extensionを使うことを強くおすすめします。
https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop

コード補完、マウスオーバー、スニペット機能。どれをとっても申し分ないです。また、SyncTeXに対応しているので、PDFをクリックするとコードの該当箇所に飛ぶ、なんていうことも可能です。`subfiles`にも対応しているので、通常のコンパイルと同様に`subfiles`の個別ファイルをコンパイルすることも可能です。
![](/images/zotero-tex-bibtex/latex-workshop.gif)
公式のページの機能の紹介がかなり分かりやすいので、上記のリンクから見ることをおすすめします。

### $\LaTeX$ にGrammarlyを直接かける方法
[Grammarly](https://www.grammarly.com/)といえば、言わずと知れた英文添削ソフトです。公式にはWordやGoogle Docsなどに対応していますが、実は非公式ながら$\LaTeX$に直接Grammarlyをかける方法があります。
#### VSCodeの場合
以下のVSCodeの拡張機能を使うだけです。ログインにも対応しているので、有料会員の機能も使うことができます。詳しい使い方は以下のリンク先を参考にしてください。
https://marketplace.visualstudio.com/items?itemName=znck.grammarly

#### Overleafの場合
Grammarly公式のChrome拡張である以下を入れた状態で
https://chrome.google.com/webstore/detail/grammarly-for-chrome/kbfnbcaeplbcioakkpcpgfkobkghlhen
以下の拡張を入れます。
https://chrome.google.com/webstore/detail/overleaf-textarea/iejmieihafhhmjpoblelhbpdgchbckil
詳しい使い方は上記のChromeストアのOverleaf textareaのページを見てください。

## おわりに

以上が私が普段使っている$\LaTeX$環境です。一度設定してしまえば、
- 引用する可能性のある文献をZoteroに追加する
- 引用する際はBibTeXのキーを使う

を繰り返すだけです。また、英文添削も拡張機能を入れるだけで自動化することができます。みなさまの論文ライフが少しでも楽になれば幸いです。