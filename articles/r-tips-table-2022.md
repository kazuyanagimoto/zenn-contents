---
title: "Rで論文を書く実践的なテクニック集 (テーブル編)"
emoji: "🧮"
type: "tech" 
topics: ["r", "kableextra"]
published: true
---

:::message
この記事はRで論文を書く実践的なテクニック集のテーブル編です.

1. [プロジェクト・クリーニング編](https://zenn.dev/nicetak/articles/r-tips-cleaning-2022)
1. [グラフ編](https://zenn.dev/nicetak/articles/r-tips-graph-2022)
1. テーブル編

:::

@[speakerdeck](2d865070926c4f67bf047fc7f641472a)

https://github.com/kazuyanagimoto/workshop-r-2022



# `kableExtra`


$\LaTeX$ 用の表作成は基本的に`kableExtra`を使えばよいです.
例えば以下のようなデータフレームを持っているとします.

```r
tab
```
```
# A tibble: 6 × 9
# Groups:   weather [6]
  weather   n_Men_2019 n_Men_2…¹ n_Men…² n_Men…³ n_Wom…⁴ n_Wom…⁵ n_Wom…⁶ n_Wom…⁷
  <fct>          <int>     <int>   <int>   <int>   <int>   <int>   <int>   <int>
1 sunny          24399     14969   19208   19420   11971    6958    9417    9298
2 cloud           1159      1190    1325    1633     555     554     630     774
3 soft rain       2126      1198    1281    1408    1068     542     605     716
4 hard rain        386       202     386     352     222      96     210     179
5 snow               2         2     124       5      NA      NA      38       1
6 hail              11         5       6       4       3       3       1       2
# … with abbreviated variable names ¹​n_Men_2020, ²​n_Men_2021, ³​n_Men_2022,
#   ⁴​n_Women_2019, ⁵​n_Women_2020, ⁶​n_Women_2021, ⁷​n_Women_2022
```


`kableExtra` なら簡単に`.tex`ファイルにできます.

```r
library(kableExtra)
options(knitr.kable.NA = '')

ktb <- tab |>
  kbl(format = "latex", booktabs = TRUE,
      col.names = c(" ", 2019:2022, 2019:2022)) |>
  add_header_above(c(" ", "Men" = 4, "Women" = 4)) |>
  pack_rows(index = c("Good" = 2, "Bad" = 4))

ktb |>
  save_kable(here("output/tex/kableextra/tb_accident_bike.tex"))
```

![](https://github.com/kazuyanagimoto/workshop-r-2022/blob/main/code/slides/advancedr/img/kableextra.png?raw=true)

ポイントとしては

- `booktabs = TRUE` は `booktabs` パッケージを使うので見た目がよくなります
- 列名は`col.names`項で指定します
- 行と列は`pack_rows()` と `add_header_above()` でまとめることができます
- `kbl(format = "latex")` を指定すると `save_kable()` でtexファイルに出力できます
- タイトルは論文用の本文用のtexファイルであとづけしています.

より複雑な表については Zhu ([2021](https://cran.r-project.org/web/packages/kableExtra/vignettes/awesome_table_in_pdf.pdf)) を読むことをおすすめします.
ここまで複雑な $\LaTeX$ の表はPythonやJuliaだと簡単には作成できないのではないかと思います.

# `modelsummary`

回帰分析の表は`modelsummary` を使います. 以下のような回帰結果をリストでもっているとします.


```r
library(fixest) # for faster regression with fixed effect

models <- list(
    "(1)" = feglm(is_hospitalized ~ type_person + positive_alcohol + positive_drug | age_c + gender,
                family = binomial(logit), data = data),
    "(2)" = feglm(is_hospitalized ~ type_person + positive_alcohol + positive_drug | age_c + gender + type_vehicle,
                family = binomial(logit), data = data),
    "(3)" = feglm(is_hospitalized ~ type_person + positive_alcohol + positive_drug | age_c + gender + type_vehicle + weather,
                family = binomial(logit), data = data),
    "(4)" = feglm(is_died ~ type_person + positive_alcohol + positive_drug | age_c + gender,
                family = binomial(logit), data = data),
    "(5)" = feglm(is_died ~ type_person + positive_alcohol + positive_drug | age_c + gender + type_vehicle,
                family = binomial(logit), data = data),
    "(6)" = feglm(is_died ~ type_person + positive_alcohol + positive_drug | age_c + gender + type_vehicle + weather,
                family = binomial(logit), data = data)
)
```



計算を早くするために`fixest::feglm()` を使っていますが通常の`lm()` や `glm()` で問題ありません.

`modelsummary()`のデフォルトの設定で以下のようなテーブルを作ることができます.

```r
library(modelsummary)
modelsummary(models)
```

![](/images/r-tips-table-2022/kableextra_init.png)

論文に使える形にするために以下のように調整します.

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

modelsummary(models,
  output = "latex_tabular",
  stars = c("+" = .1, "*" = .05, "**" = .01),
  coef_map = cm,
  gof_map = gm) |>
  add_header_above(
    c(" ", "Hospitalization" = 3, "Died within 24 hours" = 3)) |>
  row_spec(7, hline_after = T) |>
  save_kable(here("output/tex/modelsummary/reg_accident_bike.tex"))
```



![](https://github.com/kazuyanagimoto/workshop-r-2022/blob/main/code/slides/advancedr/img/modelsummary.png?raw=true)

調整した項目は以下です

- `coef_map = cm` で係数のラベルを変更
- `gof_map = gm` で統計量を選択&ラベル付け
- 出力が `kableExtra` 形式なので `add_header_above()` や `row_spec()` で見た目を調整
- タイトルとノートは本文用texファイルで記述
- `output = "latex_tabular"` を使うことで `table` タグなしのtexファイルが出力できる

# テーブル編まとめ

**`kableExtra` & `modelsummary`**

- `kableExtra` でtibble (データフレーム) から簡単にtexのテーブルを作成できる
- `modelsummary` で回帰結果から `kableExtra` のテーブルを出力できる
- 出力されたtexファイルとそれをコンパイルする本文のtexファイルはレポジトリ内の`output/tex/`と`code/thesis/`から確認できます

**より詳しく**

- 公式ドキュメント[modelsummary](https://vincentarelbundock.github.io/modelsummary/articles/modelsummary.html) と Zhu ([2021](https://cran.r-project.org/web/packages/kableExtra/vignettes/awesome_table_in_pdf.pdf))
- [gt](https://gt.rstudio.com/articles/intro-creating-gt-tables.html)は `kableExtra` に替わりうる強力なテーブル作成パッケージです (が数式に対応していないので, 論文用には使っていません. スライドではよく使います.)

解説は以上です. 皆様の研究生活がもっと楽になりますように！