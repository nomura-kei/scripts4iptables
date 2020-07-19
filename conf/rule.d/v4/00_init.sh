SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
SCRIPT_FILE=${SCRIPT_DIR}/$(basename ${BASH_SOURCE:-$0})
# ==============================================================================
#  接続中の SSH の情報
#  SSHD_REMOTE_IP : 接続元のIPアドレス
#  SSHD_PORT      : SSH のポート
# ==============================================================================
SSHD_REMOTE_IP=$(who -m | sed -e 's/^.*(\(.*\))$/\1\/32/')
SSHD_PORT=$(ss --tcp -n -p | grep sshd | awk '{print $4}' | sed -n -e 's/^.*\:\([0-9]\+\)$/\1/p' | head -n 1)



# ==============================================================================
#  iptables 設定クリア
# ==============================================================================
function clear_iptables()
{
	for chain in INPUT FORWARD OUTPUT
	do
	    /sbin/iptables -P $chain ACCEPT
	done
	for param in F Z X; do /sbin/iptables -$param; done
	for table in $(cat /proc/net/ip_tables_names)
	do
	    /sbin/iptables -t $table -F # テーブル初期化
	    /sbin/iptables -t $table -Z # パケットカウンタクリア
	    /sbin/iptables -t $table -X # チェーン削除
	done
}


# ==============================================================================
#  最低限の通信確保の設定
# ==============================================================================
function init_iptables()
{
	# ループバックはすべて許可する。
	/sbin/iptables -A INPUT -i lo -j ACCEPT


	# 現在接続中の SSH 通信を確保する。
	if [ "${SSHD_REMOTE_IP}" = "" ] || [ "${SSHD_PORT}" = "" ]; then
		echo "接続中の ssh 接続許可設定に失敗しました。"
		echo "ssh で接続していない端末より設定する場合は、"
		echo "${SCRIPT_FILE} の SSHD_REMOTE_IP と、SSHD_PORT を適宜修正してください。"
		exit 1
	fi
	/sbin/iptables -A INPUT -s ${SSHD_REMOTE_IP} -p tcp --dport ${SSHD_PORT} -j ACCEPT

	# localnet-list, trasted-list からの ICMP と SSH 通信を許可する。
	/sbin/iptables -A INPUT -p icmp -m set --match-set localnet-list src -j ACCEPT
	/sbin/iptables -A INPUT -p icmp -m set --match-set trasted-list  src -j ACCEPT
	/sbin/iptables -A INPUT -p tcp --dport ${SSHD_PORT} -m set --match-set localnet-list src -j ACCEPT
	/sbin/iptables -A INPUT -p tcp --dport ${SSHD_PORT} -m set --match-set trasted-list  src -j ACCEPT

	# 接続確立後の応答は許可する。
	/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

	# IGMP パケットを許可する。
	/sbin/iptables -A INPUT -d 224.0.0.1/32 -p igmp -j ACCEPT

	# --------------------------------------------------------------------------
	#  ポリシー設定
	# --------------------------------------------------------------------------
	/sbin/iptables -P INPUT		DROP
	/sbin/iptables -P FORWARD	DROP
	/sbin/iptables -P OUTPUT	ACCEPT

}


# iptables クリア
clear_iptables

# 信頼できるアドレスからの SSH 接続のみを許可
echo "信頼できるアドレスからの SSH 接続のみ許可します。"
trap 'clear_iptables' 1 2 3 15
init_iptables

IS_LOGGINED=ng
echo "-------------------------------------------------------------------"
echo " SSH 締め出し防止"
echo "-------------------------------------------------------------------"
echo " 他の端末より、30秒以内に SSH ログインできることを確認して下さい。"
read -t 30 -p " ログインできれば、ok[Enter] を入力ください > " IS_LOGGINED

if [ "${IS_LOGGINED}" != "ok" ]; then
	# 設定情報をクリアして元に戻す。
	clear_iptables
	echo ""
	echo "iptables の設定をキャンセル (クリア) しました。"
	echo ""
	exit 1
fi


