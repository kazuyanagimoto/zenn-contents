---
title: "Stataをモダンな環境で使う"
emoji: "💻"
type: "tech" 
topics: ["vscode", "stata"]
published: true
---

# Stataを使わなければならないあなたへ

Stataは非常に強力かつ広く使割れている統計解析ソフトウェアですが, プログラミング言語として考えると機能がかなり限られています. 私自身はStataを研究で使うことはほとんどなくなりましたが, それでも経済学の世界にいるとStataを使わざるを得ない場面があります.

この記事では, 私なりにStataの不満を解消する方法を紹介します. 私自身, Stataをメインでは使わないため他にも良い方法があるかもしれませんが, 参考になれば幸いです.

## Stataへの不満

私なりのStataへの不満 (のうち解決できたもの) は以下の通りです.

1. 好きなエディタでコードを書きたい
1. プロジェクトのルートからパスを指定したい
1. Jupyter notebook や Quarto でレポート形式にしたい
1. IDEのような環境が欲しい

これらの不満を私がメインで使っているVSCodeにて解決する方法を紹介します. 以下のレポジトリをプロジェクトの参考にしていただければと思います.

https://github.com/kazuyanagimoto/modern-stata

# 好きなエディタでコードを書く

近年のLLMの進展により, コードを書く際にAIによる補完の効かないエディタやチャットやエージェントモードを使わないというのは時間の無駄です. そのため, Stataのコードを書く際にもVSCodeを使いたいというのが私の希望です.

実はこれ自体はそんなに難しくなく, VSCodeの拡張機能の中にはいくつかStataのコードをハイライトしてくれるものがあります. 実行方法に関しては, 次節で紹介する方法以外にもコマンドラインでStataを実行する方法があります.

```bash
stata
```

![](/images/stata-modern-2025/stata-command.png)

あまり知られていないのですが, Stataはコマンドラインから実行できます. 私は, 以下のように`stata`というエイリアスを`~/.zshrc`に設定して使っています.

```bash:~/.zshrc
alias stata="/Applications/Stata/StataMP.app/Contents/MacOS/stata-mp"
```

これはMacの例ですが, LinuxやWindowsでも似たような設定は可能だと思います. この時点でStataのGUIを開く必要があまりなくなります.

```bash
stata --help
```

```bash
stata-mp:  usage:  stata-mp [-h -q -s -b] ["stata command"]
        where:
            -h          show this display
            -q          suppress logo, initialization messages
            -s          "batch" mode creating .smcl log
            -b          "batch" mode creating .log file
            -rngstream# set rng to mt64s and set rngstream to #;
                          see "help rngstream" for more information;
                          note that there must be no space between
                          "rngstream" and #

        Notes:
            xstata-mp is the command to launch the GUI version of Stata/MP
            stata-mp  is the command to launch the console version of Stata/MP

            -b is better than "stata-mp < filename > filename".
```

私は最終実行として, `stata -b main.do` のように実行することが多いです. これにより, `main.do`というファイルを実行し, 実行結果を`main.log`というファイルに保存します.

# プロジェクトのルートからパスを指定したい

Stataにはdoファイルというスクリプトファイルのようなものがありますが, そのファイル自体のパスという概念がありません. そのため, ファイルのパスの指定方法が絶対パスを指定するか, `cd PATH` でカレントディレクトリを変更するぐらいしかありません. またこれは自分のPC上のパスをハードコードする必要があるため, 他者と共有する場合は, 相手にパスを変更してもらう必要があります.

Rの[here](https://here.r-lib.org) というパッケージはプロジェクトのルートディレクトリを (`.git`や`.Rproj`などから) ほとんど自動で取得し, 以下のようなパスの指定を可能にします.

```r
here::here("path", "to", "file.csv")
```

Pythonには[pyprojroot](https://pypi.org/project/pyprojroot/), Juliaには [ProjectRoot.jl](https://jolars.github.io/ProjectRoot.jl/stable/) というパッケージがあり, 同様のことが可能です. これにより, 他者と共有する際にパスを変更する必要がなくなります. また, JupyterやQuartoなどのノートブックを用いた場合, 相対パスがIDEとノートブックで異なるという問題が生じたりしますが, これらのパッケージを使い, すべてプロジェクトルートからのパスを指定することで解決できます.

これをなんとかStata上で実現しようとしたのが World Bankの[repkit](https://worldbank.github.io/repkit/articles/reproot-files.html) にある `reproot` というコマンドです. `reproot` は以下の二つのファイルを適切に配置することで, プロジェクトのルートディレクトリを取得します.

- `reproot-env.yaml`: ホームディレクトリ `~/reproot-env.yaml` に配置. 各PCごとに1回だけ設定する
- `reproot.yaml`: プロジェクトのルートディレクトリに配置. プロジェクトごとに設定, 共有される

```bash
~/
├── reproot-env.yaml
└── github/
    ├── project1/
    │   ├── reproot.yaml
    │   └── (project files)
    └── project2/
        ├── reproot.yaml
        └── (project files)
```

### `reproot-env.yaml` の設定

`reproot-env.yaml` では, 各プロジェクトの入りうるトップレベルのディレクトリを絶対パスで指定します. 私の場合は, コードを置くディレクトリは `~/github/` 直下にあるので, 以下のように設定しています.

```yaml:~/reproot-env.yaml
recursedepth: 1
paths:
  - "/Users/kazuharu/github/"
skipdirs:
  - ".git"
```

`recursedepth` によって再帰的に`reproot.yaml`を探す深さを指定できます. これが多ければ多いほどプロジェクトのルートディレクトリを見つけるのに時間がかかります. 例のような`github`直下にプロジェクトが必ずある場合は, `recursedepth: 1` で十分です. 

経済学で人気なDropboxでプロジェクトを管理している場合は, 以下のようにDropboxのパスも追加してもいいかもしれません:

```yaml:~/reproot-env.yaml
recursedepth: 1
paths:
  - "/Users/kazuharu/github/"
  - "/Users/kazuharu/Dropbox/"
skipdirs:
  - ".git"
```

### `reproot.yaml` の設定

`reproot.yaml` ではプロジェクト名とそのグローバルマクロ名を指定します.

```yaml:~/github/project1/reproot.yaml
project_name: project1
root_name: here
```

私はプロジェクト名は分かりやすくフォルダの名前, ルート名はRの`here`の慣習に従って, `here` というグローバルマクロにしています.

### `reproot` の使い方

パッケージとして`repkit`をインストールします.

```stata
ssc install repkit
```

以下のように, `reproot` コマンドを一度実行して, `here` というグローバルマクロを宣言した後, そのマクロを用いてデータのパスを指定します.

```stata
qui reproot, project("project1") roots("here")
use "$here/path/to/data.dta", clear
```

細かい話ですが, Windowsの`\`を使うとWindow以外ではパスが正しく解釈されないので, `/`を使うことをお勧めします. これは, Windowsでも正しく動作します.

# Jupyter notebook や Quarto でレポート形式にしたい

Stataは17以降, Pythonとの連携が強化されており, [`pystata`](https://www.stata.com/python/pystata18/) というパッケージがその際たる例です. [`nbstata`](https://hugetim.github.io/nbstata/user_guide.html) は `pystata` を用いて, Stataの Jupyter用のkernelを提供しています. これにより, Jupyter notebook上でStataのコードを実行し, 結果を表示することができます. さらに, Quartoにおいても, `jupyter: nbstata` と指定することで, Stataのコードを実行し, 結果を表示することができます.

![](/images/stata-modern-2025/jupyter-stata.png)

Quartoでレポートを作成した場合以下のようなコードになります. また, [ここ](https://kazuyanagimoto.com/modern-stata/notebook/penguins.html)から実際にQuartoで作成したStataのHTMLレポートを確認できます.

https://github.com/kazuyanagimoto/modern-stata/blob/main/notebook/penguins.qmd

# IDEのような環境が欲しい

長らくStataをVSCodeでIDEのように使うことはできませんでしたが, 先日発表されたKyle Butts氏による[vscode-stata](https://marketplace.visualstudio.com/items?itemName=kylebutts.vscode-stata) という拡張機能によってそれが可能になりました. この拡張機能は, `nbstata` をバックエンドとしてStataのコードを実行し, 結果を表示することができます. (Atom時代のHydrogenを思い出します.)

![](/images/stata-modern-2025/vscode-stata.png)

使い方は簡単で, `*%%` というコメントで挟まれる部分がJupyterのコードセルのように扱われ, その部分を実行することができます.

https://github.com/kazuyanagimoto/modern-stata/blob/main/code/penguins.do

## (おまけ) Stata MCP について

[Stata MCP](https://marketplace.visualstudio.com/items?itemName=DeepEcon.stata-mcp) という拡張機能もありますが, これはStataとLLMとを連携させることに主眼が置かれているようです. 私が紹介した方法でもStataのコードをGitHub Copilot Chatなどで書かせたりすることはできるので, どこまでこの拡張機能が役に立つかまで検証できていません. Stataをメインで使う方は, こちらの拡張機能も試してみると良いかもしれません.


# おわりに

以上が私がStataの実行環境を改善するために行ったことです. Stataと共にある皆さまの生活のお役に立てれば幸いです🥂