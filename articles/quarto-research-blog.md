---
title: "Quartoでブログを書くように研究する"
emoji: "🗂"
type: "tech"
topics: ["r", "quarto"]
published: true
---

# Jupyter NotebookやR Markdownをブログにしよう

Jupyter NotebookやR Markdownは研究の試行錯誤の段階で, 共著者や指導教官とのコミュニケーションのために非常に便利なツールです. しかしこれらのファイルが溜まってくると中身を忘れてしまい, いちいち開かなければなりません.

そこで, これらの分析結果をブログのように管理することを考えました. 日々のレポートを時系列などでならべるのであればブログ形式として管理するのが自然です. 既存のブログの機能を用いれば, タイトルやサムネイルから内容を探しやすくなり, タグ付けや検索機能などでより効率的に管理ができるようになります.

この記事ではQuartoを用いて, ブログのように研究を管理する方法を紹介します. 私自身, 指導教官や共著者とのミーティングの際にこのブログを見せながら, その週の進捗について議論しています. また, 以下に見本のブログを示していますので, イメージを掴んでいただければと思います. また, ソースコードは[GitHub レポジトリ](https://github.com/kazuyanagimoto/quarto-research-blog)で確認いただけます.

https://kazuyanagimoto.com/quarto-research-blog/

## ３つの共有方法

研究の途中経過をどの程度公開するかはプロジェクトや分野によって異なります.　アクセスの容易さとセキュリティのバランスを考えて, 大きく以下の３つの方法が考えられると思います.

1. ローカルでコンパイルしたブログ (HTMLファイル群) をGitHubなどで共有する
    - **メリット**: セキュリティが高い. 無料
    - **デメリット**: 共有相手が`git pull` してHTMLファイルをローカルで開く必要がある
1. GitHub Pagesでホストする
    - **メリット**: 共有相手がブラウザで閲覧できる. 無料
    - **デメリット**: 基本的に全世界に公開されてしまう. GitHub Entrepriseを用いればプライベートにできるがやや高額
1. AWS S3 + CloudFrontでBasic認証をつける
    - **メリット**: 共有相手がブラウザで閲覧できる
    - **デメリット**: AWSの設定が必要. 月に数十円程度のコストがかかる

今回の記事では最も汎用性の高い3つめの方法を紹介します. 実際, 私の研究プロジェクトでは, それなりのプライベート性が保たれつつ共有相手の負担も少ない3つ目の方法を用いています. なお, 上記のデモサイトは２つ目の方法で公開しています. [こちら](https://quarto-research-blog.kazuyanagimoto.com)から3つめの方法でデプロイしたプライベートなサイトを見ることができます (username: `abcd`, password: `1234`). 

# Quartoでブログを書く

QuartoはR Markdownを拡張させたようなツールで, knitrがバックグラウンドで動くため, R Markdownの機能はそのまま使うことができます. また, jupyterをバックグラウンドエンジンにすることで, PythonやJuliaといった言語も扱うことができます.^[正確にはknitrは多言語をもともと扱えるので, knitrをバックグラウンドエンジンにすると, 複数言語を同じノートブックに共有させることができます. 私の過去の[ブログ](https://kazuyanagimoto.com/blog/2023/04/30/quarto_multi_lang/)などでその例を見ることができます.]

今回の記事ではマークダウン記法などは[公式ドキュメント](https://quarto.org/docs/)を参照していただくとして, Quartoの特徴的な機能とwebsiteとしての設定方法を解説します.

## R Markdownとの違い

QuartoはR Markdownと同様に書けますが, ほぼ唯一の違いはチャンクオプションにあります. 

````r:R Markdown
```{r, include = FALSE}
mdl <- lm(mpg ~ wt, data = mtcars)
```
````

````r:Quarto
```{r}
#| include: false
mdl <- lm(mpg ~ wt, data = mtcars)
```
````

これはコード実行の観点からはただのコメントとなるため, PythonやJuliaなどの他の言語とも共存する良い記法であると思います.

その他の機能としては, [Tabset Panel](https://quarto.org/docs/interactive/layout.html#tabset-panel) や[Callout Blocks](https://quarto.org/docs/authoring/callouts.html) などによって, より見やすくかけるようになりました. また, [引用](https://quarto.org/docs/authoring/footnotes-and-citations.html)の記法もよりわかりやすくなっています.

## Website の設定

### `_quarto.yml`の設定

プロジェクト単位の設定ファイルです. 詳細は[公式ドキュメント](https://quarto.org/docs/reference/projects/options.html)を参照してください. 私の設定ファイルは以下のようになっています.

https://github.com/kazuyanagimoto/quarto-research-blog/blob/main/_quarto.yml

- `output-dir: docs`: GitHub Pagesでホストする場合は`docs`ディレクトリにHTMLファイルを出力する必要があります. 後述のGitHub Actionsでデプロイする場合は必ずしも`docs`である必要はありません
- `favicon`: ファビコンのファイルです. 私は[Icooon Mono](https://icooon-mono.com)さんのものをよく利用します.
- `theme`: テーマは[Bootswatch](https://bootswatch.com)の中から選ぶことができます.
- `custom.scss`: CSSを設定することができます. Quartoでは事前に[Sass Variables](https://quarto.org/docs/output-formats/html-themes.html#sass-variables)が用意されているので, それを使うことで簡単にカスタマイズすることができます. 共著者以外は見ないので, あまり凝りすぎないようにしています

:::details プロジェクトのコードネーム

研究とはよく開始時点でのリサーチクエスチョンと異なる方向に進むことがよくあります. そのためはじめに設定したレポジトリの名前と研究の実態が異なることがよくあります. そこで私はDr. Andrew Heissさんの[アイディア](https://github.com/andrewheiss/testy-turtle)を参考に, プロジェクトには研究と全く関わりないコードネームをつけています.

例えば私の日本のジェンダーギャップについて研究したプロジェクトは[common cheetah](https://kazuyanagimoto.com/research/common-cheetah/)というコードネームがついています. これは`codename`というRパッケージを用いて生成しています.

```r
library(codename)
codename_message()
#> code name generated by {codename} v.0.5.0. R version 4.2.2 (2022-10-31).

codename(seed = 210715, type = "ubuntu") # The day I started the project
#> [1] "common cheetah"
```

ちなみにこの[Ubuntu-styling](https://wiki.ubuntu.com/DevelopmentCodeNames)だと, 必ず動物名が割り当てられるので, ファビコンを決めるのが楽です. 共著者が面白がってくれるかは分かりませんが...

:::

### `_metadata.yml`の設定

ディレクトリ単位の設定ファイルです. 詳細は[公式ドキュメント](https://quarto.org/docs/reference/formats/html.html)を参照にしてください.

https://github.com/kazuyanagimoto/quarto-research-blog/blob/main/posts/_metadata.yml

- `freeze: auto`: コードのセルの実行結果を保存してくれます. `auto`の場合, コードの変更があった場合は自動で更新してくれます. これによってブログのコンパイルの時間を短縮でき, また, GitHub Actionsなどでコードを実行することなくHTMLを生成することができるようになります
- `echo`, `warning`, `message` はブログとして結果を読む際は不要なので非表示にしています
- `code-tools: true`: これによって, ページの右上からコードを確認することができます. これは共著者が分析内容を軽く確認するために便利です

### サムネイルの設定

サムネイルは, 手元の画像ファイルを用いる場合はYAMLヘッダーの`image`タグで指定します.

```yaml
---
title: A Blog Post
image: path/to/image.jpg
---
```

分析中のグラフをサムネイルにする場合は, グラフを表示するコードのチャンクオプションとして`classes: preview-image`を設定すればよいです.

````r
```{r}
#| classes: preview-image
plot(cars)
```
````

### `.gitignore`の設定

以上のような設定を行えば, ローカルでHTMLファイルをコンパイルすることができるようになります. また, このままGitHubにプッシュしてしまえば, `docs/`をルートディレクトリにして, GitHub Pagesで公開することもできます. しかし, 自動生成されるHTMLファイルやライブラリをGit管理するというのはあまりスマートな方法ではありません. コンフリクトが起きた際の解決が面倒ですし, レポジトリのサイズも大きくなってしまいます. そこで, `docs/`ディレクトリはgitignoreしてしまい, 後述するようにHTMLファイルはGitHub Actionsで自動生成するようにします.

```shell:.gitignore
/.quarto/
/_site/
/docs/
```

:::details GitHub Pagesで公開する場合

GitHub Pagesとして公開して良い場合は, 以下のコマンドを実行することで`gh-pages`ブランチにHTMLファイルを自動生成し, GitHub Pagesとして公開することができます.

```shell
quarto publish gh-pages --no-browser
```

記事を書く事にこのコマンドを実行してもよいのですが, 以下のようなGitHub Actionsで自動化できます.

```yaml:.github/workflows/publish.yml
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

      - name: Render and Publish
        uses: quarto-dev/quarto-actions/publish@v2
        with:
          target: gh-pages
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

:::

# AWS S3 + CloudFrontでBasic認証をつけて公開する

AWS S3とCloudFrontを用いることで, 比較的低コスト(月あたり約数十円)で, パスワード認証 (Basic認証) 付きのウェブサイトを公開することができます. AWSの仕様変更や料金体系の変更があるかもしれませんので, 以下の手順は自己責任でお願いします.

## S3バケットを作成し, GitHub Actionsで自動デプロイする

### Step 1: S3バケットを作成する

AWSコンソールのS3からバケットを作成します. バケット名はGitHubレポジトリと同じものにするのが分かりやすいと思います. 設定はすべてデフォルトのままでよいと思います. CloudFront経由でアクセスするので, バケットのパブリックアクセスはすべてブロックしておきます.

### Step 2: IAMユーザーを作成し, アクセスキーを取得する

AWSコンソールのIAMからユーザーを作成し, ポリシーにはS3のフルアクセス権限 (AmazonS3FullAccess) を与えます. その後, アクセスキーを取得しておきます.

### Step 3: GitHub Secretsにアクセスキーを登録する

GitHubのレポジトリのSettingsからSecurity → Secrets and variables → Actionsを開き, 新しいrepository secretsとして`AWS_ACCESS_KEY_ID` と `AWS_SECRET_ACCESS_KEY` を登録します.

![](/images/quarto-research-blog/github_secrets.png)

### Step 4: GitHub Actionsでデプロイする

以下のようなGitHub Actionsを設定することで, `main`ブランチにpushされた際にHTMLファイルをS3バケットに自動デプロイすることができます.

```yaml:.github/workflows/publish.yml
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

      - name: Render Quarto Project
        uses: quarto-dev/quarto-actions/render@v2
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2

      - name: S3 sync
        working-directory: docs
        run: aws s3 sync . s3://quarto-research-blog --delete
```

## CloudFrontでBasic認証を設定する

CloudFront経由でS3バケットにアクセスさせることで, Basic認証によるパスワードを設定することができます.

### Step 1: CloudFrontの関数を作成する

AWSコンソールのCloudFrontから, Functions → Create function で以下の関数を作成します.

```javascript
function handler(event) {
  var request = event.request;
  var headers = request.headers;
  var uri = request.uri;

  // echo -n user:pass | base64
  var authString = "Basic XXXXXXXXXXXXXXXXXXX";

  if (
    typeof headers.authorization === "undefined" ||
    headers.authorization.value !== authString
  ) {
    return {
      statusCode: 401,
      statusDescription: "Unauthorized",
      headers: { "www-authenticate": { value: "Basic" } }
    };
  }
  
  // Check whether the URI is missing a file name.
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    }
    // Check whether the URI is missing a file extension.
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }
  
  return request;
}
```

`authString`にはユーザー名とパスワードをbase64エンコードしたものを設定します. 例えば, デモサイトのようにユーザー名`abcd`, パスワード`1234`の場合は, `echo -n abcd:1234 | base64` でエンコードできます. AWSコンソールの左下にCloudShellがあるので, そこでエンコードするのがいいでしょう.

コードの後半では, urlが`/`で終わっている場合や, 拡張子がない場合に`index.html`を追加するようにしています.　CloudFront経由でS3バケットにアクセスする際は, サブディレクトリの`index.html`がデフォルトで表示されるわけではないようです.

:::message
作成した関数を発行することを忘れないでください.
:::

:::details IPアドレスによる制限

よりセキュリティを高めたいという場合は, IPアドレスによるアクセス制限をかけることもできます. 大学や会社の場合, 固定IPアドレスを持っている場合が多いと思うので, 比較的簡単に設定できるでしょう. 以下の`IP_WHITE_LIST`に許可するIPアドレスを記入してください.

```javascript
function handler(event) {
  var request = event.request;
  var clientIP = event.viewer.ip;
  var headers = request.headers;
  var uri = request.uri;
  
  //-------------------
  // Check IP
  //-------------------
  var IP_WHITE_LIST = [
   'xxx.xxx.xxx.xxx',
  ];
    
  var isPermittedIp = IP_WHITE_LIST.includes(clientIP);
  
  if (!isPermittedIp) {
    var response = {
        statusCode: 403,
        statusDescription: 'Forbidden',
    }
    return response;
  }
  
  //---------------------------
  // Basic Authentication
  //---------------------------
  
  // echo -n user:pass | base64
  var authString = "Basic XXXXXXXXXXXXXXXXXXX";

  if (
    typeof headers.authorization === "undefined" ||
    headers.authorization.value !== authString
  ) {
    return {
      statusCode: 401,
      statusDescription: "Unauthorized",
      headers: { "www-authenticate": { value: "Basic" } }
    };
  }
  
  //--------------------------------------
  // Correct Subdirectory index.html
  //-------------------------------------
  
  // Check whether the URI is missing a file name.
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    }
    // Check whether the URI is missing a file extension.
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }
  
  return request;
}
```

:::


### Step 2: CloudFrontのディストリビューションを作成する

AWSコンソールのCloudFrontから, ディストリビューションを作成します.

- Origin Domain Name: 先ほど作成したS3バケットを選択します
- Origin Access
    - Origin access control settingsを選ぶ
    - Create new OACで新しいOACを作成します
- Viewr: Redirect HTTP to HTTPSを選択します
- 関数の関連付け: CloudFront Functionsを選び, 先ほど作成した関数を選択します
- Web Application Firewall (WAF): 有効にする場合は料金がかかります. 今回は不要と考えます
- サポートされているHTTPバージョン: HTTP/2とHTTP/3を選択しました
- Default Root Object: `index.html`を選択します

### Step 3: S3 バケットポリシーの変更

以上を完了するとS3バケットポリシーの更新が求められます.

1. ポリシーをコピーというボタンを押し, Policy statmentをコピーします
1. S3のバケットを選択し, アクセス許可のタブからバケットポリシーを編集して, 先ほどコピーしたポリシーを貼り付けます

### Step 4: テスト

CloudFrontのディストリビューションからディストリビューションドメイン名をコピーし, ブラウザでアクセスしてみてください. パスワードを求められ, 事前に設定したユーザー名とパスワードを入力することで, ブログが表示されるはずです.

## おまけ: サブドメインを設定しURLを整える

CloudFrontのデフォルトの設定ではランダムな文字列がURLになってしまいます. もしあなたが独自のドメインを持っている場合は, サブドメインを作成することで無料で独自のURLを持つことができます. 私は[kazuyanagimoto.com](https://kazuyanagimoto.com) というドメインをGoogle Domainsで取得したため, 100個までのサブドメインを無料で作成することができます.

### Step 1: サブドメインを作成する

お使いのドメインのDNS設定から, サブドメインを作成します. 今回のデモサイトの場合, `quarto-research-blog.kazuyanagimoto.com`というサブドメインのCNAMEレコードを作成し, CloudFrontのディストリビューションドメイン名 (`https://`は不要です) を設定します.

### Step 2: カスタムSSL証明書を作成する

AWS Certificate Managerから, カスタムSSL証明書を作成します. パブリック証明書のリクエストを選択します. ドメイン名は, 自分の所有するドメインとサブドメインを追加します. サブドメインは`*.kazuyanagimoto.com`のようにワイルドカードを使うことをおすすめします.

:::message alert
AWS Certificate Managerのリージョンはus-east-1でないとCloudFrontで使えません. 必ず確認しましょう.
:::

DNSの検証を選択すると, Route53 (AWSのDNSサービス)以外を用いている場合は, DNSレコードを追加する必要があります. `_`から始まるCNAMEレコードが表示されるので, ご自身のドメインのDNS設定に追加してください. 登録を完了して暫く待つと, 証明書の状態が発行済になると思います.

### Step 3: CloudFrontのディストリビューションの代替ドメインを設定する

CloudFrontに戻りディストリビューションに代替ドメイン名を設定します. 代替ドメイン名として, 先ほど作成したサブドメインを入力し, カスタムSSL証明書は先ほど作成したものを選択します.

### Step 4: テスト

サブドメインにアクセスしてみてください. パスワードを求められ, 事前に設定したユーザー名とパスワードを入力することで, ブログが表示されるはずです.

![](/images/quarto-research-blog/basic_auth.png)

https://quarto-research-blog.kazuyanagimoto.com

# まとめ

以上でQuartoを用いてブログのように研究を管理する方法を紹介しました. この方法を用いることで, 自分の過去の分析を振り返ることができるだけでなく, 共著者や指導教官とのコミュニケーションもスムーズにすることができます. 皆様の研究がより捗ることを願っております.

Have a happy Quarto life 🥂!