# script4iptables

iptables の設定を簡略化するためのスクリプトです。
このスクリプトで次のような設定が簡単にできます。

1. 攻撃パケットを破棄する。
2. ブラックリスト、特定国からのアクセスを拒否する。
3. 特定アドレスからのみ ssh アクセスを許可する。
4. ホワイトリスト、特定国からのみ git, subversion へのアクセスを許可する。
5. ホームページは全体に公開する。


## 簡単設定
1. ipset をインストールする。
	apt install ipset   # Debian 系の場合
	yum install ipset   # Red Hat 系の場合
2. conf/zone.conf に設定を記載する。
3. bin/ipset-update を実行する。
4. bin/iptables-update を実行する。


---
## 事前準備

- Debian 系の場合
	apt install ipset

- RedHat 系の場合
	yum install ipset


## インストール
一式を任意のディレクトリにおいてください。


## 設定
conf/zone.conf の編集

- WHITE_LIST_CONTRIES
-- ホワイトリストとする国の2文字コードをスペース区切りで記載します。
	例) 日本と台湾を有効にする場合
	WHITE_LIST_COUNTRIES=( "jp" "tw" )

- BLACK_LIST_COUNTRIES
-- ブラックリストとする国の2文字コードをスペース区切りで記載します。

- LOCALNET_LIST
-- ローカルネット(基本的に全サービスを提供するネットワーク)を記載したファイルを指定します。
デフォルトでは、下記が記載されているファイル(${ZONE_DIR}/localnet-list.zone)が指定されます。

	10.0.0.0/8
	172.16.0.0/12
	192.168.0.0/16

- TRASTED_LIST
-- 信頼できるアドレス(SSHアクセスを許可するアドレスなど)を記載したファイルを指定します。
bin/ipset-update を実行した際、現在接続されている ssh の接続元が追記されます。

- WHITE_LIST_OTHER
-- ホワイトリストとするIPアドレスを記載します。

- BLACK_LIST_OTHER
--ブラックリストとするIPアドレスを記載します。

## 設定反映
- 次のコマンドを実行して設定を反映します。

	bin/ipset-update
	bin/iptables-update

※ホワイトリスト、ブラックリストのIPアドレスを更新する場合は、bin/ipset-update のみ実施ください。


## 設定の保存し、再起動時にも有効とする。(Debian 系のみ)
- 次のコマンドを実行しツールをインストールします。

	apt install netfilter-persistent	# 再起動後も設定を有効にするために利用します。
	apt install iptables-persistent		# 同上
	apt install ipset-persistent		# 同上

- 次のコマンドを実行して設定を保存します。

	bin/all-save


---

## 機能, フィルタルールを追加、変更する人向け説明

### 構成
	+-- bin/
	|    +-- all-save        : ipset, iptables の情報を保存し、起動時に自動反映するスクリプト。
	|    +-- dl-zone-file    : 指定された国の zone ファイルをダウンロードするスクリプト。
	|    +-- ipset-mkrestore : zone ファイルより、ipset を生成/更新するスクリプト。
	|    +-- ipset-update    : zone.conf の設定に従い、ipset 情報を更新するスクリプト。
	|    +-- iptables-clear  : iptables の情報をクリアするスクリプト。
	|    +-- iptables-update : conf/rule.d 配下のルールに従い、iptables の情報を更新するスクリプト。
	|
	+-- conf/
	|    +-- zone.conf       : 設定ファイルです。
	|    +-- rule.d/         : iptables の実行するコマンドが記載されたスクリプトが格納されています。。
	|                          本ディレクトリにスクリプトを格納することで機能追加可能です。
	|
	+-- zone/                : ipset に利用する IPアドレスのリストなどを記載したファイルが格納されます。
	|        
	+-- README.md            : 本ファイル

※それぞれのスクリプトの使い方は、--help オプションで確認してください。

### 現状のルール
次の 1～ 順番に適用されます。

1. conf/rule.d/v4/00_init.sh
- ループバックの通信をすべて許可
- 接続中の SSH 通信を許可
- ローカルネット (localnet-list), 信頼できるネットワーク (trusted-list) からの SSH 通信を許可
- 接続確立後の応答パケットを許可
- IGMP パケットを許可

2. conf/rule.d/v4/20_blacklist.sh
- ブラックリストからの通信を拒否

3. conf/rule.d/v4/21_reject.sh
- IDENT/AUTH への要求に対して、REJECT を返す。(DROP の場合にメール処理が遅くなることを防ぐため)

4. conf/rule.d/v4/30_attack_sthelthscan.sh
- ステルススキャン攻撃を防ぐ

5. conf/rule.d/v4/31_attack_pingofdeath.sh
- Ping Of Death 攻撃を防ぐ

6. conf/rule.d/v4/32_attack_synflood.sh
- SYNFLOOD 攻撃を防ぐ

7. conf/rule.d/v4/40_localnet.sh
- ローカルネット (localnet-list) からのプロキシ機能(TCP, Port=3129) へのアクセスを許可する。

8. conf/rule.d/v4/40_whitelist.sh
- ホワイトリストからの SSH アクセスを許可する。

9. conf/rule.d/v4/50_public.sh
- HTTP(Port=80), HTTPS(Port=443) へのアクセスを許可する。

