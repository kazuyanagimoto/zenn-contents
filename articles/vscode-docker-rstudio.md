---
title: "VSCode + Docker + Rstudio + DVC でポータブルな研究環境を作る"
emoji: "📝"
type: "tech" 
topics: ["vscode", "docker", "r", "rstudio"]
published: false
---

# はじめに
### 研究環境を全部Dockerにしたい
みなさん, Dockerって便利ですよね.

### なんなら, 全部 VSCodeのDev Containerにしたい


### 条件
- `git clone` と VSCodeの **Open Floder in Container** ですべての環境を整える
- Rはサーバー版のRstudioを使う^[ブラウザで `localhost:8787` とアドレスバーに打って使います]
- $\LaTeX$はVSCodeで書く
- データはDVC経由で管理する (後述)


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
を実行しているだけです. 追加で必要なパッケージは基本的に`Dockerfile`に書いてビルドする形で対応しています.
:::details GitHubで開発中のパッケージを用いる場合
CRANにまだ登録されていないパッケージをインストールする場合は,
```Dockerfile
RUN Rscript -e "devtools::install_github('tidyverse/googlesheets4')"
```
などを追加して, `devtools::install_github`を用いてインストールできます.
:::

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

ぐらいです. 

# DVC
## DVC とは

## セットアップ

# ワークフロー
- プロジェクトを始める場合は以下の1を行ってください
- コラボレーターや自分の他のPCには1を完了した後で2を行ってください
- セットアップが終わった後は3の通り作業して行けばよいです

### 1. プロジェクトを始める場合
1. `Dockerfile`, `docker-compose.yml`, `.devcontainer/devcontainer.json` を用意する
1. **Open Folder in Container**
1. DVC のセットアップを行う
1. `git push origin main`
1. `dvc push`

### 2. 上記のセットアップが行われたレポジトリを再現する場合

1. `git clone`
1. **Open in container**
1. `dvc pull`

### 3. 1, 2の後の実際の作業フロー
1. `git pull origin main`
1. `dvc pull`
1. 作業
1. `git push` (ブランチは各自で)
1. `dvc push`

# おわりに
以上が私が普段使っている研究環境です. これを真似することで, わずか数ステップで, 新しいPCに全く同じ研究環境が作れます. みなさまの研究ライフが少しでもシンプルになれば幸いです.








