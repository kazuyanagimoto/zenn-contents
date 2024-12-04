---
title: "Quartoで始めるTypst生活"
emoji: "📄"
type: "tech" 
topics: ["quarto", "typst"]
published: true
---

:::message

:::

## Typstはじめました

2024年, 私の研究生活にとって最も大きな変化は$\LaTeX$に変わり[Typst](https://typst.app)を主要な文書作成ツールとするようにしたことです. $\LaTeX$と比べて圧倒的に速いコンパイルと直感的なシンタックスは, 研究の一助となりました. しかし, Typstを研究に導入する上で二つのハードルがあると思っています.

1. Typstは新しいツールであるため, 導入にはリスクがある. 論文のテンプレートが用意されていなかったり, 数年後にTypstのプロジェクトが終了してしまう可能性もないわけではない.
1. Typstの記法が$\LaTeX$やMarkdownと互換性がない. 特に数式の記法が異なり, 覚えることが多い.

2つ目の点は新しい言語であるからには仕方がない部分もあると思っていますが, 1つ目の点は今後のリスクを考えると大きな問題です.

### Quarto + Typstはじめました

そんな問題を解決するのが, [Quarto](https://quarto.org)です. QuartoはRmarkdownやJupyterを統合させたようなノートブック型の文章作成ツールですが, version 1.4からTypstをサポートするようになりました. つまり, Markwon記法で書かれた文章をTypst経由でPDFに変換することができるようになったのです. これにより, Typstの記法を覚えることなく, (Quarto方言の)Markdownの記法で文章を書くことができるようになりました.^[正確に言えば, QuartoはRやPythonのコードを`knitr`や`jupyter`を用いて実行した上でmarkdownに変換し, markdownを[pandoc](https://pandoc.org)がTypstに変換しています. つまり, Quartoによるコード実行に興味がない場合は本質的にはpandocのみの導入で十分です.]

さらに, QuartoはTypst以外にも, $\LaTeX$やWord, HTMLなどのフォーマットに変換することもできます. つまり, Typstの高速コンパイルやデザインのカスタマイズ性などの利点を享受しつつ, (もしもの時は) 他のフォーマットにも簡単に変換することができるのです.

### Quarto + Typstで完結する研究生活

この記事では, Quarto + Typstを用いた基本的な文章作成方法を紹介します. 私は実際にQuarto + Typstによって, CV, プレゼン, ワーキングペーパーという研究生活に必要なほとんどの (PDF) 文章を作成しています. またそれぞれのQuarto + Typstのテンプレートも作成しました. これらはGitHub上で公開されているため, どなたでも利用することができます. この記事で個別のテンプレートの使い方は紹介しませんが, ご興味があればレポジトリ上から参照できるドキュメントを参照してください.

https://github.com/kazuyanagimoto/quarto-academic-typst
https://github.com/kazuyanagimoto/quarto-clean-typst
https://github.com/kazuyanagimoto/quarto-awesomecv-typst

なお, 別の記事での日本語解説もご覧になることができます.

https://zenn.dev/nicetak/articles/quarto-typst-slides
https://zenn.dev/nicetak/articles/quarto-typst-cv

## Tips for Quarto + Typst

Quartoに関する詳細な情報は[公式サイト](https://quarto.org)を参照してください. 過去のバージョンに関する破壊的な変更はあまり行われない印象ですが, バグ修正のための頻繁なアップデートや, 新機能の追加が行われているため, 最新の情報を確認することをお勧めします. Quarto + Typstの基本的な使い方も[Typst Basics](https://quarto.org/docs/output-formats/typst.html)にまとめられています. Quartoに関する日本語の解説によるものでは宋財泫さんと矢内勇生さんによる[私たちのR](https://www.jaysong.net/RBook/quarto1.html)に詳しい解説があります.

この記事では公式ドキュメントにあまり記載のない, Quarto + Typstによる文章作成のTipsやつまづきやすいポイントを紹介します.

### 1. Quartoのインストール

[公式サイト](https://quarto.org/docs/download/)からインストーラーをダウンロードしてインストールしてください. TypstはQuartoにバンドルされているため, Typstのインストールは不要です. なお, このバンドルされているTypstは最新版であるとは限らないことに注意してください. TypstのCLI機能は `quarto typst`コマンドで実行できますし, `quarto typst --version`でバージョンを確認することもできます.

```bash
quarto typst --version
#> typst 0.11.0 (2bf9f95d)
```



### 2. Quarto + Typstによる文章作成


### 3. Typstの表作成

論文において表の作成は日常の茶飯事です. $\LaTeX$においては, 歴史的な経緯から様々なツールが存在しますが, Typstにおいては2024年12月現在唯一の表作成ツールが[`modelsummary`](https://modelsummary.com) + [`tinytable`](https://vincentarelbundock.github.io/tinytable/)です.　`tinytable`はデータフレームから様々な形式の表 (Typst, $\LaTeX$, $Word$など)を作成するRのパッケージであり, `modelsummary`のデフォルトのバックエンドです. `modelsummary`は様々な統計モデルの結果を表形式で出力するRのパッケージであり, Rで実行できる主要なモデルのほとんどをサポートしています. これらのパッケージを用いることで, Typstの表を簡単に作成することができます. なお, Quartoにも対応しているため, Quartoの出力形式がTypstであればこれらのパッケージは自動的にTypstの表を出力します.

一つ問題があるのが, これらのパッケージはTypstの数式入力を変換しないということです. Quartoは`$$`で囲まれた数式を出力形式に合わせて自動で変換するため, Typstの場合でも$\LaTeX$記法の数式をそのまま記述することができます.　しかし, `tinytable`にはそのような機能がないため, 数式を入力する場合はTypst記法で入力する必要があります. これは, Typstのみを出力形式とする場合には問題ありませんが, 他の出力形式にも対応する場合には注意が必要です.

一つの解決策として, Typstのパッケージである[MiTeX](https://typst.app/universe/package/mitex/)を用いるという方法があります. MiTeXは$\LaTeX$記法をTypst記法に変換するTypstパッケージであり, Typstのコード内では`mitex()`関数を噛ませることで$\LaTeX$記法の数式をTypst記法に変換することができます. これを`tinytable`の出力に適用することで, Typstと他の形式 ($\LaTeX$, HTML, Word) に対応した表を作成することができます.

```r
theme_mitex <- function(x, ...) {
    fn <- function(table) {
        if (isTRUE(table@output == "typst")) {
          table@table_string <- gsub("\\$(.*?)\\$", "#mitex(`\\1`)",
                                    　table@table_string)
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




## 応用編: Quarto + Typst のテンプレートを作る

## おわりに

以上で, Quarto + Typstを用いた文書作成の基本を紹介しました. 私にとってはQuarto + Typstは現在のベストプラクティスで, しばらくは私にとって最も重要なツールとなるでしょう. この記事がQuarto + Typstの普及に少しでも役立てば幸いです. また, この記事によって, Quarto + Typstのテンプレートが増えることをささやかな願いとしておきます.
Happy Quarto + Typst Life! 🥂