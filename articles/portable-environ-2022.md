---
title: "VSCode + Dockerでよりミニマルでポータブルな研究環境を作る"
emoji: "🐳"
type: "tech" 
topics: ["vscode", "docker", "r", "dvc"]
published: false
---

# はじめに

自分自身の研究のための環境についてこれまで二本の記事を書いてきました.

@[card](https://zenn.dev/nicetak/articles/zotero-tex-bibtex)
@[card](https://zenn.dev/nicetak/articles/vscode-docker-rstudio)

これらの記事から一年ほどたち, いくつかの点において不満点が出てきました. 特に, GCPや自宅のデスクトップでリモートで作業することが多くなってきたので, よりミニマルでポータブルな環境が必要になりました.

以下では, 現時点で最小限の努力で

この環境を用いると, 新たなコンピュータ上での環境の再現が4ステップで完了します.

1. `git clone`
1. VSCodeの"Open in Remote Containers"
1. `renv::restore()`
1. `dvc pull`


この環境とセットアップはこのレポジトリにテンプレートとしておいて置きます. 実際, 私自身も新しいプロジェクトを始める際にはこのテンプレートを用いて環境を作っています.


## Docker 環境

https://github.com/nicetak/dockerR/blob/main/Dockerfile

### `rocker/verse` イメージ
特に理由がなければ, rocker-org の rocker イメージの中から選べば良いと思います.
@[card](https://github.com/rocker-org/rocker)

後述する TinyTeX が含まれているので, 現在は `rocker/verse` をメインで使っています. 地理情報を扱うプロジェクトの時だけ `rocker/geospatial` に変更しています.

### その他のソフトウェア
- `gnupg` DVC の導入に必要
- `openssh-client` コンテナの中から, GitHubにSSHで通信するのに必要

:::details コンテナ内でGitHubにSSHする方法について
コンテナ内で作業するため, `git pull` や `git push` もコンテナ内で行いたくなります.
またDVCは基本的にはコンテナの中にしか導入されていないため,
コンテナ内で Git + DVC の作業を完結させたいです.
そのためにはホスト環境のSSHキーをコンテナに移す必要がありますが,
これは`ssh-agent` にキーを追加してあれば, Remote Containers の機能によって, 自動で鍵が使えます.
設定はホストOSごとに異なるので, 詳しくは公式ドキュメントの [Developping inside a container](https://code.visualstudio.com/docs/remote/containers#_sharing-git-credentials-with-your-container) の "Sharing Git credentials with your container" の節を読むことをおすすめします.

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

ポイントは`renv` のキャッシュをホスト側にマウントしているところです. これによってDockerをビルドをするたびにRのパッケージをインストールし直す必要がなくなります. また, 複数のプロジェクトでDocker環境を使い分けている際に, 重複するパッケージをインストールしなくて良くなります.

:::message
ホスト側に`~/.renv`のディレクトリが元々ない場合, root権限で`~/.renv`が作成されてしまいます. これはトラブルの元なので, 事前にホスト側に`~/.renv`ディレクトリを作成してから, Dockerイメージをビルドする必要があります.
:::

## R 環境
### `renv`


## Julia & Python 環境


## $\LaTeX$ 環境
### TinyTeX でコンパイル

### BibTeX はZotero API から
