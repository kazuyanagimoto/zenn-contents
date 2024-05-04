---
title: "Quarto + TypstでCVを自動で作る"
emoji: "📄"
type: "tech" 
topics: ["quarto", "r", "typst"]
published: true
---

![](/images/quarto-typst-cv/thumbnail_cv_yanagimoto.png)

# Quarto + TypstでCV作成を自動化した

CSVファイルからQuartoとGitHub Actionsを用いて, CVを自動で生成するワークフローを作りました.

![](/images/quarto-typst-cv/workflow.drawio.png)

これを実現するためにQuartoのTypstテンプレートとして[quarto-awesomecv-typst](https://github.com/kazuyanagimoto/quarto-awesomecv-typst)とRによるサポートパッケージ[typstcv](https://kazuyanagimoto.com/typstcv/)も開発しました. 同様のプロジェクトとしてRmarkdown + TinyTexを用いる[mitchelloharawild/vitae](https://github.com/mitchelloharawild/vitae)がありますが, Quarto + Typstを用いることで, より高速なCV作成が可能になります.

私自身のCVとして実際に運用しているので, コードは以下のレポジトリを参照してください.

https://github.com/kazuyanagimoto/cv

### なぜTypstを使うのか

[Typst](https://typst.app)は$\LaTeX$に代わる新しい文書作成ツールです. マークダウンのようなシンプルな記法で, $\LaTeX$のような美しいドキュメントを作成することができます. また, $\LaTeX$と比べて高速で動作し, インストールの手間もありません. [Quarto](https://quarto.org)1.4からは出力先にTypstを選ぶことができるようになりました. TypstはQuartoに内蔵されているため, インストールする必要すらありません.

とはいえTypstはまだ開発途上であり, ジャーナルに投稿する際は$\LaTeX$を使わざるを得ないことも多いでしょう. 私自身も論文に使うには時期尚早であると考えていますが, CVのような個人の文章作成には十分使えると考えています. 今回はQuarto + Typstの実験的使用の意味もあって導入に至りました.

# CVの作成

## インストール

`typstcv`は現在R-universe (かGitHub)　のみで提供されているので以下のコマンドでインストールします.

```r
install.packages("typstcv", repos = "https://kazuyanagimoto.r-universe.dev")
```

Quartoテンプレートから始めるのがもっとも簡単です.

```shell
quarto use template kazuyanagimoto/quarto-awesomecv-typst
```

このコマンドを新しいディレクトリ上に, typstのテンプレートとQuartoのテンプレートが作成されます. デフォルトではエントリーが以下のようになっています.

````md
```{=typst}
#resume-entry(
  title: "On the Electrodynamics of Moving Bodies",
  location: " Annalen der Physik",
  date: "September 1905"
)
```
````

これを後述する`typst::resume_entry()`関数を用いて置き換えていきます.

## YAMLの設定

![](/images/quarto-typst-cv/awesomecv_header.png)

### 基本情報

```yaml
author:
  firstname: Albert
  lastname: Einstein
  address: "Rämistrasse 101, CH-8092 Zürich, Switzerland, Zürich"
  position: "Research Physicist ・ Professor"
  contacts:
    - icon: fa envelope
      text: ae@example.com
      url: "mailto:ae@example.com"
    - icon: PATH_TO_ICON/icon.svg
      text: example.com
      url: https://example.com
```

アイコンは[Font Awesome](https://fontawesome.com/)のフリーのアイコンを`fa`を前につけることで指定することができます.^[[duskmoon314/typst-fontawesome](https://github.com/duskmoon314/typst-fontawesome)を用いて実装しているのですが, いくつかのアイコンは正しく表示できないようです. その場合は, SVGファイルを指定することで対応することができます.] また, Font Awesomeが対応していないアイコンであっても, SVGファイルを指定することで利用することができます. Google scholarなどは, [Academicons](https://jpswalsh.github.io/academicons/)などからダウンロードできますし, 他にも[Bootstrap Icons](https://icons.getbootstrap.com)や[Simple Icons](https://simpleicons.org)などがあります ([Zennのロゴ](https://simpleicons.org/?q=zenn)もありますね!)


### フォント & カラー

```yaml
style:
   color-accent: "516db0"
   font-header: "Roboto"
   font-text: "Source Sans Pro"
format:
  awesomecv-typst:
    font-paths: ["PATH_TO_FONT"]
```

アクセントカラーとフォントを指定することができます. システムにインストールされているフォントを用いることができますが, GitHub Actionsなどでフォントファイルをレポジトリに含める場合は, パスを指定することで利用することができます.

## コンテンツの設定

### `typstcv::resume_entry()`

`resume_entry()`関数を用いて, データフレームからコンテンツを生成することができます.

```r
educ
#>               title            location        date          description
#> 1  Ph.D. in Physics Zürich, Switzerland        1905 University of Zürich
#> 2 Master of Science Zürich, Switzerland 1896 - 1900                  ETH
```

````r
```{r}
#| output: asis
educ |>
  resume_entry(
    title = "title",
    location = "location",
    date = "date",
    description = "description"
)
```
````

![](/images/quarto-typst-cv/awesomecv_educ.png)

QuartoのRコードチャンクでは, `output: asis`を**必ず指定してください**. これは, `resume_entry()`が生成したTypstコードを認識させるために必要です (以下の説明では省略します.) なお, データフレームの列名が`title`や`location`のように引数名と一致している場合は, 引数を省略することができます.

また, `details`引数を用いて, 箇条書きのエントリーを作ることができます. 以下の例では, `award`データフレームの`detail1`と`detail2`の列を箇条書きにして出力しています.

```r
award
#>                    title          location date         description
#> 1 Nobel Prize in Physics Stockholm, Sweden 1921 For his services to
#>               detail1                                          detail2
#> 1 Theoretical Physics Discovery of the law of the photoelectric effect
```

```r
resume_entry(award, details = c("detail1", "detail2"))
```

![](/images/quarto-typst-cv/awesomecv_award.png)

箇条書きの項目が多い場合は, 以下のように`grep()`を用いるのが簡便でしょう.

```r
resume_entry(award, details = grep("^detail", names(award)))
```

### `typstcv:date_formatter()`

`date_formatter()`関数を用いて, 日付順にソートし指定の形式で出力することができます.

```r
work
#>                 title            location      start        end
#> 1 Technical Assistant   Bern, Switzerland 1902-01-01 1908-01-01
#> 2    Junior Professor   Bern, Switzerland 1908-01-01 1909-01-01
#> 3 Associate Professor Zürich, Switzerland 1909-01-01 1911-01-01
#>             description
#> 1 Federal Patent Office
#> 2    University of Bern
#> 3  University of Zürich
```

```r
work |>
  format_date(
    start = "start",
    end = "end",
    date_format = "%Y",
    sep = "->",
    sort_by = "start"
  ) |>
  resume_entry()
```

![](/images/quarto-typst-cv/awesomecv_work.png)

# GitHub Actions & GitHub Pages

Quartoドキュメントであるため, GitHub Actionsを用いて簡単にビルドし, GitHub Pagesで公開することができます.

## データの用意

ローカルでコンパイルするのであれば, Google Spreadsheetなどからデータを取得するなどの方法がありますが^[[`googlesheets4`](https://googlesheets4.tidyverse.org)を用いるなど. [`datadrivencv`](https://nickstrayer.me/datadrivencv/)などもあります], GitHub Actionsを用いる場合は, CSVファイルを用いるのが簡便でしょう. 更新の際も, CSVファイルに新しい行を追加するだけでよいです.

```csv: data/education.csv
degree,start,end,institution,location
M.Sc.,2016-04-01,2019-03-31,University of Zurich,Zurich
Ph.D.,2019-04-01,2022-03-31,University of Zurich,Zurich
```

````r: cv.qmd
```{r}
#| output: asis
educ <- read.csv("data/education.csv",
                 colClasses = c("character", "Date", "Date",
                                "character", "character"))

educ |>
  format_date(end = "end", sort_by = "start") |>
  resume_entry(title = "degree",
               description = "institution")
```
````


## GitHub Actionsの設定

```yaml: .github/workflows/publish.yml
on:
  workflow_dispatch:
  push:
    branches: main

name: Quarto Publish

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Check out repository
        uses: actions/checkout@v4
      
      - name: Set up Quarto
        uses: quarto-dev/quarto-actions/setup@v2

      - uses: r-lib/actions/setup-r@v2
      - uses: r-lib/actions/setup-renv@v2

      - name: Render and Publish
        uses: quarto-dev/quarto-actions/publish@v2
        with:
          target: gh-pages
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

ビルドするためには, 少なくとも`rmarkdown`と`typstcv`のパッケージがインストールされている必要があります. 私は`renv`を用いてパッケージを管理しているため, `r-lib/actions/setup-renv@v2`を実行しています.

なお`renv`を用いたパッケージ管理に関しては以前の記事で解説をしています.

https://zenn.dev/nicetak/articles/r-tips-cleaning-2022#tips%3A-renv-%E3%81%AF%E7%A7%81%E3%81%9F%E3%81%A1%E3%82%88%E3%82%8A%E3%81%8B%E3%81%97%E3%81%93%E3%81%84

## GitHub Pagesの設定

### _quarto.yml

GitHub Pagesで必要なファイルだけを`docs`ディレクトリに出力するために, `_quarto.yml`を以下のように設定します.

```yaml: _quarto.yml
project:
  type: default
  output-dir: docs
```

### リダイレクトの設定

上記の設定だけでも, https://username.github.io/repo/cv.pdf でアクセスすることができますが, https://username.github.io/repo/index.html からリダイレクトすることで, https://username.github.io/repo/ でアクセスすることができるようになります. GitHub PagesのJekyllプラグインを用いて設定します.

```html: docs/index.html
---
redirect_to: "cv.pdf"
---
```

```yaml: docs/_config.yml
plugins:
  - jekyll-redirect-from
```

なお私の場合は, GitHub Pagesで自分のウェブサイトをホストし, カスタムドメインを設定しているため, アドレスが https://kazuyanagimoto.com/cv/ になっています.

# おわりに

以上で私がQuarto + Typstを用いてCVをCSVファイルからGitHub Actions上でビルドする方法を解説しました. CSVからCVを自動作成することで, データの更新が容易になりますし, バージョン管理もしやすくなります.

この[quarto-awesomecv-typst](https://github.com/kazuyanagimoto/quarto-awesomecv-typst)は, Byungjin Park氏の[Awesome-CV](https://github.com/posquit0/Awesome-CV)のPaul Tsouchlo氏による[Typst実装](https://typst.app/universe/package/modern-cv/)をさらに改変したものです. 至らない点があるかと思いますので, [GitHub Issues](https://github.com/kazuyanagimoto/quarto-awesomecv-typst)からお知らせいただけると幸いです. Pull Requestも歓迎です.