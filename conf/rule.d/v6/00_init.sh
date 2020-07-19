# ==============================================================================
#  iptables 設定クリア
# ==============================================================================
function clear_ip6tables()
{
	for chain in INPUT FORWARD OUTPUT
	do
	    /sbin/ip6tables -P $chain ACCEPT
	done
	for param in F Z X; do /sbin/ip6tables -$param; done
	for table in $(cat /proc/net/ip6_tables_names)
	do
	    /sbin/ip6tables -t $table -F # テーブル初期化
	    /sbin/ip6tables -t $table -Z # パケットカウンタクリア
	    /sbin/ip6tables -t $table -X # チェーン削除
	done
}


# ==============================================================================
#  最低限の通信確保の設定
# ==============================================================================
function init_ip6tables()
{
	# ループバックはすべて許可する。
	/sbin/ip6tables -A INPUT -i lo -j ACCEPT

	# --------------------------------------------------------------------------
	#  ポリシー設定
	# --------------------------------------------------------------------------
	/sbin/ip6tables -P INPUT		DROP
	/sbin/ip6tables -P FORWARD	DROP
	/sbin/ip6tables -P OUTPUT	ACCEPT

}


# iptables クリア
clear_ip6tables

# 初期設定
init_ip6tables

