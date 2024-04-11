---
title: "VSCode + Dockerでよりミニマルでポータブルな研究環境を"
emoji: "🐳"
type: "tech" 
topics: ["vscode", "docker", "r", "dvc", "latex"]
published: true
---

# はじめに

### もっとミニマルで簡単なポータブルな環境を!

自分自身の研究のための環境構築についてこれまで二本の記事を書いてきました.

@[card](https://zenn.dev/nicetak/articles/zotero-tex-bibtex)
@[card](https://zenn.dev/nicetak/articles/vscode-docker-rstudio)

これらの記事から二年ほどたち, いくつかの点において不満点が出てきました. 特に, GCPや自宅のサーバー上でリモートで作業することが多くなってきたので, よりミニマルでポータブルな環境が必要になりました.

以下では, 現時点で最小限の努力で環境を再現ができることを目標にしたDockerベースのGitHubレポジトリのテンプレートとその使い方を紹介します. このテンプレートを用いて作られた環境は, 新たなコンピュータ上で最短4ステップで環境を再現できるようになります.

1. `git clone`
1. VSCodeの"Open in Remote Containers"
1. `renv::restore()`
1. `dvc pull`

この環境とセットアップはこのレポジトリにテンプレートとしておいて置きます. 実際, 私自身も新しいプロジェクトを始める際にはこのテンプレートを用いて環境を作っています.

https://github.com/nicetak/dockerR/

### 概要

私自身が研究の際に使う言語はR, Julia, $\LaTeX$, と時々Pythonです. また, バージョン管理にはGitを, データ管理にはDVCを使っています. DVCによるデータ管理は以前の記事もご覧ください.

https://zenn.dev/kazuyanagimoto/articles/vscode-docker-rstudio

これらの条件とミニマルさポータブルさを満たすために私が出した結論は以下の通りです.

1. VSCode内ですべて完結する. DevContainerを使う.
1. Rは必須なので, [rocker](https://github.com/rocker-org/rocker)ベースのDockerイメージ
1. DVCはPythonのパッケージなのでPythonも必須.
1. Juliaはオプション. プロジェクトごとに使ったり使わなかったり.
1. $\LaTeX$ はRの`tinytex`で必要かつ十分. (後述)
1. R, Python, Julia, TinyTeXのパッケージはDocker Volumesによってホスト側にキャッシュする.


:::details なぜRは必須か. なぜrockerベースか.
私はデータ分析を扱う分野においての論文執筆でRは必須と考えます. これは私の専門の経済学で様々な推定方法がRで提供されているからというだけではありません. 最大の理由は`ggplot2`より美しいグラフと`kableExtra`ほどの多機能な$\LaTeX$の表を作れるパッケージが他の言語では提供されていないからです. 私なりの図と表の作り方は以前の記事にまとめてあります.

https://zenn.dev/nicetak/articles/r-tips-graph-2022
https://zenn.dev/nicetak/articles/r-tips-table-2022

またなぜubuntuやイメージベースではないのかというと, LinuxへのRとRstudioのインストールがPythonやJuliaより面倒に感じるからです. Dockerfileを見ていただければお分かりかと思いますが, PythonとJuliaのインストールがかなり簡単なのに対し, RとRstudioのインストールはかなり面倒です. どうせRは必須であるので, rockerベースで作るのが最適と感じています. さらに, あくまでおまけではありますが, TinyTeXの扱いがR環境があるとやりやすいということは大きなメリットでした.

:::


## Docker 環境

https://github.com/kazuyanagimoto/dockerR/blob/main/Dockerfile

### R

ホスト側にRのパッケージはキャッシュするので, `rocker/rstudio`で十分です. 地理情報を扱うプロジェクトの時だけ `rocker/geospatial` に変更しています.

パッケージ管理は`renv`一択であると考えます. パッケージを追加するたびごとにいつも`renv::snapshot()`で記録を`renv.lock`ファイルに残すことができ, 同様のパッケージを他のコンピュータで再現する際にも `renv::restore()` で一発です. `renv`を用いたパッケージ管理は以下の記事でも解説しています.

https://zenn.dev/nicetak/articles/r-tips-cleaning-2022


### Python

僕はPythonはDVCの依存関係ぐらいにしか使わないことが多いので, 特にバージョンにこだわりがなく, `apt`でインストールできるものをインストールします. また, Pythonを分析で使わないといけない場合は (スクレイピングや自然言語処理などで) `pip` と `requirements.txt` で管理します. 

:::details requirements.txt で管理する理由
2023年8月現在, Pythonの仮想環境は混迷を極めていると思います. ざっと見ただけでもvenv, anaconda, pyenv, poetry, ryeなどさまざまなツールがあって何が最適か, 長く使えるのか分かりません. そもそも, Dockerで環境を構築するのだからパッケージのバージョン (と依存性) が分かればいいので, 多機能なツールは使う必要がないと考えています.  正直, `pip install -r requirements.txt` と `pip freeze > requirements.txt` で十分な気がしてなりません. ただ本格的にPythonを研究で使っているわけではないので, 誤解があればご指摘ください.

:::


### Julia

Dockerfileから明らかではあると思いますが, Juliaのバージョンを指定してインストールします. 個人的な経験ですが, Juliaはアップデートによって高速化こそされ, バグで動かなくなるという自体にはあまり遭遇していません. そのため, 基本的には最新のバージョンを指定して, プロジェクトの最中にアップデートがあれば数字を書き換えてビルドし直します.

パッケージ管理は`Project.toml`を使いましょう. これはJuliaの標準的なパッケージ管理ファイルで, Juliaのパッケージを追加するたびに自動で更新されます. はじめに`Project.toml`ファイルをからファイルで作成したあとは, `Pkg.activate()`で環境をアクティベートして使ってください. また`Project.toml`からパッケージをインストールする場合は, `Pkg.instantiate()`でインストールしてください.

### その他

- `openssh-client` コンテナの中から, GitHubにSSHで通信するのに必要です
- DVCはPythonのパッケージなので`dvc`コマンドをターミナルで使用できるようにパスを通しています
- 最後にキャッシュしたパッケージの権限を変更しています. これは Docker Volumesをマウントした場合, root権限で作成されてしまい, ユーザ権限では書き込めなくなってしまうためです.

:::details コンテナ内でGitHubにSSHする方法について
コンテナ内で作業するため, `git pull` や `git push` もコンテナ内で行いたくなります. またDVCは基本的にはコンテナの中にしか導入されていないため, コンテナ内で Git + DVC の作業を完結させたいです.
そのためにはホスト環境のSSHキーをコンテナに移す必要がありますが, これは`ssh-agent` にキーを追加してあれば, Remote Containers の機能によって, 自動で鍵が使えます. 設定はホストOSごとに異なるので, 詳しくは公式ドキュメントの [Developping inside a container](https://code.visualstudio.com/docs/remote/containers#_sharing-git-credentials-with-your-container) の "Sharing Git credentials with your container" の節を読むことをおすすめします.

私はホストOSがWindowsのWSLであるので, `~/.bash_profile` に以下を記述してます.
```shell:~/.bash_profile
# SSH-Agent
eval "$(ssh-agent -s)"
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi
   eval `cat $HOME/.ssh/ssh-agent`
fi
ssh-add $HOME/.ssh/id_ed25519
```
ちなみに, 最終行の `ssh-add` が公式ドキュメントと異なり, 記述する必要がありました.
:::

### docker-compose.yml

https://github.com/nicetak/dockerR/blob/main/docker-compose.yml

ポイントは`cache`という[Docker Volumes](https://docs.docker.com/storage/volumes/)を`$HOME/.cache/`にマウントしているところです. `renv`はデフォルトで`$HOME/.cache/R/renv`にキャッシュしますし, PythonやJuliaのライブラリのキャッシュも`PYTHONUSERBASE`と`JULIA_DEPOT_PATH`という環境変数を指定することで`$HOME/.cache/`以下に保存しています. これによって一度インストールしたパッケージはホスト側にも保存されることになるため, DockerをビルドをするたびにRのパッケージをインストールし直す必要がなくなります. また, 複数のプロジェクトでDocker環境を使い分けている際に, 重複するパッケージをインストールしなくてよくなります. なお, TinyTeXのパッケージやフォントも同様にキャッシュしています.

:::details Docker Volumesとは

Docker VolumesはDockerコンテナのデータをホスト側に保存するための仕組みです. これによって, コンテナを削除してもデータを保持することができます. なお, 初めてこのテンプレートを使う際はDocker Volumesが存在しないので, 以下のコマンドで作成する必要があります.

```shell
docker volume create cache
docker volume create TinyTeX
docker volume create fonts
```

なお, このコマンド叩かずにDockerをビルドすると, Docker Volumesが自動で作成されます. この場合はDocker Volumesの名前が`PROJECTNAME_cache`のようになるので, 他のプロジェクトですでにインストールしたパッケージを使い回すことができません.

また, 以前の私の記事のようにインターネット上では, Docker Volumesを使わずに `~/.cache/R/renv` のようにホストOSの領域に直接マウントしている例がありますが, これはソースコードの場合は良いですが, パッケージの場合はおすすめできません. MacOSやWindows (WSL2を除く) の場合ファイルシステムがLinux (Docker) と異なるため, パッケージを読んで実行する際に著しくスピードが落ちる可能性があります. Docker内で使うパッケージはDockerの領域でキャッシュしましょう.

:::


## $\LaTeX$ 環境

Docker内で$\LaTeX$を使うには, `apt`で`texlive`をインストールしたり, docker-compose.ymlの別サービスとして使うという事もできますが, Rには`tinytex`という軽くてとても便利なパッケージがあるのでこれを利用します.^[TinyTeX自体はRがない環境でもインストールして使うことができます. 詳しくは[公式ドキュメント](https://yihui.org/tinytex/#for-other-users)を参考にしてください.] なお, VSCodeで$\LaTeX$を扱う際は, 以下の記事も参考にしていただければ幸いです.

https://zenn.dev/nicetak/articles/zotero-tex-bibtex

### TinyTeXとは

[TinyTeX](https://yihui.org/tinytex/)は超軽量の$\LaTeX$のディストリビューションです. コンパイルの際に自動で足りないパッケージをインストールしてコンパイルしてくれるため, 事前に大量のパッケージをインストールして$\LaTeX$環境を構築する必要がありません. そのため, RmarkdownやQuartoでPDFをコンパイルする際にはデフォルトで使用されています. この軽量であるという特徴はDocker環境とかなり相性がよく, `rocker/verse`イメージでも採用されています. 今回は, このTinyTeXをVSCodeでの$\LaTeX$コンパイラーにしてしまおうという話です. また, この時インストールされる$\LaTeX$のパッケージもDocker Volumesにキャッシュされます.

### TinyTeXのインストールとVSCodeでの設定

TinyTeXをインストールする際は, `tinytex::install_tinytex()` というRコマンドがあります. ただ, TinyTeXを用いてインストールされるパッケージはDocker Volumesにキャッシュしたいため, 以下のようにインストールフォルダを指定します.

```r
tinytex::install_tinytex(dir = "/home/rstudio/.TinyTeX", force = TRUE)
```

なお, 一度Docker Volumesにインストールしてしまえば, 今後はこのコマンドを他のプロジェクトであっても実行する必要はありません. 

VSCodeでTinyTeXを$\LaTeX$のコンパイラにするために, `settings.json`を以下のように編集します. なお, `WORKSPACE_DIR/.vscode/settings.json`に設定した場合は, このワークスペースのみで有効な設定になります. チームプロジェクトでは`settings.json`をgit-ignoreすることも多いと考えるので, テンプレートでは`_settings.json`と名前を変えてあります. 

https://github.com/kazuyanagimoto/dockerR/blob/main/.vscode/_settings.json

:::details なぜOverleafを使わないのか

[Overleaf](https://www.overleaf.com/)はもはや$\LaTeX$のエディターの第一候補といっても差し支えないでしょう. 二年前の話ですが, 修士の同級生がOverleafと$\LaTeX$の概念の区別がついていないことにびっくりしました. しかし, 私はOverleafにいくつもの不満点があります.

- 無料版ではOverleafはGitHubが連携できない. 
- GitHubのブランチも分けられない
- スライドや論文の図表の見え方の修正をしたいのにいちいち, アップロードしないといけない
- ファイル数が1プロジェクトあたり最大で2000ファイルと制限されている.
- たまにサービスが落ちる. 締め切り前であった場合これは致命的
- GitHub Copilotが使えないエディタは時間の無駄 (後述)

正直, TinyTeXとVSCodeのLaTeX Workshop拡張があれば環境の設定も難しくなく, コンパイルもローカルのコンピュータにもよりますが早いので, 私にとってはOverleafを使う意味はあまりありません.

:::


## VSCode Extensionについて

VSCodeのRemote Containersのための設定は以下のとおりです. ほとんど直感的ですが, Extensionに関してはいくつか説明を加えたいと思います.

https://github.com/kazuyanagimoto/dockerR/blob/main/.devcontainer/devcontainer.json


#### [Gramarly Extension](https://marketplace.visualstudio.com/items?itemName=znck.grammarly)

言わずとしれた英文校正サービスの[Grammarly](https://www.grammarly.com/)のVSCode Extensionです. これを入れるだけで, 無料でスペルミスから三単現のsのつけ忘れ, 冠詞の修正などをこなしてくれます. 有料版の機能も使うことが可能です. また, `.tex`, `.Rmd`, `.qmd`ファイルにおいても使うことが可能です. 詳しくは拡張機能自体のヘルプを参照にしてほしいですが, 以下のようにconfigファイルに拡張子追加するだけです.

```json
{
  "grammarly.files.include": ["**/README.md", "**/readme.md", "**/*.txt", "**/*.tex", "**/*.Rmd", "**/*.qmd"]
}
```
#### [Edit CSV](https://marketplace.visualstudio.com/items?itemName=janisdd.vscode-edit-csv)

CSVやTSVファイルなどをサクッと確認や編集したいときに大変便利な拡張機能です. これがないと, Excelのような表計算ソフトを使ったりしないとプレビューもろくにできないので, かなり重宝します. とくにリモートで作業する際には, ローカルでExcelなどでファイルを開くのはかなり面倒なので, この拡張機能は必須です.

#### GitHub Copilot

2023年8月現在, GitHub Copilotを**使わずに**コーディングするのは時間の無駄です. ゲームで言うなら舐めプです. この拡張機能は移り変わりが激しいので, 最新のドキュメントを参考に導入してみてください.

## ワークフロー

実際にこのテンプレートを用いてプロジェクトを始める際の手順と作業中のワークフローを紹介します. 管理者はこのテンプレートを使ってプロジェクトを作成し, 共同作業者はそのプロジェクトをクローンして作業をすることを想定しています. 作業中は管理者も共同作業者も同じ手順で作業を進めます.

### 管理者

0. DockerのVolumeを作る. (初めてこのテンプレートを使う際のみ)

```shell
docker volume create cache
docker volume create TinyTeX
docker volume create fonts
```

1. GitHubでこのテンプレートから新しいレポジトリを作り, ローカルにクローンする
1. VSCodeでこのレポジトリを開く. (Remote Containers)
1. Rのプロジェクトを作成する. Rstudioを用いる場合, `localhost:8787`にアクセスし, プロジェクトを作成する
1. `renv::init()` でパッケージ管理を開始する
1. `pip install dvc dvc-gdrive` でDVCをインストールする. 二回目以降はpipのキャッシュがあるためこのコマンドは不要
1. DVC環境を設定する
   - Google Drive上にフォルダを作成し, そのフォルダのIDをコピーする
   - `dvc init && dvc remote add -d myremote gdrive://<Google DriveのフォルダID>` を実行する
   - Google Driveのフォルダは共同作業者と共有の設定をする
1. LaTeX用のVSCodeの設定をする
   - 初めての場合, `tinytex::install_tinytex(dir = "/home/rstudio/.TinyTeX", force = TRUE)` を実行して, TinyTeXをインストールする
   - `.vscode/_settings.json` を `.vscode/settings.json` にコピーする
1. Juliaの環境を設定する. `Project.toml`の空ファイルを作成し, `Pkg.activate()`でアクティベートする

### 共同作業者

0. DockerのVolumeを作る. コマンドは管理者と同様. (初めてこのテンプレートを使う際のみ)
1. GitHubで管理者が作ったレポジトリをクローンする
1. VSCodeでこのレポジトリを開く. (Remote Containers)
1. Rのプロジェクトを開く
1. `renv::restore()` でパッケージをインストールする.
1. Pythonパッケージ (DVCを含む) を `pip install -r requirements.txt` でインストールする
1. `dvc pull` でデータをダウンロードする
1. LaTeX用のVSCodeの設定をする
   - 初めての場合, `tinytex::install_tinytex(dir = "/home/rstudio/.TinyTeX", force = TRUE)` を実行して, TinyTeXをインストールする
   - `.vscode/_settings.json` を `.vscode/settings.json` にコピーする
1. Juliaのパッケージをインストールする. `Pkg.activate(); Pkg.instantiate()`でインストールする


### 作業中

1. Rのパッケージを追加する際は, `install.packages("PACKAGENAME")` でインストールし, `renv::snapshot()`で記録を`renv.lock`ファイルに残す
1. Juliaのパッケージを追加する際は, `Pkg.add("PACKAGENAME")`で追加する. `Project.toml`に自動で記録される
1. Pythonのパッケージを追加する際は, `pip install PACKAGE_NAME`で追加し, `pip freeze > requirements.txt` で記録する
1. DVCでデータを追加する際は, `dvc add`で追加する. 基本的には`dvc add data/`でディレクトリごと追加する
1. 以上の作業が終わった上で, `git add`, `git commit`, `git push` する
1. 作業が終わったら, `dvc push` でデータをアップロードする


## まとめ

以上が私が考えるミニマルでポータブルな研究環境のテンプレートとその使い方でした. VSCodeとDockerで完結しているため, 実際にはかなり少ない手順でまったく同一の環境を他のコンピュータ上で再現することができます. また, すべてのパッケージをキャッシュするため, Dockerのビルド時間もかなり少なくなっておりメンテナンスのコストも結果下がりました. 私にとってのベストな環境が皆さんにとってもベストな環境であるとは限りませんが, この記事が皆さんの研究の一助になれば幸いです.
