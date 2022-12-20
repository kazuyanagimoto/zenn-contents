---
title: "Quartoでアカデミックなスライドを作るためのTips"
emoji: "💠"
type: "tech" 
topics: ["r", "quarto"]
published: true
---

:::message
これは [R Advent Calendar 2022](https://qiita.com/advent-calendar/2022/rlang) 20日目の記事です.
:::

# はじめに

## Beamerはお好きですか?
先日, [Quarto](https://quarto.org/)で作ったスライドを学会発表で使ってみました. 私の専門は経済学ですが, 経済学の世界では98%が$\LaTeX$のBeamer, 2%ぐらいがPowerPointを用いてプレゼンをします. 私は個人的にはBeamerのデザインを好みませんし, PowerPointは進行中のプロジェクトの場合, 保守性 (つまり簡単に変更できるか) に問題があると思っています. Quartoは
1. そこそこ良いデザイン. カスタマイズ性も高い
1. デザイン面にこだわらなければ, マークダウン記法なので, Beamerと同程度の労力で作成できる
1. 保守性が高い. 文中で変数を利用できるので, モデルや分析を多少変更しても数字が自動でアップデートされる

などの点でかなり気に入っています. 

以下では, 学術目的のプレゼンを行う際のQuartoでのTipsを紹介します. Quartoでの基本的なスライドの作り方は[公式ドキュメント](https://quarto.org/docs/presentations/revealjs/) やTom MockさんのRStudioカンファレンスでの[スライド](https://rstudio-conf-2022.github.io/get-started-quarto/materials/05-presentations.html#/presentations)などを参考にしてください. 学会発表で用いたスライドはまだ公開できる段階にないので, [HTML版スライド](https://kazuyanagimoto.com/quarto-slides-example/code/slides/quarto_academic_tips/slides.html)と[コード](https://github.com/nicetak/quarto-slides-example/blob/main/code/slides/quarto_academic_tips/slides.qmd)を参考にしてみてください. PDF版はSlideDeckに上げてみました.

@[speakerdeck](e2861c33218c48e48ca7abe270758847)

# データ
私はスライドの中で図表をレンダリングしています. つまり, 論文中の図表の画像ファイルを埋め込んでいるわけではありません. これは,
1. 論文中の図表で適切なフォントサイズはスライド上では小さすぎる
1. ハイライトなどの自由がきかない
1. スライドのテーマとデザインを合わせたい (後述)

などの理由からです. そのため別ファイルにて図表に起こす直前のデータフレームを保存しておき, 図表をプロットする直前で読み込む形式を取っております.

```r
load("tb_hoge.rds")
tb_hoge |>
  ggplot(aes(x, y)) +
  geom_point()
```


このデータフレームを用いれば, スライド中の地の文で図表中の数値を簡単に利用できます.

```md
2021年のデータでは, `r tb_hoge$value[tb_hoge$year == 2021]`%の人が…
```

また, 分析を多少変更して`tb_hoge.rds`の値が変更になったとしても, レンダリングし直せば数値がアップデートされる点も便利です.^[経済学だと, サンプルの年齢層を変更したり, モデルの設定を少し変更することで結果が少し変わることなどのことがよく起きます. またクリーニングや分析のミスなどを見つけた場合に軽微な修正が入ることも多々あります.]


# テーマ

Quartoでは[デフォルトのテーマ](https://quarto.org/docs/presentations/revealjs/themes.html)が10個ほど用意されています. これらもいいデザインですが, 図と合わせたいという観点から, `custom.scss` を作成して独自のテーマを用いています. 現在は [xaringanthemr](https://pkg.garrickadenbuie.com/xaringanthemer/) の`style_mono_accent()`風にしています. カスタムできる部分については[公式ドキュメント](https://quarto.org/docs/presentations/revealjs/themes.html#customizing-themes)を参照してください.

## 部分的なCSS設定
よく使うCSSの設定は`custom.css`に記述しますが, その場しのぎ的にCSSの設定を使いたい場合があります (例えば少しだけフォントのサイズを変更したい場合.) その場合は,

```md
::: {style="font-size: 0.68"}

ちょとだけ小さくしてスペースを詰めたい文章

:::
```

のように, `style=` 以下にCSSを書き込むことで変更できます.


## Fragment

QuartoもといReveal.jsではそこそこ複雑なアニメーションが使えます. 実例を見たほうがわかりやすいと思うので, Tom Mockさんのスライドの [この部分](https://rstudio-conf-2022.github.io/get-started-quarto/materials/05-presentations.html#/lists)からのスライドをみるとよいと思います.

これとは別に, [ここ](https://community.rstudio.com/t/quarto-revealjs-presentation-2-columns-with-pause/151950)で議論されているように, `. . .`は`columns`環境やヘッダータグなどに対してうまく動かないことがあります. このような場合は, `fragment` 環境を設定するとうまくいく場合が多いです.

# 図
## テーマ

スライドデザインの基本は要素を少なくすることです. そのため, 図表であってもフォントと基本色をスライドに合わせることが重要だと思います. [xaringanthemr](https://pkg.garrickadenbuie.com/xaringanthemer/)はスライドデザインのテーマとそれに応じた`ggplot`のテーマを自動で作成してくれたため, かなり便利でした. 残念ながらQuartoに対応したものはまだ作成されていないと思うので, 以下のように自分で関数を宣言しました.

https://github.com/nicetak/quarto-slides-example/blob/main/code/slides/quarto_academic_tips/slides.qmd#L61-L113

本家xaringanthemerでは`ggplot2::update_geom_defaults`を用いて, `ggplot2::geom_*` 関数群の色も再定義していますが, ２色以上用いる場合はどのみち色を手動で指定しなければならないので, あえて上書きしていません. 以下のように使います.
```r
color_base <- "#1C5253"
tb_hoge |>
  ggplot(aes(x, y)) +
  geom_point(color = color_base) +
  theme_quarto()
```

## ハイライト

Rで図のハイライトといえば[gghighlight](https://cran.r-project.org/web/packages/gghighlight/vignettes/gghighlight.html)でしょう.

```r:１つ目のスライド
p <- tb_hoge |>
  ggplot(aes(x, y)) +
  geom_col(color = color_base) +
  theme_quarto()

p
```

```r:２つ目のスライド
p + gghighlight(x == "Japan")
```

などの使い方によって, 効果的に話を展開できるでしょう.

# 表

## `markdown` vs. `kableExtra` vs. `gt`?

HTMLスライドにおける表の作成方法としては基本的に上記の３択になると思っています. どれも一長一短ですが,

**Markdown Table**
- ハイライトができない
- 複数行や複数列をまとめてさらに高いレベルのラベルをつける (つまり$\LaTeX$の`multirow` `multicol` のような)ことができない


**kableExtra**
- すこしだけ`gt`より書きづらい. 例えば, %表記の列は文字列に変換した上で`align`を指定しないといけない
- ハイライトが`gtExtras`と比べると面倒

などの理由で`gt`を使っています. 論文用の$\TeX$ファイルを出力する場合は, 下記の数式問題から`kableExtra`一択です.

## 数式問題

実は, Quartoで数式混じりの表を用いる場合少し大変です. そもそも`gt`は$\LaTeX$記法の数式をサポートしていません (GitHubの[Issue](https://github.com/rstudio/gt/issues/375)に2019年から挙がっていますが, すぐには解決されなさそうです.)  また, `kableExtra` の数式がQuarto上でだけレンダリングされないことはQuartoの[Issue](https://github.com/quarto-dev/quarto-cli/issues/555)に挙がっています. 簡単な解決策は, 

```r
kableExtra::kbl(data, format="markdown")
```

のようにmarkdown tableとして出力することです. しかし, これでは上で述べたmarkdown tableの問題を抱えることになります.

そこで私は完全な$\LaTeX$記法の数式は諦めて, 
- Unicodeのギリシャ文字 (θ, τ, δなど)
- <sup> や <sub> のHTMLタグ

を用いて`gt::fmt_markdown`で評価することでお茶を濁しています. 表中の数式で複雑な式になることはまれなので, 現状は問題なく使えています.

```r
tibble(a = c("θ = 0", "τ<sup>δ-1</sup>")) |>
  gt() |>
  fmt_markdown(columns = everything())
```

## ハイライト

`gt` パッケージ本体でも`tab_style`という関数で表内のセルをハイライトすることはできます. しかしこれは冗長な書き方をしないといけないので, 行/列単位でよければ`gtExtras`パッケージの`gt_highlight_rows()`や`gt_highlight_cols()`が便利です.

# 出力

## HTML or PDF?

学会発表は用意されたPCを使うと思いますが, ブラウザが入っていないPCというものは想定しづらいのでhtml形式でも問題ないと思います. YAMLヘッダーに以下のように記述すれば, self-containedなhtmlファイル１つだけ出力されるので, PDFファイルのように手軽に持ち運べるでしょう.^[`self-contained: true` のオプションはdeprecated warningが出ます.]
```yaml
format:
  revealjs:
    standalone: true
    embed-resources: true
```

しかし, さまざまな場面でPDFのフォーマットでの提出が求められると思います. また, 実際にPDFでプレゼンするかは別として, 保険のためにも手元にあるといいと思います. 
1. HTMLファイルをブラウザで開いた状態で `E` を押す
1. ブラウザの印刷→PDFとして保存をする

とすれば, PDFを出力できます. なお, fragmet単位で別ページにしたい場合は, YAMLで `pdf-separate-fragments: true` を指定しましょう.


### ハイパーリンク問題
各スライドに飛ぶようなハイパーリンクは, 実質的に<h2>タグにジャンプすることにほかならないので, 以下のようにリンクを貼ることができます.

```md
## A Slide {#sec-slide}

<a href="#/sec-detail">detail↗</a>

## A Detail Slide {#sec-detail}

<a href="#/sec-slide">↩︎</a>

```

しかし, 私が把握している限りだと上記のようなPDF出力をした場合, リンクは反映されません. どなたか解決法をご存知でしたらご教示いただければ幸いです.

## おわりに
以上が, Quartoを学術発表で使ってみた際の私なりの工夫です. QuartoのスライドはBeamerとほとんど同じ労力で作成でき, デザインの自由度や数字の保守性が高く, かなり学術向きだと思います. お役に立てたら幸いです.
