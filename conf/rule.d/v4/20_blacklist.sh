# ==============================================================================
#  ブラックリスト拒否設定
# ==============================================================================
iptables -N BLACKLIST
iptables -A BLACKLIST -j LOG --log-prefix 'blacklist: '
iptables -A BLACKLIST -j DROP

ACCEPT_COUNTER=$(/sbin/iptables -L | grep "^ACCEPT" | wc -l)
if [ ${ACCEPT_COUNTER} -lt 5 ]; then
	echo "iptables が初期化されていません。"
	exit 1
fi

BLACK_LIST=`/sbin/ipset list | grep "^Name: black-list" | awk '{print $2}'`
for list in ${BLACK_LIST}; do
	# ブラックリストはすべて BLACKLIST へ
	/sbin/iptables -A INPUT -m set --match-set ${list} src -j BLACKLIST
done

