---
title: "VSCode + Docker + Rstudio + DVC でポータブルな研究環境を作る"
emoji: "🐳"
type: "tech" 
topics: ["vscode", "docker", "r", "rstudio", "dvc"]
published: true
---

# はじめに
### 研究環境を全部Dockerにしたい
みなさん, Dockerって便利ですよね. プロジェクトを複数持っている時に, 環境を簡単に切り替えることができて最高ですよね. また複数人のプロジェクトも同一の環境で実行できるって, 魅力的ですよね.

### なんなら, 全部 VSCodeのDev Containerにしたい
VSCodeのRemote Container Extension機能のおかげで, Docker環境がますます便利になったと思います. コンテナ内をまるでローカルのようにGUIで扱えるのでDockerに関する学習コストがとりわけ少なくなったように感じます. 個人的には共同のプロジェクトでもDockerを使ってもらいやすくなったと感じています (環境はこちらで構築すれば良いので.)

今回の目標はRstudio + LaTeXの研究環境をまるごとDocker + VSCodeで構築することです. この環境はわずか数ステップで他のPCで再現することができるようになります.

### 条件
- `git clone` と VSCodeの **Open Floder in Container** ですべての環境を整える
- Rはサーバー版のRstudioを使う.^[ブラウザで `localhost:8787` とアドレスバーに打って使います] VSCode上の開発も可能にする
- $\LaTeX$はVSCodeで書く
- データはDVC経由で管理する (後述)

VSCodeで$\LaTeX$を書く際のTipsは以前書いた記事も参考にしてみてください.
@[card](https://zenn.dev/nicetak/articles/zotero-tex-bibtex)

# 環境
## ソフトウェア
- [Visual Studio Code](https://code.visualstudio.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

なお, この記事の読者はDockerとVSCodeのRemote Containersに関しては使い方を知っていることを前提とします.

また, Windowsの方は[Docker公式が推奨するように](https://docs.docker.com/desktop/windows/wsl/), フォルダがWSL配下にあるかつ, WSLバックエンドであることを仮定します.

## ファイル構成
この記事に対応したレポジトリを用意しました.
クローンした後, **"Open in container"** で環境がすべて整います.
なお, DVCはコンテナ上で開いた後に次節のセットアップをする必要があります.
@[card](https://github.com/nicetak/docker-r-template)

### Dockerfile
```docker
FROM rocker/tidyverse:latest

RUN apt update && apt install -y gnupg openssh-client texlive-full

# DVC
RUN wget \
       https://dvc.org/deb/dvc.list \
       -O /etc/apt/sources.list.d/dvc.list && \
    wget -qO - https://dvc.org/deb/iterative.asc | apt-key add - && \
    apt update && \
    apt install -y dvc 

# R Packages
RUN R -e "install.packages( \
    c('languageserver', 'here', 'kableExtra', 'patchwork', 'janitor', 'markdown'))"
```

#### R イメージ
特に理由がなければ, rocker-org のrockerイメージの中から選ぶのが良いと思います.
@[card](https://github.com/rocker-org/rocker)
基本的には
- rocker/rstudio
- rocker/tidyverse
- rocker/verse
- rocker/geospatial

の中から選べばよく, `tidyverse`を使うなら`rocker/tidyverse`, そうでないなら`rocker/rstudio`を選べばよいでしょう. 地理情報を使う方は`rocker/geospatial`を選びましょう. `rocker/verse` は`texlive-full` を結局入れるのであまり使っていません.

#### その他のソフトウェア
- `gnupg` DVCの依存関係のインストールに必要
- `openssh-client` GitHub とSSH通信するために必要
- `texlive-full` $\LaTeX$ 環境. 必要以上に大きすぎる可能性はあります

:::details コンテナ内でGitHubにSSHする方法について
基本的にコンテナ内で作業するため, `git pull` や `git push` もコンテナ内で行いたくなります. そのためにはホスト環境のSSHキーをコンテナに移す必要がありますが, これは`ssh-agent` にキーを追加してあれば, Remote Containers が自動でコンテナ内にコピーしてくれます. そのための設定はOSごとに異なるので, 詳しくは公式ドキュメントの [Developping inside a container](https://code.visualstudio.com/docs/remote/containers#_sharing-git-credentials-with-your-container) の "Sharing Git credentials with your container" の節を読むことをおすすめします.
:::

#### DVC
公式の[Install from repository](https://dvc.org/doc/install/linux#install-from-repository) をそのまま用いています. Pythonを用いる環境なら`pip`で入れてしまうほうが簡単だと思います.

#### R パッケージ
基本的には通常のRからのインストール方法である
```R
install.packages()
```
を実行しているだけです. 追加で必要なパッケージは基本的に`Dockerfile`に書いてビルドする形で対応しています. 現状のDockerfileには私の研究環境で基本的に必須のパッケージを入れています.

:::details GitHubで開発中のパッケージを用いる場合
CRANにまだ登録されていないパッケージをインストールする場合は,
```Dockerfile
RUN Rscript -e "devtools::install_github('tidyverse/googlesheets4')"
```
などを追加して, `devtools::install_github`を用いてインストールできます.
:::

なお, *languageserver* パッケージをいれることで, VSCode上でRを開発するための拡張機能が利用できます.
@[card](https://marketplace.visualstudio.com/items?itemName=Ikuyadeu.r)

### docker-compose.yml
Remote Containers は仕組み上Dockerfileのみでもコンテナ環境を作れるはずですが, rocker環境の場合はdocker-compose.yml をベースにしないとRstudioサーバーが立ち上がりません.
なお, マウントの設定も行っているため, Remote Containersに入る前のホスト環境で
```shell
docker-compose up --build
```
とすれば, `localhost:8787` からRstudioの環境に入ることは一応できます.


### ./devcontainer/devcontainer.json
```json
{
    "name": "${localWorkspaceFolderBasename}",
    "dockerComposeFile": "../docker-compose.yml",
    "service": "rstudio",
    "remoteUser": "rstudio",
    "extensions": [
		"ikuyadeu.r"
	],
	"forwardPorts": [8787],
    "workspaceFolder": "/home/rstudio/work",
    "shutdownAction": "stopCompose",
    "settings": {
    }
}
```
デフォルトの `devcontainer.json` と大きく異なる点は
- `remoteUser` に rockerイメージのデフォルトのユーザーである `rstudio` を設定している^[Mac OS ならばあまり気にする必要はありませんが, Linux や WSL 環境下ではroot権限のまま作業するとホスト側からファイルを修正したいときに (例えばDockerfileなど) ファイルを操作できなくなってしまうので, ユーザーを設定したほうがよいです.]
- ポート8787 をフォワードしている (Rstudio サーバーのデフォルトポート)
- `workspaceFolder` を設定している (つまり, デフォルトの`/workspaces` ではない)

ぐらいです. なお, 拡張機能の`ikuyadeu.r`は前述のR開発のための拡張機能です.

# DVC
## DVC とは
[DVC (Data Version Control)](https://dvc.org/) は機械学習のモデルとデータのバージョン管理をGitとともに行うことを目的としたソフトウェアです. 機械学習の分野ではさらに便利な利用方法がありますが, ここでは単にデータ分析するためのデータ管理ツールとして用います. 通常GitHubのプロジェクトでデータを扱うには
- 1ファイルあたり100MBという制限
- データクリーニングの結果などをGitで管理する必要がない (クリーニングのコードで十分)

といった問題があります. [Git Large File Storage](https://git-lfs.github.com/)などもありますが, 有料である点などが気になります.

DVCでは以下のようにしてデータを管理します.
- データファイルのメタ情報(.dvcファイル)を生成し, Gitではdvcファイルのみを管理する
- データ本体はgitignoreし, 他のストレージ (Google DriveやAmazon S3など) で管理する

![](/images/vscode-docker-rstudio/dvc.png)
*DVCの概念図*

:::details 概念図では省略した部分について
正確には, dvcファイルを作成した際に``.dvc/cache``フォルダの中にデータが移されます. またこの際には, データ本体の名前はハッシュ化されたランダムな英数名になり, もとのファイルの場所 (図では``data1.csv``) にはシンボリックリンクが張られた状態になります. また, クラウド上にプッシュされるファイルも``.dvc/cache``下にあるファイルです. したがって, クラウド上のファイル名はハッシュ化された名前になります.

なお, シンボリックリンクを作れないWindows OSでは, シンボリックリンクではなく, ファイルのコピーを作成するため, データ容量は原理的に2倍になってしまいます. 今回のワークフローはDocker上のLinux環境なので関係はありませんが.
:::

### クラウドストレージの選択について
DVCが対応しているリモートストレージやプロトコルは[Supported storage types](https://dvc.org/doc/command-reference/remote/add#supported-storage-types)にありますが, 私のおすすめはGoogle Driveです. 理由は
- ほとんどの研究者はアカウントをすでに持っている
- 教育機関のGoogleアカウントはGoogle Driveのストレージが無制限である
- コラボレーターがデータをダウンロードする際のアクセス権限はGoogle Driveのフォルダの共有設定を行うだけである

点で便利だと思うからです. 以下ではGoogle Driveの場合の設定方法を解説します.

## DVCの使い方
DVCはGitに準じたコマンドを用いて, ファイルを管理します.
### セットアップ
1. `dvc init`: プロジェクトのフォルダでdvcプロジェクトを始めます. `.dvc`フォルダと`.dvcignore`ファイルが作られます
1. Google Drive内にデータ管理用のフォルダを作成します. フォルダをGoogle Driveで開いた際のアドレスバーに書いてあるコードをコピーしてください.
1. `dvc remote add --default myremote gdrive://GDRIVE_FOLDER_CODE`: dvcのリモートストレージを設定します.

### ファイルの追加, 共有
- `dvc add`: dvcファイルを作成または更新します. また`.gitignore`が作成され, データ本体はGit管理から除外されます
- `dvc add -R data`: `data/`フォルダ以下のファイルのdvcファイルを作成または更新します. 基本的にこれだけ使えば問題ないです.
- `dvc push`: データファイルをクラウドにプッシュします
- `dvc pull`: `.dvc/` フォルダの情報とdvcファイルの情報から, データ本体をクラウドからダウンロードします

### その他
#### `.dvcignore`ファイル
データフォルダ内でDVCで管理したくない (Git管理したい) ファイルを指定してください. `.gitinore` と同様にワイルドカードでも指定できます.

#### 認証
初めての`dvc push`または`dvc pull`の際に, Google Driveのアクセスの認証が行われます.
```
Go to the following link in your browser:

    https://accounts.google.com/o/oauth2/auth # ... 
Enter verification code:
```
というメッセージが出るので, このリンクをブラウザで開き, Google アカウントでログインした後, 認証コードが表示されるので, それをコピーして"Enter verification code:"の後にペーストして認証を行います.

# ワークフロー
- プロジェクトを始める場合は以下の1を行ってください
- コラボレーターや自分の他のPCには1を完了した後で2を行ってください
- セットアップが終わった後は3の通り作業して行けばよいです

### 1. プロジェクトを始める場合
1. `Dockerfile`, `docker-compose.yml`, `.devcontainer/devcontainer.json` を用意する
1. **Open Folder in Container**
1. DVC のセットアップを行う
1. `git push`
1. `dvc push`
1. Google Driveの認証を行う

### 2. 上記のセットアップが行われたレポジトリを再現する場合

1. `git clone`
1. **Open Folder in Container**
1. `dvc pull`
1. Google Driveの認証を行う

### 3. 1, 2の後の実際の作業フロー
1. `git pull origin main`
1. `dvc pull`
1. 作業 (基本的にブランチを切った後で)
1. ``dvc add -R data``
1. ``git add`` & ``git commit``
1. `git push` (ブランチは各自で)
1. `dvc push`

## デモンストレーション
このワークフローの簡便さを体感していただくために, 簡単なデモを行います. [先ほど紹介したレポジトリ](https://github.com/nicetak/docker-r-template)の`main`ブランチはプロジェクトを開始するためのテンプレートですが, `demo`ブランチはすでに私がdvcのセットアップした状態となっています.
`demo`ブランチをプルした後
- **Open Folder in Container**
- `dvc pull`

を行うことで, 私が分析を行った環境を整えることができます.
:::message 
`dvc pull` を行うと, ご自身のGoogleアカウントの認証が必要になります. このデモデータは私のGoogle Drive内に保存されており, 誰でも閲覧できる状態になっています.
:::

分析結果を再現するためには
- ブラウザで`localhost:8787`にアクセスしRstudioを開く
- 右上のOpen Projectボタンから, `work/work.Rproj`を選択しRのプロジェクトを開く
- `r/demo.Rmd`を開き, すべてのセル実行するかknitする

以上で私の分析結果が再現できました.
:::message alert
`main`ブランチは実際の研究で使うテンプレートとするために, `texlive-full`などの大きなソフトウェアをダウロードしています. デモンストレーション目的には必要ありませんので, `demo`ブランチの`Dockerfile`はデモに必要な最小構成になっています. `main`ブランチで**Open Folder in Container**をする際はビルドに時間がかかることをご留意ください.
:::

# おわりに
以上が私が普段使っている研究環境です. これを真似することで, わずか数ステップで, 新しいPCに全く同じ研究環境が作れます. みなさまの研究ライフが少しでもシンプルになれば幸いです.








