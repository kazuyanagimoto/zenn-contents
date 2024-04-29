---
title: "Rで論文を書く実践的なテクニック集 (tinytable編)"
emoji: "🧮"
type: "tech" 
topics: ["r", "tinytable"]
published: true
---

:::message

2022年に書いたRで論文を書く実践的なテクニック集の[テーブル編](https://zenn.dev/nicetak/articles/r-tips-table-2022)をtinytable版で書き直したものです.　Quartoで書かれた[英語版](https://kazuyanagimoto.com/blog/2024/04/29/)もありますので, そちらも参考にしてください.

:::

# `kableExtra`, `gt` から `tinytable` の時代へ

近年, Rで表を作成するためのパッケージとして `kableExtra` と `gt` が人気を集めてきました. 私は `kableExtra` を使って論文（$\LaTeX$）で表を作成し, `gt` を使ってスライド (revealjs) で表を作成しており, 以前行った[Rワークショップ](https://github.com/kazuyanagimoto/workshop-r-2022)やZennでの[解説記事](https://zenn.dev/nicetak/articles/r-tips-table-2022)でも`kableExtra`を念頭においておりました.

しかし, 2024年4月現在, [tinytable](https://vincentarelbundock.github.io/tinytable/)が従来のパッケージと比べ軽くて使いやすく, 今後のスタンダードになっていくと確信しており, 以前書いた記事を更新する必要があると考えました. この記事では, `tinytable` を使って論文に必要な表を作成する方法を紹介します.

## `tinytable` とは？

`tinytable` は, [Vincent Arel-Bundock](https://github.com/vincentarelbundock) (`modelsummary`のメンテナー) によって開発されたミニマル（zero-dependency, baseRのみを使用）でありながら強力な表を作成するためのパッケージです. `modelsummary` パッケージとシームレスに連携するように設計されており, Rで行えるほとんどの推定方法に対応しています. Rで回帰表を作成する場合, 現在は`modelsummary`が最有力候補であり, そのバックエンドに採用されていることからも, `tinytable` が今後の主流になることは間違いありません.

# `tinytable` の基本

```r
library(dplyr)
library(tidyr)
library(tinytable)
```

ここでは私がワークショップ内で用いた [the Madrid traffic accident dataset](https://datos.madrid.es/portal/site/egob/menuitem.c05c1f754a33a9fbe4b2e4b294f1a5a0/?vgnextoid=7c2943010d9c3610VgnVCM2000001f4a900aRCRD&vgnextchannel=374512b9ace9f310VgnVCM100000171f5a0aRCRD&vgnextfmt=default)を用います. このデータセットは, 2019年から2023年までのマドリード市内で発生した交通事故に関する情報を含んでおり, 事故の種類, 事故の日時, 事故の場所, 事故の原因, 事故に関わった人の属性, 事故の結果などが含まれています. データの[ダウンロード]((https://github.com/kazuyanagimoto/kazuyanagimoto.github.io/blob/main/blog/2024/04/29/download_accident_bike.R))や[クリーニング](https://github.com/kazuyanagimoto/kazuyanagimoto.github.io/blob/main/blog/2024/04/29/clean_accident_bike.R)に関してはリンクのコードを参照してください.

```r
dir_post <- here::here("blog/2024/04/29/")
data <- arrow::read_parquet(file.path(dir_post, "data", "cleaned.parquet")) |>
  mutate(is_died = injury8 == "Died within 24 hours",
         is_hospitalized = injury8 %in% c("Hospitalization after 24 hours",
                                          "Hospitalization within 24 hours",
                                          "Died within 24 hours"))
```

まず, 事故に関わった人の人数と天候に関するクロス集計表を作成します.

```r
tab_count <- data |>
  filter(!is.na(weather), !is.na(gender)) |>
  summarize(n = n(), .by = c(year, gender, weather)) |>  
  pivot_wider(names_from = c(gender, year), values_from = n) |>
  arrange(weather) |>
  select(weather, starts_with("Men"), starts_with("Women"))

tab_count
```

```r
# A tibble: 6 × 11
  weather   Men_2019 Men_2020 Men_2021 Men_2022 Men_2023 Women_2019 Women_2020
  <fct>        <int>    <int>    <int>    <int>    <int>      <int>      <int>
1 sunny        24399    14969    19208    20679    22451      11971       6958
2 cloud         1159     1190     1325     2082     2011        555        554
3 soft rain     2126     1198     1281     1930     1224       1068        542
4 hard rain      386      202      386      527      317        222         96
5 snow             2        2      124        5       NA         NA         NA
6 hail            11        5        6        4        3          3          3
# ℹ 3 more variables: Women_2021 <int>, Women_2022 <int>, Women_2023 <int>
```

`tinytable` は `tt()` 関数を使って表を作成します.

```r
tt_count <- tab_count |>
  `colnames<-`(c("", rep(2019:2023, 2))) |>
  tt() |>
  group_tt(i = list("Good Weather" = 1, "Bad Weather" = 3),
           j = list("Men" = 2:6, "Women" = 7:11)) |>
  style_tt(i = c(1, 4), bold = TRUE) |>
  format_tt(replace = "-")

tt_count |>
  theme_tt("tabular") |>
  save_tt(file.path(dir_post, "tex", "table_count.tex"),
          overwrite = TRUE)
```

![Number of Persons Involved in Traffic Accidents](/images/r-tips-tinytable-2024/table_count.png)

ポイントは

- `group_tt()` で行と列を ($\LaTeX$ の`multirow`や`multicolumn`のように) グループ化
- `style_tt()` で行を太字や斜体に
- `format_tt()` でセルを数値やパーセンテージに変換. `replace`引数で`NA`のセルを指定した文字に置き換えられます
- `tt()` 関数では (`kableExtra`の`col.names`引数のように) 列名を変更できないので, `colnames<-()` を使う. 詳しくは[#194](https://github.com/vincentarelbundock/tinytable/issues/194)の議論を参照してください
- 表を _plain_ な表 (つまり `\begin{table}` と `\end{table}` がない) として保存するには, `theme_tt("tabular")` を使います

:::details LaTeXの表をQuartoのHTML記事にSVG形式で挿入する小技

[英語版のQuarto記事](https://kazuyanagimoto.com/blog/2024/04/29/)では, $\LaTeX$の表をSVG形式で挿入しています. Quarto記事内では以下の2ステップで`tinytable`オブジェクトをSVG形式の図に変換できます.

**1. `tinytable`オブジェクトをPDFファイルとして保存する.**

```r
tt_count |>
  save_tt(file.path(dir_post, "img", "table_count.pdf"),
          overwrite = TRUE)
```

`tinytable::save_tt()`はとてもパワフルな関数で, ファイルの拡張子によって出力形式を変更できます.　拡張子が`.pdf` の場合, `tinytex`パッケージを使って1つのPDFファイルとしてコンパイルします.

**2. PDFファイルをSVGファイルに変換する.**

````markdown
```{bash}
#!/bin/bash
pdf2svg img/table_count.pdf img/table_count.svg
```
````

:::


# modelsummary

```r
library(modelsummary)
library(fixest)
```

`tinytable`はそもそも`modelsummary`と連携するために開発されたパッケージです. そのため, `modelsummary`を使って回帰分析の結果を表にすることができます.　`modelsummary`のversion 2.0.0以降では, `tinytable`がデフォルトの表作成パッケージになっています. 例えば, 以下のような６つのロジット回帰モデルを推定したとします.

```r
setFixest_fml(..ctrl = ~ type_person + positive_alcohol + positive_drug |
                          age_c + gender)
models <- list(
    "(1)" = feglm(xpd(is_hospitalized ~ ..ctrl),
                  family = binomial(logit), data = data),
    "(2)" = feglm(xpd(is_hospitalized ~ ..ctrl + type_vehicle),
                  family = binomial(logit), data = data),
    "(3)" = feglm(xpd(is_hospitalized ~ ..ctrl + type_vehicle + weather),
                  family = binomial(logit), data = data),
    "(4)" = feglm(xpd(is_died ~ ..ctrl),
                  family = binomial(logit), data = data),
    "(5)" = feglm(xpd(is_died ~ ..ctrl + type_vehicle),
                  family = binomial(logit), data = data),
    "(6)" = feglm(xpd(is_died ~ ..ctrl + type_vehicle + weather),
                  family = binomial(logit), data = data)
)

modelsummary(models)
```

デフォルトで以下のような表が作成されます.

![modelsummary default table](/images/r-tips-tinytable-2024/modelsummary.png)

論文で使える形にするために, 以下のようにカスタマイズします.

```r
cm  <-  c(
    "type_personPassenger" = "Passenger",
    "type_personPedestrian" = "Pedestrian",
    "positive_alcoholTRUE" = "Positive Alcohol"
)

gm <- tibble(
    raw = c("nobs", "FE: age_c", "FE: gender",
            "FE: type_vehicle", "FE: weather"),
    clean = c("Observations", "FE: Age Group", "FE: Gender",
              "FE: Type of Vehicle", "FE: Weather"),
    fmt = c(0, 0, 0, 0, 0)
)

tt_reg <- modelsummary(models,
  stars = c("+" = .1, "*" = .05, "**" = .01),
  coef_map = cm,
  gof_map = gm) |>
  group_tt(j = list("Hospitalization" = 2:4,
                    "Died within 24 hours" = 5:7))

tt_reg |>
  theme_tt("tabular") |>
  save_tt(file.path(dir_post, "tex", "table_reg.tex"),
          overwrite = TRUE)
```

- `coef_map` で係数の名前を変更します
- `gof_map` で統計量 (goodness-of-fit) を選択し, 名前を変更します
- `modelsummary`関数は`tinytable`オブジェクトを返すので, `tinytable`の関数 (`group_tt()`や`style_tt()`) を使って表を整えることができます


![Logit Regression of Hospitalization and Death within 24 Hours](/images/r-tips-tinytable-2024/table_reg.png)

# おわりに

この記事では, `tinytable` を使って論文に必要な表を作成する方法を紹介しました. 試しに使っていく過程で, `tinytable` が `kableExtra` や `gt` と比べて以下の理由で使いやすいと感じました.

- `kableExtra` や `gt` のほとんどの機能をカバーしている. `multirow` や `multicolumn`, セルのハイライト, セルのフォーマット, 数式の表示などができる
- HTML や LaTeX だけでなく, PDF (`tinytex`を用いて) や [Typst](https://typst.app) にもエクスポートできる
- `kableExtra` や `gt` よりもコンパイルが速い. これは `tinytable` が baseR のみを使用している小さなパッケージであるためだと思います

みなさまの研究の一助となれば幸いです🥂