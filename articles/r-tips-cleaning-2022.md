---
title: "Rで論文を書く実践的なテクニック集 (プロジェクト・クリーニング編)"
emoji: "🧹"
type: "tech" 
topics: ["r", "renv", "dplyr"]
published: false
---

## ワークショップを開きました

先日, PhD学生向けに論文を書く際に役に立つRのテクニックのワークショップを行いました.

@[speakerdeck](2d865070926c4f67bf047fc7f641472a)


ワークショップ用のレポジトリは以下にあります.
https://github.com/kazuyanagimoto/workshop-r-2022


せっかく作った資料なので, 日本語での解説をしたいと思います. 長いので３つの記事に分けました.^[Quartoについてはあまりに基本的な説明しかしていないので省略します.]

1. プロジェクト・クリーニング編
1. [グラフ編](https://zenn.dev/nicetak/articles/r-tips-graph-2022)
1. [テーブル編](https://zenn.dev/nicetak/articles/r-tips-table-2022)

お役に立てれば幸いです.

# プロジェクトベースワークフロー

Q. なぜあなたのRコードは私のPC上で動かないのですか?

~~A. パスかパッケージのバージョンに問題があるからです~~

A. あなたが**R project**のもとで`here`や`renv`を使っていないせいです.


## R プロジェクト

ところでみなさんはこのボタンを押したことがあるでしょうか?

![](https://github.com/kazuyanagimoto/workshop-r-2022/blob/main/code/slides/advancedr/img/rproject.png?raw=true =400x)

このボタンはRプロジェクトを作るボタンです. 私は常にプロジェクトのフォルダを (つまりGitのレポジトリ単位) Rプロジェクトにしています.

なぜRプロジェクトを使うとよいのでしょうか. 理由は明快で, パスマネージャーの[here](https://here.r-lib.org/)とパッケージマネージャーの[renv](https://rstudio.github.io/renv/articles/renv.html)が使えるようになるからです.


## Tips: 常に`here::here()`でパスを指定する.

`here::here()` 関数はRプロジェクトのルート (つまり `*.Rproj` が置かれている場所) をルートディレクトリとして扱います.


```r
here::here()
```
```
[1] "/home/rstudio/workshop-r-2022"
```

常に `here::here()` を使ってルートからの相対パスを指定するようにしましょう.

```r
data <- readr::read_csv(
  here::here("data/tiny.csv")
)
```

このようにパスを指定していれば, Windows, Mac, Linux (もちろんDocker内でも) にかかわらずパスが正しく変換されます.

>If the first line of your R script is
>`setwd("C:\Users\jenny\path\that\only\I\have")`
>
>I* will come into your office and SET YOUR COMPUTER ON FIRE 🔥.
>
>-Bryan([2018](https://github.com/jennybc/zen-art-workflow))


## Tips: `renv` は私たちよりかしこい

- Rプロジェクトを作った直後に`renv::init()`を実行します. `renv/`フォルダと `renv.lock` ファイルが作られます.
- 作業を進めつつ頃合いをみて, `renv::snapshot()` を実行すると, その時に使用されているパッケージ情報が`renv.lock`ファイルに自動的に記録されます
- 共著者やコラボレーターは`renv::restore()`を実行することで`renv.lock`の情報からパッケージをすべてインストールできます


https://github.com/kazuyanagimoto/workshop-r-2022/blob/main/renv.lock


しかし, Dropbox^[経済学者はエンジニア並みにコードを書くのにgitやGitHubを使わない人が一定数います. また, やたらDropboxが人気であるという特徴もあります.]などのクラウドストレージと`renv`は相性が悪いです. 興味がある方は以下の`renv`がどのように動くかをお読みください.

:::details renv が裏でどのように動いているか
![](https://github.com/kazuyanagimoto/workshop-r-2022/blob/main/code/slides/advancedr/img/renv_backgroud.drawio.svg?raw=true)

`renv`は各Rのバージョンごと, 各パッケージのバージョンごとにグローバルキャッシュを持っています. プロジェクト内で利用するパッケージは`renv/`フォルダ内に収められていますが, 実体はシンボリックリンクが張られたグローバルキャッシュにあります. これは, 各プロジェクトごとにパッケージがインストールされるのを防いでおり, ストレージを圧迫しない仕組みになっています.

![](https://github.com/kazuyanagimoto/workshop-r-2022/blob/main/code/slides/advancedr/img/renv_cloud.drawio.svg?raw=true)
しかし, このプロジェクトフォルダがクラウドストレージで共有されていると, シンボリックリンクが切れてしまいます. また仮にシンボリックリンクが切れていなくても, WindowsとMacでは利用されているRのバイナリが違うため, そもそもライブラリを共有してはいけません. `renv.lock` ファイルのみが共有されるべきです.

これらを解決するには特定のファイルやフォルダを共有されないようにクラウドストレージ側で設定しないといけません. (e.g. [Dropbox](https://help.dropbox.com/sync/ignored-files)) しかし, そもそも`renv/`下のパッケージは自動で _git-ignored_ されているので, GitHubを使っていればなんの問題もありません.

:::

## (発展) Docker

万能に見える`renv`ですが, これが扱えるのはパッケージのバージョンのみです.
もし問題が以下の原因であった場合は解決できません.

- **Rのバージョン** ⇒ 常に最新のバージョンを使う. Dockerを使う
- **R以外の依存関係** (地理データ関連など) ⇒ Dockerを使う
- **OS** (Windowsバイナリ特有のバグなど) ⇒ Dockerを使う

これらの問題はDockerを使うことで解決できます.

**Docker**

- バーチャルマシン. OS (Linux), ソフトウェア (Rや他のソフト), やパッケージの情報を設計図 (Dockerfile) に書いてビルドします
- 常にDocker上で作業していれば, そのDockerfileを共有するだけで, 相手は全く同一の作業環境を構築することができます


# 戦略的なデータクリーニング

私はデータクリーニングで行うべきこととして以下の４つのことが挙げられると思っています.

1. Tidyなデータフレームの作成
1. 命名
1. 型変換
1. 保存

Tidyなデータフレームとは`tidyverse`の開発者であるHadley Wickham氏によって
提唱されているデータ分析で用いるべき理想的なデータフレームの形式をいいます.

>**Tidy Data** (Wickham ([2014](https://www.jstatsoft.org/article/view/v059i10)), Wickham ([2017](https://r4ds.had.co.nz/)))
>
>1. 各変数は列をなす
>1. 各標本は行をなす
>1. 各値はセルである


`tidyverse`パッケージ群はTidyなデータフレームを作るためのライブラリ (`dplyr`や`tidyr`), またはTidyなデータを前提とするライブラリです (`ggplot2`など).

この部分は`tidyverse`の基礎として, 多くの書籍や講座で解説されている部分ですので省略します. 実際のワークショップでは, [An Introduction to `tidyverse`](https://kazuyanagimoto.com/workshop-r-2022/code/slides/tidyverse/) と題して簡単な説明を行いました. 興味がある方はリンクからスライドをご覧になってください. 以下では, 残りの３つについて解説を行います.

## 命名

コードというものは読まれることを前提として書かなければいけません. 共著者はもちろん, 未来の自分もまた何度もコードを読みます. 特に論文の場合はどんな処理を行ったかを正確に記述するためにコードを読み直す作業が必ずあります. ここで名著『リーダブル・コード』から以下を引きましょう.

>**読みやすさの基本的定理** (Boswell and Foucher (2011))
>コードは他の人が最短時間で理解できるように書かなければいけない.


この本の内容に従うと, データテーブルの列名は情報量が多く （カラフルな） 曖昧性なく命名しなくてはなりません.

|         |🙆 Good              |🙅 Bad               |
|:--------|:--------------------|:--------------------|
|ブール   |is_female, has_kids  |female, no_kids      |
|カテゴリ |industry8, emp3      |industry, emp_status |
|ビン     |age_bin5, wage_bin10 |age, wage            |


**ブール変数**

ブール変数の場合は, `is_*`, `has_*`, `should_*` などの変数名で真偽の2値であることが示せます. また, `female`などの命名は慣例的に女性であることのダミー変数などとして用いられていますが, 曖昧性がないとは言えません. 次の型変換の節でも話しますが, "Yes"/"No"という文字列である可能性も含んでいます. そもそも文字列の"Yes"/"No"は, 分析上1ステップ増えてしまうので存在すべきではないですが, ブール変数ならそうと分かる命名にする必要があります.

また, `no_kids`というような否定で始まる命名もよくありません. 頭の中で真偽値を反転させる作業が必要になるので, 理解を少しだけ遅らせます. 変数名は否定が含まれないように命名し, 必要に応じて条件の中で`if (!has_kids)`のように反転すべきです.

**カテゴリ変数**

私は変数名のあとにカテゴリの数を付属させます. これによって,

- カテゴリ変数であること
- そのカテゴリの数

を同時に伝えることができます. また, 産業分類などでは大分類, 中分類, 小分類などがあるので, それらの定義もざっくり把握できます.

**連続値のビン**

年齢や所得などの連続値を等間隔で区切りたいときがあります (ビン). その場合はそのビンの間隔を付属して伝えます.

これら以外の命名の変数は基本的に連続値か, 中身が明らかなもの (gender, countryなど)
になります.

## 一括でリネーム

上記の変数名に変換するとして, 小さいデータセットの場合は
`dplyr::rename()`を使えば問題ありませんが, 変数が20を超えると少し面倒です.
また, 英語以外の変数名の場合, 変数名を英語に変換する必要を感じることが多いでしょう.

こういう場合私はCSVの対応表を用意します.
例えば, このマドリードの自転車事故のデータセットは変数名がスペイン語です.


```r
raw <- read_delim(here("data/raw/accident_bike/txt/year=2022/file.txt"),
        delim = ";", show_col_types = FALSE)
```

```
Rows: 42,547
Columns: 5
$ num_expediente <dbl> 2.022e+04, 2.022e+04, 2.022e+05, 2.022e+05, 2.022e+05, …
$ fecha          <chr> "01/01/2022", "01/01/2022", "01/01/2022", "01/01/2022",…
$ hora           <time> 01:30:00, 01:30:00, 00:30:00, 00:30:00, 00:30:00, 01:5…
$ localizacion   <chr> "AVDA. ALBUFERA, 19", "AVDA. ALBUFERA, 19", "PLAZA. CAN…
$ numero         <chr> "19", "19", "2", "2", "2", "53", "53", "728", "728", "+…
```

そこで, 以下のようなCSVファイルを用意します. 基本的に命名は上記で説明した規則に従っています.

```r
code <- read_csv(here("data/translate/accident_bike.csv"),
                     show_col_types = FALSE)
```

|spanish        |english       |
|:--------------|:-------------|
|num_expediente |id_1922       |
|fecha          |date          |
|hora           |hms           |
|localizacion   |street        |
|numero         |num_street    |
|cod_distrito   |code_district |



そして, 以下のように`dplyr::rename_at()` 関数で一括で変換します.

```r
renamed <- raw |>
  rename_at(vars(code$spanish), ~code$english)
```

```
Rows: 42,547
Columns: 5
$ id_1922    <dbl> 2.022e+04, 2.022e+04, 2.022e+05, 2.022e+05, 2.022e+05, 2.02…
$ date       <chr> "01/01/2022", "01/01/2022", "01/01/2022", "01/01/2022", "01…
$ hms        <time> 01:30:00, 01:30:00, 00:30:00, 00:30:00, 00:30:00, 01:50:00…
$ street     <chr> "AVDA. ALBUFERA, 19", "AVDA. ALBUFERA, 19", "PLAZA. CANOVAS…
$ num_street <chr> "19", "19", "2", "2", "2", "53", "53", "728", "728", "+0050…
```

## 型変換

データクリーニングのステップで正確な型を付けておくとデータ分析のステップがかなり楽になります. `readr::read_csv()`などでデータを読み込めば大体の型付けは完了しますが, 
以下の３つの問題は明示的に解決しなければなりません.

- 日付 & 時刻
- カテゴリ変数とその順番
- 欠損値

### 日付 & 時刻

`lubridate`は強力な日付パーサーを提供しています.

```r
lubridate::ymd("2021/08/31")
```
```
[1] "2021-08-31"
```

```r
lubridate::mdy("Sep. 10, 19")
```
```
[1] "2019-09-10"
```

```r
lubridate::dmy_hm("02/04/1999 16:00", tz="America/New_York")
```

```
[1] "1999-04-02 16:00:00 EST"
```

日付型に変換してしまえば, 時系列のプロットなどでかなり楽をすることができます. 必ず日付型に変換しましょう.

```r
renamed |>
  mutate(time = lubridate::dmy_hms(str_c(date, hms), tz = "Europe/Madrid")) |>
  select(date, hms, time) |>
  head()
```

```
# A tibble: 6 × 3
  date       hms    time               
  <chr>      <time> <dttm>             
1 01/01/2022 01:30  2022-01-01 01:30:00
2 01/01/2022 01:30  2022-01-01 01:30:00
3 01/01/2022 00:30  2022-01-01 00:30:00
4 01/01/2022 00:30  2022-01-01 00:30:00
5 01/01/2022 00:30  2022-01-01 00:30:00
6 01/01/2022 01:50  2022-01-01 01:50:00
```

### カテゴリ変数

カテゴリ変数の場合は`dplyr::recode_factor()`が便利です.


```r
renamed |>
  mutate(
    type_person = recode_factor(type_person,
        "Conductor" = "Driver",
        "Pasajero" = "Passenger",
        "Peatón" = "Pedestrian",
        "NULL"= NULL)) |>
  janitor::tabyl(type_person)
```

```
 type_person     n    percent
      Driver 34567 0.81244271
   Passenger  6503 0.15284274
  Pedestrian  1477 0.03471455
```


`recode_factor()` は以下の4つを同時に行えるという点で強みがあります.

1. Factor型として変数を定義する
1. Factor型の順番を決める (recodeの順番がfactorの順番になる)
1. 図表中のラベルとして適切な名前に変換 （翻訳も含む）
1. 特定の値を`NA`として変換

### 欠損値処理

一部のデータセットで欠損値は文字列 （ないし外れ値） として記録されています.

```r
unique(renamed$weather) # "Se desconoce" は「分からない」という意味です
```

```
[1] "Despejado"      "NULL"           "Se desconoce"   "Lluvia débil"  
[5] "Nublado"        "LLuvia intensa" "Granizando"     "Nevando"       
```

これらを解決する方法はいくつかあります.

**方法1: ロードする時に`NA`を定義する**

以下の例では, `NULL`や`Se descnoce`を欠損値として指定してデータを読み込んでいます.

```r
sol1 <- read_delim(here("data/raw/accident_bike/txt/year=2019/file.txt"),
                 delim = ";", show_col_types = FALSE,
                 na = c("", "NA", "NULL", "Se desconoce", "Desconocido")) |>
        rename(weather = "estado_meteorológico")

unique(sol1$weather)
```
```
[1] "Despejado"      NA               "Lluvia débil"   "Nublado"       
[5] "LLuvia intensa" "Granizando"     "Nevando"       
```

しかし, この方法は連続値の中の外れ値 (99, 9999) などでは,
他の変数中で実際の値として使われていた場合を考えると使うことができません.

**方法2: `na_if()`**

`na_if()`を使えば, 基本的にどのような場合でも対応できます.

```r
renamed |>
  mutate(
    weather_old = weather,# Presentation Purpose
    weather = na_if(weather, "Se desconoce"),
    weather = na_if(weather, "NULL"),
    ) |>
  select(weather_old, weather) |>
  head()
```

```
# A tibble: 6 × 2
  weather_old weather  
  <chr>       <chr>    
1 Despejado   Despejado
2 Despejado   Despejado
3 NULL        <NA>     
4 NULL        <NA>     
5 NULL        <NA>     
6 Despejado   Despejado
```

しかし, 複数の値を同時に欠損値に変換できないため, 少し不便です.

**方法3: `NULL`としてリコード**

前小節でも書きましたが, `recode_factor()` のついでに欠損値として処理してしまうのが効率がいいです.
カテゴリ変数にしか使えませんが, よく使う方法です.

```r
renamed |>
  mutate(
    weather_spanish = weather,# Presentation Purpose
    weather = recode_factor(weather,
        "Despejado" = "sunny",
        "Nublado" = "cloud",
        "Lluvia débil" = "soft rain",
        "Lluvia intensa" = "hard rain",
        "LLuvia intensa" = "hard rain",
        "Nevando" = "snow",
        "Granizando" = "hail",
        "Se desconoce" = NULL,
        "NULL" = NULL)) |>
  select(weather_spanish, weather) |>
  head()
```

```
# A tibble: 6 × 2
  weather_spanish weather
  <chr>           <fct>  
1 Despejado       sunny  
2 Despejado       sunny  
3 NULL            <NA>   
4 NULL            <NA>   
5 NULL            <NA>   
6 Despejado       sunny  
```


## 保存形式: Parquet

2023年1月現在, データフレームの最良な保存形式はparquet形式だと思います.

|           |速度 |サイズ |型保存 |多言語対応                       |
|:----------|:----|:------|:------|:--------------------------------|
|csv, tsv   |❌   |❌     |❌     |All                              |
|rds, RData |❌   |✔️      |✔️      |❌                               |
|parquet    |✔️    |✔️      |✔️      |Python, Julia, MATLAB, Stata,... |



詳細やベンチマークなどは 瓜生 ([2022](https://speakerdeck.com/s_uryu/introduction-to-r-arrow)) などを参考にされるとよいと思います.
`arrow::read_parquet()` は通常のデータフレームとしてだけでなく, 列情報のみを読み込むことが可能です.

**データフレームとして**

```r
df <- arrow::read_parquet(
  here("data/cleaned/accident_bike.parquet"),
  as_data_frame = TRUE)

df |> head()
```

```
# A tibble: 6 × 23
  id_1922     date  hms   street num_s…¹ code_…² distr…³ type_…⁴ weather type_…⁵
  <chr>       <chr> <chr> <chr>  <chr>     <int> <chr>   <chr>   <fct>   <chr>  
1 2018S017842 04/0… 9:10… CALL.… 1             1 Centro  Colisi… sunny   Motoci…
2 2018S017842 04/0… 9:10… CALL.… 1             1 Centro  Colisi… sunny   Turismo
3 2019S000001 01/0… 3:45… PASEO… 168          11 Caraba… Alcance <NA>    Furgon…
4 2019S000001 01/0… 3:45… PASEO… 168          11 Caraba… Alcance <NA>    Turismo
5 2019S000001 01/0… 3:45… PASEO… 168          11 Caraba… Alcance <NA>    Turismo
6 2019S000001 01/0… 3:45… PASEO… 168          11 Caraba… Alcance <NA>    Turismo
# … with 13 more variables: type_person <fct>, age_c <fct>, gender <fct>,
#   code_injury8 <chr>, injury8 <fct>, coord_x <chr>, coord_y <chr>,
#   positive_alcohol <lgl>, positive_drug <lgl>, year <int>, time <dttm>,
#   is_died <lgl>, is_hospitalized <lgl>, and abbreviated variable names
#   ¹​num_street, ²​code_district, ³​district, ⁴​type_accident, ⁵​type_vehicle
```

**列情報のみ**

```r
info <- arrow::read_parquet(
  here("data/cleaned/accident_bike.parquet"),
  as_data_frame = FALSE)

info[1:6]
```

```
Table
168574 rows x 6 columns
$id_1922 <string>
$date <string>
$hms <string>
$street <string>
$num_street <string>
$code_district <int32>
```

`dplyr::collect()` を使うとデータフレームとしてメモリに読み込まれます.

```r
info |>
  collect()
```
```
# A tibble: 168,574 × 23
   id_1922    date  hms   street num_s…¹ code_…² distr…³ type_…⁴ weather type_…⁵
   <chr>      <chr> <chr> <chr>  <chr>     <int> <chr>   <chr>   <fct>   <chr>  
 1 2018S0178… 04/0… 9:10… CALL.… 1             1 Centro  Colisi… sunny   Motoci…
 2 2018S0178… 04/0… 9:10… CALL.… 1             1 Centro  Colisi… sunny   Turismo
 3 2019S0000… 01/0… 3:45… PASEO… 168          11 Caraba… Alcance <NA>    Furgon…
 4 2019S0000… 01/0… 3:45… PASEO… 168          11 Caraba… Alcance <NA>    Turismo
 5 2019S0000… 01/0… 3:45… PASEO… 168          11 Caraba… Alcance <NA>    Turismo
 6 2019S0000… 01/0… 3:45… PASEO… 168          11 Caraba… Alcance <NA>    Turismo
 7 2019S0000… 01/0… 3:45… PASEO… 168          11 Caraba… Alcance <NA>    Turismo
 8 2019S0000… 01/0… 3:45… PASEO… 168          11 Caraba… Alcance <NA>    Turismo
 9 2019S0000… 01/0… 3:50… CALL.… 65           10 Latina  Choque… sunny   Furgon…
10 2019S0000… 01/0… 3:50… CALL.… 65           10 Latina  Choque… sunny   Turismo
# … with 168,564 more rows, 13 more variables: type_person <fct>, age_c <fct>,
#   gender <fct>, code_injury8 <chr>, injury8 <fct>, coord_x <chr>,
#   coord_y <chr>, positive_alcohol <lgl>, positive_drug <lgl>, year <int>,
#   time <dttm>, is_died <lgl>, is_hospitalized <lgl>, and abbreviated variable
#   names ¹​num_street, ²​code_district, ³​district, ⁴​type_accident, ⁵​type_vehicle
```

この方法が便利なのは`select()`, `filter()`, `group_by()`, `summarize()`
などの関数が使える点です.
これによって, 大きなデータセット全体をメモリに読み込むことなく,
必要なデータのみ読み込むというデータベースのようなことが簡易的に行なえます.

### パーティショニング

仮にデータセットが年ごとにフォルダで分かれた構造を持っていたとしています.

```{.shell}
data/raw/accident_bike/parquet/
├── year=2019
│   └── part-0.parquet
├── year=2020
│   └── part-0.parquet
├── year=2021
│   └── part-0.parquet
└── year=2022
    └── part-0.parquet
```

このようなデータを`arrow::open_dataset()`関数は1つのparquetデータのように扱うことができます.

```r
info <- open_dataset(
          here("data/raw/accident_bike/parquet"))
info
```

```
FileSystemDataset with 4 Parquet files
num_expediente: string
fecha: string
hora: string
localizacion: string
numero: string
cod_distrito: int32
distrito: string
tipo_accidente: string
estado_meteorológico: string
tipo_vehiculo: string
tipo_persona: string
rango_edad: string
sexo: string
cod_lesividad: string
lesividad: string
coordenada_x_utm: string
coordenada_y_utm: string
positiva_alcohol: string
positiva_droga: string
year: int32
```

この場合, フォルダを分けていた年次が`year`として新しい変数に加わります.
実はCSVファイルや他のフォルダ名でも可能なのですが, 詳細は上の瓜生さんのスライドか
Mock ([2022](https://jthomasmock.github.io/arrow-dplyr)) などを参考にされるとよいと思います.

## 前処理まとめ

Tidyなデータを作った後,

**1. 命名**

- （変数の型の） 情報量が多く, 誤解のない命名を行う. 必要に応じて翻訳もする
- 変数が多い場合は別ファイルで対応表をつくるとよい

**2. 型変換**

- _日付_: `lubridate()`
- _カテゴリ変数_: `recode_factor()`
- _欠損値_: 読み込み時の`na`オプション, `na_if()`, そして`recode_factor()`

**3. 保存**

- Parquet形式が2023年1月現在の最適解
- Parquet形式は大きなデータセットを扱う際に更に便利になる

続きはこちら[グラフ編](https://zenn.dev/nicetak/articles/r-tips-graph-2022), [テーブル編](https://zenn.dev/nicetak/articles/r-tips-table-2022)
