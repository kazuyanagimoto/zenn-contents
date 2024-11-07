---
title: "Quarto + Typstで爆速アカデミックスライド"
emoji: "🔬"
type: "tech"
topics: ["quarto", "typst", "r"]
published: false
---

# Beamerひしめく経済学の世界の片隅で

2年前, Quarto + Reveal.jsによるアカデミックなスライドの作り方を解説しました.

https://zenn.dev/nicetak/articles/quarto-tips-2022

以来, デザイン等をアップデートしながら, Quarto + Reveal.jsでスライドを作成してきました. Beamerが98%, PowerPointが2%という経済学の世界では異端ながらも, Quarto + Reveal.jsは私にとってはデザインとカスタマイズ性から最適な選択肢でした.

しかし, PDFスライドがデファクトスタンダードな世界でReveal.jsを用いたHTMLスライドを使うことには限界があると感じました. Reveal.jsはPDFに変換することができますが, いくつかの問題がありました.

1. HTML版だと1枚に収まっていたスライドがPDF版だと下部分がはみ出てしまうことがある
1. 数式のレンダリングがうまくいかないことがある
1. 日本語のフォントのサイズが重すぎて`embed-resource: true`で埋め込めない
1. **PDF版ではHyperlinkが機能しない. つまりボタンのリンクができない.**

特に最後の点が致命的で, Robustness CheckやDetailsへのリンクをBeamerのボタンで表す文化のある経済学の世界ではかなり不便で不評でした.

とはいえ, Beamerはコンパイルが遅く, デザインのカスタマイズが難しいという問題もあります.^[十分な$\LaTeX$の知識があればRevealjsとほとんど同様のカスタマイズ性があるはずですが, 私はその仕様の複雑さに挫折しました. Typstのフォントやレイアウト等の関数はHTMLに近く, その意味で「直感的」であると感じました.] そこで, Quarto + Typstという高速にコンパイルでき, 文法が平易かつグラフの調整しやすい方法に着目しました. また, Quarto + Typstによるスライドを作るテンプレートは存在しなかったため, 自分で作成しました.

https://github.com/kazuyanagimoto/quarto-clean-typst

これはGrant McDermottさんの[Clean theme](https://github.com/grantmcdermott/quarto-revealjs-clean)というReveal.jsテーマをTypstに移植したものです. このテンプレートを使うことで, Quarto + TypstでBeamerのようなPDFスライドを作成することができます.

@[speakerdeck](aecc63d3b8e14cb39729197c4d396066)

この[デモ](https://kazuyanagimoto.com/quarto-slides-typst/slides/quarto-clean-typst/clean.pdf)に用いたコードは[ここ](https://github.com/kazuyanagimoto/quarto-slides-typst/blob/main/slides/quarto-clean-typst/clean.qmd)にあります.

## Touying

このテンプレートはフレームワークとして[Touying](https://touying-typ.github.io)^[名前の由来は中国語の"投影" (tóuyǐng) から来ています. これは$\LaTeX$における"Beamer"がビデオプロジェクターを意味するドイツ語から来ていることに対応をしています. ちなみにPolyluxはそのドイツで有名なプロジェクターの一つのブランド名です.]を採用しています. Typstでスライドを作成するフレームワークとしては[Polylux](https://polylux.dev/book/)が有名ですが, `h2`タグをスライドの区切りかつタイトルとして使うことのできるTouyingはQuartoとの親和性が高いと感じました. Touyingは簡潔な文法ながら, PolyluxやBeamerに負けないパワフルな機能を持っています.

なお以下では特段解説しませんが, Quartoでは`{=typst}`ブロックを使うことでTypstのコードを記述することができ, Touyingの全ての機能を利用することができます. 特に[数式中のアニメーション](https://touying-typ.github.io/docs/dynamic/equation)などは, Typstの数式記法に依存しているため, Typstネイティブのコードでしか実現できません. また, Quarto + Typstにおける基本的な機能は[こちら](https://quarto.org/docs/output-formats/typst.html)を参照してください.


:::details 数式中のアニメーション

Touyingでは以下のような`pause`や`meanwhile`コマンドが数式中でも使うことが可能です.

````md:slides.qmd
```{=typst}
#slide[
  Touying equation with pause:

  $
    f(x) &= pause x^2 + 2x + 1  \
         &= pause (x + 1)^2  \
  $

  #meanwhile

  Touying equation is very simple.
]
```
````

さらに, Typst独自の数式記法ではなく, $\LaTeX$の記法からTypst記法に変換できる[MiTeX](https://github.com/mitex-rs/mitex)をサポートしているため

````md:slides.qmd
```{=typst}
#touying-mitex(mitex, `
  f(x) &= \pause x^2 + 2x + 1  \\
      &= \pause (x + 1)^2  \\
`)
```
````

のように$\LaTeX$記法を用いることもできます.

:::

# `quarto-clean-typst`の使い方

## スライドの作成

基本的には, Quartoのスライド記法 (特にReveal.jsの) を使います. `h2`レベルのヘッダーがスライドの区切りかつスライドタイトルであり, `h1`がセクションタイトル, `h3`がスライドのサブタイトルとなります.


````md:slides.qmd
# Section Slide as Header Level 1

## Slide Title as Header Level 2

### Subtitle as Header Level 3

You can put any content here, including text, images, tables, code blocks, etc.

- first unorder list item
    - A sub item

1. first ordered list item
    1. A sub item

Next, we'll brief review some theme-specific components.

- Note that _all_ of the standard Quarto + Typst
[features](https://quarto.org/docs/output-formats/typst.html) 
can be used with this theme
- Also, all the [Touying](https://touying-typ.github.io) features can be used by **Typst native code**.
````

![](/images/quarto-typst-slides/slides_example.png)

## YAMLによるカスタマイズ

スライドの基本的な要素のテーマはYAMLヘッダーでカスタマイズすることができます.

```yaml:slides.qmd
format:
  clean-typst:
    font-size: 20pt
    font-heading: Josefin Sans
    font-body: Montserrat
    font-weight-heading: bold
    font-weight-body: normal
    font-size-title: 2.5em
    font-size-subtitle: 1.5em
    color-jet: "#272822"
    color-accent: "009F8C"
    color-accent2: "B75C9D"
```

- `font-size`: デフォルトのフォントサイズ
- `font-heading`: スライドタイトルのフォント
- `font-body`: 本文のフォント
- `font-weight-heading`: スライドタイトルのフォントウェイト
- `font-weight-body`: 本文のフォントウェイト
- `font-size-title`: タイトルスライドのタイトルのフォントサイズ
- `font-size-subtitle`: タイトルスライドのサブタイトルのフォントサイズ
- `color-jet`: テキストのカラー. 基本的に`#000000`はコントラストが強すぎます. デフォルトは`#131516`です.
- `color-accent`: サブタイトル, ボタン, リンクなどの色です
- `color-accent2`: `.alert`の色です.

また, タイトルスライドは以下のように記述します.
  
````yaml:slides.qmd
title: Quarto Clean Theme
subtitle: A Minimalistic Theme for Quarto + Typst + Touying
date: today
date-format: long
author:
  - name: Kazuharu Yanagimoto
    orcid: 0009-0007-1967-8304
    email: kazuharu.yanagimoto@cemfi.edu.es
    affiliations: CEMFI
````

![](/images/quarto-typst-slides/title_slides.png)

## 独自機能

TouyingやQuartoのTypstの機能に加えて, このテンプレートにはいくつかの独自の機能があります.

````md:slides.qmd
## Components

### Alerts & Cross-refs {#sec-crossref}

Special classes for emphasis

- `.alert` class for default emphasis, e.g. [the second accent color]{.alert}.
- `.fg` class for custom color, e.g. [with `options='fill: rgb("#5D639E")'`]{.fg options='fill: rgb("#5D639E")'}.
- `.bg` class for custom background, e.g. [with the default color]{.bg}.

To cross-reference, you have several options, for example:

- Beamer-like .button class provided by this theme, e.g. [[Appendix]{.button}](#sec-appendix)
- Sections are not numbered in Touying, you cannot use `@sec-` cross-references
````

![](/images/quarto-typst-slides/alerts_crosrefs.png)

- `.alert`: デフォルトの強調. `color-accent2`の色が使われます.
- `.fg`: カスタムカラーの強調. `options='fill: rgb("#5D639E")'`で指定します. デフォルトは`#"e64173"`です.
- `.bg`: カスタム背景の強調. `options='fill: rgb("#5D639E")'`のように色を指定できます. デフォルトは`#"e64173"`です.
- `.button`: Beamerのボタンに相当するクラス. マークダウン記法のリンクでリンク先のセクション名を指定することで, ハイパーリンクを貼ることができます.

## 局所的なカスタマイズ

スライドを作成する際, 一部のスライドだけスタイルを変更したり, 行間を調整したいことがよくあります. Quartoの[Typst CSS](https://quarto.org/docs/advanced/typst/typst-css.html)を用いたり, 独自機能の`{{vspace 1em}}`を使うことで局所的なカスタマイズが可能です.

````md:slides.qmd
## Ad-hoc Styling

### Typst CSS

- Quarto supports [Typst CSS](https://quarto.org/docs/advanced/typst/typst-css.html) for simple styling
- You can change [colors]{style="color: #009F8C"}, [backgrounds]{style="background-color: #F0F0F0"}, and [opacity]{style="opacity: 0.5"} for `span` elements

::: {style="font-size: 30pt; font-family: 'Times New Roman'"}

You can also change the font size and family for `div` elements.

:::

{{< v 1em >}}

### Vertical Spacing

- A helper shortcode `{{{< v DIST >}}}` is provided to add vertical spacing
- This is converted to a Typst code `#v(DIST)` internally.

{{< v 2em >}}

This is a `2em` vertical spaced from above.
````

![](/images/quarto-typst-slides/adhoc_styling.png)

## カスタマイズ関数の登録

Quartoの拡張機能である[latex-environment](https://github.com/quarto-ext/latex-environment)のように, Typstの関数を`div`や`span`要素として登録することができます. 以下の例では, `small`と`small-cite`という関数を登録しています. このようにすることで, 自作の関数をQuartoの中で`[hogehoge]{.small}`のように使うことができます.

```yaml: slides.qmd
format:
  clean-typst:
    include-in-header: "custom.typ"
    commands: [small, small-cite]
```

```typst: custom.typ
#let small(it) = text(size: 0.8em, it)

#let _small-cite(self: none, it) = text(
  size: 0.7em,
  fill: self.colors.neutral-darkest.lighten(30%),
  it
)

#let small-cite(it) = touying-fn-wrapper(_small-cite.with(it))
```

`small-cite`は, スライドの中で内部的に用いられているパラメータ(`self.colors.neutral-darkest`, YAML上の`color-jet`に相当)を使っているため, `touying-fn-wrapper`を使う必要があります. 実用上は`color-accent`などの色を使いたい時などに使うことを想定しています.


## アニメーション

Touyingには, 上から順にアニメーションを適用する[simple animations](https://touying-typ.github.io/docs/dynamic/simple)と, 複雑なアニメーションを実装する[complex animations](https://touying-typ.github.io/docs/dynamic/complex)があります. このテンプレートでは, どちらも利用可能です. なお, `handout: true`をYAMLヘッダーに追加することで, アニメーションを無効にしたPDFを作成することができます.

### シンプルなアニメーション

`{{ pause }}`や`{{ meanwhile }}`を使うことで, アニメーションを簡単に実装することができます.

````md:slides.qmd
## Simple Animations {#sec-simple-animation}

Touying's [simple animations](https://touying-typ.github.io/docs/dynamic/simple) is available as `{{{< pause >}}}` and `{{{< meanwhile >}}}`

{{< pause >}}

**Animations in Lists**

Simple animations can be used in lists

- First {{< pause >}}
- Second
````

### 複雑なアニメーション

`{.complex-anim repeat=}`クラスと`{.uncover options=''}`や`{.only options=''}`クラスを使うことで, 複雑なアニメーションを実装することができます. シンプルなアニメーションと異なり, アニメーションのコマ数(`repeat`)を指定し, 全体を`{.complex-anim}`で囲む必要があります. なお, `#alternatives`関数はTypstのネイティブコードでしか使えません.

````md:slides.qmd
## Complex Animations {#sec-complex-animation}

:::: {.complex-anim repeat=4}

Touying's [complex animations](https://touying-typ.github.io/docs/dynamic/complex) is available as `{.complex-anim repeat=4}` environment.


At subslide `#self.subslide`{=typst}, we can

use [`{.uncover}` environment]{.uncover options='"2-"'} for reserving space,

use [`{.only}` environment]{.only options='"2-"'} for not reserving space,

```{=typst}
#alternatives[call `#only` multiple times \u{2717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives. But only works in a native Typst code. \
```

::: {.only options='4'}

### Other Features

- All the animation functions can be used in Typst Math code [[Appendix]{.button}](#sec-math-animations)
- `handout: true` in YAML header is available for handout mode (without animations)

:::

::::
````


## グラフ

通常のQuartoのようなRコードチャンクを使ってグラフを作成することができます. 以下は`ggplot2`を使った例です. スライドの場合は二つのグラフを横に並べることが多いので, `ggplot2`の`facet_wrap()`を用いた例と, Quartoのチャンクオプション`layout-ncol: 2`を使った例を示します.

````md:slides.qmd
## Figures

```{r}
#| fig-width: 10
#| fig-height: 4
#| fig-align: center

penguins |>
  filter(!is.na(sex)) |>
  mutate(lbl_facet = recode_factor(sex, `male` = "Male", `female` = "Female")) |>
  ggplot(aes(x = flipper_length_mm, y = bill_length_mm,
             color = species, shape = species)) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_color_manual(values = c(color_accent, color_accent2, color_accent3)) +
  facet_wrap(~lbl_facet) +
  labs(x = "Flipper Length (mm)", y = "Bill Length (mm)") +
  theme_quarto() +
  theme(legend.position = c(0.9, 0.1))
```

This is a `facet_wrap` example with `penguins` dataset.
````

![](/images/quarto-typst-slides/figure_facet.png)

````md:slides.qmd
## Figures

```{r}
#| layout-ncol: 2
#| fig-width: 5
#| fig-height: 3
#| fig-align: center

penguins |>
  ggplot(aes(x = flipper_length_mm, y = body_mass_g,
             color = species, shape = species)) +
  geom_point(size = 3) +
  scale_color_manual(values = c(color_accent, color_accent2, color_accent3)) +
  labs(x = "Flipper Length (mm)", y = "Body Mass (g)") +
  theme_quarto() +
  theme(legend.position = c(0.9, 0.1))

penguins |>
  ggplot(aes(x = flipper_length_mm, color = species, shape = species)) +
  geom_density() +
  scale_color_manual(values = c(color_accent, color_accent2, color_accent3)) +
  labs(x = "Flipper Length (mm)", y = "Density") +
  theme_quarto() +
  theme(legend.position = c(0.9, 0.1))
```

This is an example of `layout-ncol: 2` for two figures.
````

![](/images/quarto-typst-slides/figure_layout.png)

他には, [patchwork](https://patchwork.data-imaginist.com)パッケージを使ってグラフを組み合わせることもできます.


## テーブル

論文中の表は[tinytable](https://vincentarelbundock.github.io/tinytable/)パッケージで作成することができます. このパッケージはTypstに対応しているため, HTMLや$\LaTeX$の表を作るのと同様の手順で表を作成することができます.
`tinytable`の使い方は以前の記事も参照してください.

https://zenn.dev/nicetak/articles/r-tips-tinytable-2024

````md:slides.qmd
```{r}
tt_sum <- penguins |>
  filter(!is.na(sex)) |>
  summarize(across(bill_length_mm:body_mass_g, ~mean(.x, na.rm = TRUE)),
            .by = c(species, sex)) |>
  tidyr::pivot_wider(names_from = sex,
                     values_from = c(bill_length_mm, bill_depth_mm,
                                     flipper_length_mm, body_mass_g)) |>
  select(species, ends_with("_male"), ends_with("_female")) |>
  `colnames<-`(c("", rep(c("Bill Length (mm)", "Bill Depth (mm)",
                                  "Flipper Length (mm)", "Body Mass (g)"),
                                times = 4))) |>
  tt() |>
  group_tt(j = list("Male" = 2:5, "Female" = 6:9)) |>
  format_tt(j = c(2:9), digits = 4)
```
````

なお, `tinytable::style_tt()`と`.complex-anim`を組み合わせることで, 表をアニメーションでハイライトすることも可能です.

````md:slides.qmd
:::: {.complex-anim repeat=3}
::: {.only options='1'}
```{r}
tt_sum
```
:::

::: {.only options='2'}
```{r}
tt_sum |>
  style_tt(i = 2, background = color_accent,
           color = "white", bold = TRUE)
```
:::

ABBREVIATED

::::

````

![](/images/quarto-typst-slides/tinytable.png)

また, 回帰表を作成できる`modelsummary`パッケージのデフォルトバックエンドはversion2.0.0以降`tinytable`に変更されたので, `modelsummary`を普段通り使うことが可能です.

````md:slides.qmd
```{r}
cm <- c(
  "speciesChinstrap" = "Chinstrap",
  "speciesGentoo" = "Gentoo",
  "sexmale" = "Male",
  "year" = "Year"
)

gm <- tibble(
  raw = c("nobs", "r2"),
  clean = c("Observations", "$R^2$"),
  fmt = c(0, 3)
)

list("(1)" = lm(bill_length_mm ~ species, data = penguins),
     "(2)" = lm(bill_length_mm ~ species + sex, data = penguins),
     "(3)" = lm(bill_length_mm ~ species + sex + year, data = penguins),
     "(4)" = lm(body_mass_g ~ species, data = penguins),
     "(5)" = lm(body_mass_g ~ species + sex, data = penguins),
     "(6)" = lm(body_mass_g ~ species + sex + year, data = penguins)) |>
  modelsummary(stars = c("+" = .1, "*" = .05, "**" = .01),
               coef_map = cm,
               gof_map = gm) |>
  group_tt(j = list("Bill Length (mm)" = 2:4, "Body Mass (g)" = 5:7))
```
````

![](/images/quarto-typst-slides/modelsummary.png)

### Typst 数式問題

Typstの数式記法は$\LaTeX$とは異なります. Quarto上で記述する場合, $\LaTeX$記法がPandoc側で自動でTypst記法に変更されるため問題ありません. しかし, 表中の数式はそのままではTypst記法に変換されません (`tinytable`はあくまでデータフレームをTypstのコードに変換するだけです). 

ありがたいことにTypstには[MiTeX](https://typst.app/universe/package/mitex/)という$\LaTeX$記法をTypst記法に変換するパッケージがあります. 表中の$\LaTeX$記法の数式は`#mitex()`をかませることでTypst記法に変換することができます. 以下のような関数を作成し, `tinytable`に適応することで表中の数式をMiTeXでレンダリングすることができます.

```r
theme_mitex <- function(x, ...) {
    fn <- function(table) {
        if (isTRUE(table@output == "typst")) {
          table@table_string <- gsub("\\$(.*?)\\$", "#mitex(`\\1`)", table@table_string)
        }
        return(table)
    }
    x <- style_tt(x, finalize = fn)
    x <- theme_tt(x, theme = "default")
    return(x)
}
```

詳細は`tinytable`のGitHub Issue [#345](https://github.com/vincentarelbundock/tinytable/issues/345)を参考にしてください.
https://github.com/vincentarelbundock/tinytable/issues/345