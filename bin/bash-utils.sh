#!/bin/bash
########################################################################
## Script    : bash-utils.sh
## Name      : bash 用ユーティリティ関数スクリプト
## Version   : 0.0.3
## Copyright : 2018-2019  Nomura Kei
## License   : BSD-2-Clause
########################################################################
#SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
#SCRIPT_FILE=${SCRIPT_DIR}/$(basename ${BASH_SOURCE:-$0})


########################################################################
##
## 関数定義
##


# =====================================================================
#  指定されたパスの絶対パスを取得します。
#
#  [注意事項]
#  間にパスが存在しない場合、元の値をそのまま返します。
#
#  @param $1 パス
#  @stdout 絶対パス
# =====================================================================
function getAbsolutePath()
{
	INPUT_PATH=$1
	if [ -d ${INPUT_PATH} ]; then
		INPUT_PATH="${INPUT_PATH}/dummy"
	fi
	OUTPUT_PATH=$(cd $(dirname ${INPUT_PATH}); pwd)
	echo "${OUTPUT_PATH}"
	return 0
}



# =====================================================================
#  スクリプト中の "## [key] : [value]" 形式で記載されている
#  プロパティの値([value])を取得します。
#
#  @param  $1 key
#  @stdout value
# =====================================================================
function getProperty() {
KEY=${1}
sed -n "s/^##\s*${KEY}\s*\:\s*\(.*\)$/\1/p" ${SCRIPT_FILE}
}


# =====================================================================
#  スクリプトファイルのバージョン情報を出力します。
#  スクリプトファイルには、次のコメント行が必要となります。
#  ※間の空白は無視されます。
#
#  ## Script  : スクリプトファイル名
#  ## Version : バージョン番号
#  
#  @stdout バージョン情報
# =====================================================================
function version() {
SCRIPT=`getProperty "Script"`
VERSION=`getProperty "Version"`
echo "${SCRIPT}  ${VERSION}"
}


# =====================================================================
#  スクリプトファイルの使用法を出力します。
#  スクリプトファイルには、次の形式の使用法情報が必要となります。
#  ※'## Usage:' ～ '##' 範囲の行で、'## |'より後ろの文字列が、
#    使用法として表示されます。
#
#  ## Usage:
#  ## |使用例) ...
#  ## |...(ヘルプ情報)...
#  ## |...(ヘルプ情報)...
#  ##
#
#  @stdout ヘルプ
# =====================================================================
function usage() {
sed -n "/^##\s*Usage\s*\:\s*/,/^##\s*$/ s/^##\s*|\(.*\)$/\1/p" ${SCRIPT_FILE}
}


# =====================================================================
#  指定されたメッセージと共に y/n を入力させ、結果を返します。
#  y,Y,n,N いずれの文字でも始まらない場合、デフォルト値を返します。
#
#  変数 ${NO_CONFIRM} が 'y' に設定されている場合、
#  問い合わせのメッセージを表示することなく、常に 1 を返します。
#
#  @param  $1 メッセージ
#  @param  $2 デフォルト値 (1=y, 0=n)
#  @return $? 1/0 (y/n)
# =====================================================================
function confirm() {
	MESSAGE=$1
	DEFAULT=$2

	if [ "${NO_CONFIRM}" = "y" ]; then
		return 1
	fi

	LINE=
	read -p "${MESSAGE} [y/n] " LINE
	VAL=${LINE:0:1}
	if [ "${VAL}" = "y" ] || [ "${VAL}" = "Y" ]; then
		return 1
	elif [ "${VAL}" = "n" ] || [ "${VAL}" = "N" ]; then
		return 0
	fi
	return ${DEFAULT}
}


# =====================================================================
#  指定された値が、指定されたリストに含まれるか否かを返します。
#
#  @param  $1 リスト。
#  @param  $2 含まれるか否か検査する値
#  @return $? 1/0 (含まれる/含まれない)
# =====================================================================
function isContains() {
	LIST=$1
	VALUE=$2
	for item in ${LIST}; do
		if [ "${VALUE}" = "${item}" ]; then
			return 1
		fi
	done
	return 0
}


# =====================================================================
#  指定された値が、指定されたリスト(正規表現)に
#  含まれるか否かを返します。
#
#  @param  $1 リスト。
#  @param  $2 含まれるか否か検査する値
#  @return $? 1/0 (含まれる/含まれない)
# =====================================================================
function isContainsRegex() {
	LIST=$1
	VALUE=$2
	for item in ${LIST}; do
		RES=`echo "${item}" | sed "s/${VALUE}/1/"`
		if [ "${RES}" = "1" ]; then
			return 1
		fi
	done
	return 0
}


# =====================================================================
#  指定された出力先にファイルがある場合、上書きするかを問い合わせ、
#  y が選択された場合、上書きします。
#  n が選択された場合、処理を中断します。
#
#  @param $1 出力先
# =====================================================================
function overwrite() {
	OUT=$1
	if [ -f ${OUT} ]; then
		MSG_PATH=`getAbsolutePath ${OUT}`
		confirm "${MSG_PATH} が存在します。上書きしますか？" 0
		if [ $? -eq 0 ]; then
			exit 1
		fi
	fi
}



# =====================================================================
#  パスワードを入力させます。
#  確認のため２回パスワード入力を求め、２回のパスワードが
#  一致すれば入力されたパスワードを標準出力し、0 を返します。
#  不一致の場合は、1 を返します。
#
#  @param  $1 パスワード入力メッセージ
#  @param  $2 パスワード再入力メッセージ
#  @stdout 入力されたパスワード
#  @return 0/1 (成功/失敗)
# =====================================================================
CONFIRM_PASSWORD=
function confirmPassword() {
	MESSAGE=$1
	MESSAGE_RE=$2
	read -s -p "${MESSAGE}" PASSWORD
	echo ""
	read -s -p "${MESSAGE_RE}" CONFIRM_PASSWORD
	echo ""
	RET=1
	if [ "${PASSWORD}" = "${CONFIRM_PASSWORD}" ]; then
		CONFIRM_PASSWORD=${PASSWORD}
		RET=0
	else
		CONFIRM_PASSWORD=
		RET=1
	fi
	return ${RET}
}



# =====================================================================
#  指定されたテンプレートファイル中の変数を環境変数の値で置換し、
#  標準出力します。
#
#  @param  $1 テンプレートファイル
#  @stdout 変数が置換されたテンプレートの内容
#  @return 0/1 (成功/失敗[テンプレートファイルが無い])
# =====================================================================
function template() {
	TMPL_FILE=$1
	RET=0
	if [ -f ${TMPL_FILE} ]; then
		while read LINE; do
			echo $(eval echo "${LINE}")
		done  < ${TMPL_FILE}
	else
		RET=1
	fi
	return ${RET}
}



# =====================================================================
#  デバッグ用ステップ実行
#  ${DEBUG} の値が 1 の場合、ポーズします。
# =====================================================================
function debugPause() {
	if [ "${DEBUG}" = "1" ]; then
		read -p "Please [Enter] > " DUMMY_READ
	fi
}

