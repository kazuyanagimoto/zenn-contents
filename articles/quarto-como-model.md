---
title: "Quartoで科学コミュニケーション: 経済学モデル編"
emoji: "💠"
type: "tech" 
topics: ["quarto", "julia", "observable"]
published: true
---

:::message
これはQuartoで書かれた私の[英語ブログ](https://kazuyanagimoto.com/blog/2023/06/10/quarto_com_model/)の日本語訳版です. 実際にqmdファイルががコンパイルされたドキュメントを見たい方は元記事をご覧ください. コードは[こちら](https://github.com/kazuyanagimoto/kazuyanagimoto.github.io/blob/main/blog/2023/06/10/quarto_com_model/index.qmd)です.
:::

# はじめに

## Quartoはもっとできる.

ノートブック形式のプログラミング (Jupyter, Rmarkdown, Quarto) はここ10年でかなりポピュラーになりました. グラフとコードを載せることで, どのようなデータでどのような分析をしたか, 結論はどう解釈できるかなどを直感的に伝えることができます. 実際に, 私はプロジェクトの試行錯誤の段階で, 指導教官や共著者にQuartoで作成したレポートを共有することが多いです.

このようにプログラミングノートブック形式のレポートはすでに便利なツールですが, HTMLであるということを用いれば, もっとコミュニケーションをリッチにできます. ここではその例として, GIFとObservable JSを用いた経済学モデルの可視化を紹介します. Juliaを用いていますが, PythonやRでも同じようなことができます.

まず, 以下のようなシンプルなライフサイクルモデルがあったとします.
For $t = 1, \dots, T$, households solve

$$
V(t, e, x) = \max_{c, x'} \frac{c^{1 - \sigma}}{1 - \sigma} + \beta \mathbb{E}V(t + 1, e', x')
$$

$$
\begin{aligned}
c + x' &\le (1 + r)x + ew \\
\text{Pr}(e' | e) &= \Gamma(e) \\
c, x' &\ge 0
\end{aligned}
$$

パラメータや解法アルゴリズムは以下のコードを参照してください.

https://github.com/kazuyanagimoto/kazuyanagimoto.github.io/blob/main/blog/2023/06/10/quarto_com_model/index.qmd#L48-L113

伝統的な可視化の方法は, いくつかの$e$や$t$を選んでプロットをすることです.

```julia
ps = []

y̲, ȳ = minimum(V) * 1.1, maximum(V) + 0.1
for (i, t) ∈ enumerate([1, 4, 7, 10])
	
	p = plot(m.x_grid, V[:, 1, t], 
		xlabel = "x",
		ylims = (y̲, ȳ),
		label = L"e_1", 
		legend = :bottomright, 
		title = "t = $t")
	plot!(m.x_grid, V[:, 5, t], label = L"e_5")
	plot!(m.x_grid, V[:, 10, t], label = L"e_{10}")
	push!(ps, p)
end

plot(ps...)
```

![](/images/quarto-com-model/plot_traditional.png)

これでもほとんど困りませんが, GIFを使えば時間軸の変化を表現できます.

# GIF

あまり有名ではありませんが, Juliaでは`@animate`マクロを使うことでGIFアニメーションをかなり簡単に作成できます.

```julia
anim = @animate for t = 1:10
	plot(m.x_grid, V[:, 1, t], 
		xlabel = "x",
		ylims = (y̲, ȳ),
		label = L"e_1", 
		legend = :bottomright, 
		title = "t = $t")
	plot!(m.x_grid, V[:, 5, t], label = L"e_5")
	plot!(m.x_grid, V[:, 10, t], label = L"e_{10}")
end

gif(anim, "img/anim.gif", fps = 1)
```

![](/images/quarto-com-model/anim.gif)

特に説明の必要がないぐらい直感的に理解できます. もうすこし多くのパラメーターを扱いたい場合はObservable JSを使ってみてもいいでしょう.

# Observable JS

[Observable](https://observablehq.com/)はJavaScriptのノートブックで, インタラクティブな可視化を作成できます. 重要なことは, ObservableがJavaScriptベースであり, 静的なHTMLドキュメントにインタラクティブなプロットを含めることができるということです.
 
例えば, この価値観数が$r$や$w$の変化でどのように変わるかを見たいとします. Observableで可視化をする前に, まずはシミュレーションの結果をCSVファイルに保存します.^[データソースとしてCSV, TSV, JSON, Arrow (uncompressed), SQLiteを使うことができます. 詳しくは[Data Sources](https://quarto.org/docs/computations/ojs.html#data-sources)を参照してください.]

```julia:julia
function solve_partial(r, w)
	m = Model(r = r, w = w)
	V = solve(m)
	return [
		(x = x, ie = iₑ, t = t, V = V[iₓ, iₑ, t], r = m.r, w = m.w)
		for (iₓ, x) ∈ enumerate(m.x_grid)
		for (iₑ, e) ∈ enumerate(m.e_grid) if iₑ ∈ [1, 5, 10]
		for t ∈ 1:m.T
	]
end

res = Iterators.flatten(
    [solve_partial(r, w) for r ∈ 0.01:0.02:0.15 for w ∈ 2.0:0.5:10.0])
df = DataFrame(res)
d = Dict(1 => "e₁", 5 => "e₅", 10 => "e₁₀")
df.lbl = [d[i] for i in df.ie]
CSV.write("data.csv", df);
```

このCSVファイルは以下のようにObservableに読み込まれ, パラメーターごとにフィルタリングされます.^[`r`, `w`, `t` のパラメータは次のセルで定義されていますが, Observable JSのセルの順番は結果に影響を与えません.]

```js:ojs
data = FileAttachment("data.csv").csv()
filtered = data.filter(function(sim) {
	return sim.r == r && sim.w == w && sim.t == t
})
```

スライダーとプロットを追加して, インタラクティブな可視化ができます.


```js:ojs
//| panel: input
viewof t = Inputs.range(
  [1, 10], 
  {value: 1, step: 1, label: "t"}
)
viewof r = Inputs.range(
  [0.01, 0.15], 
  {value: 0.07, step: 0.02, label: "r"}
)
viewof w = Inputs.range(
  [2.0, 10.0], 
  {value: 5.0, step: 0.5, label: "w"}
)
```


```js:ojs
Plot.plot({
	marginLeft: 50,
	height: 400,
	color: {domain: ["e₁", "e₅", "e₁₀"], legend: true},
	x: {domain: [0.0, 4.0]},
	y: {domain: [-5.5, 0.0]},
	marks: [
		Plot.lineY(filtered, {x: "x", y: "V", stroke: "lbl"}),
	]
})
```

![](/images/quarto-com-model/ojs.gif)

実際にパラメーターを動かしたい場合は[こちら](https://kazuyanagimoto.com/blog/2023/06/10/quarto_com_model/)で試してください.
Happy Quarto life 🥂!