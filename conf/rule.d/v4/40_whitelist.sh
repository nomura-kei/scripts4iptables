CONNECTING_PORT=$(ss --tcp -n -p | grep sshd | awk '{print $4}' | sed -n -e 's/^.*\:\([0-9]\+\)$/\1/p' | head -n 1)
if [ "${CONNECTING_PORT}" = "" ]; then
	echo "ホワイトリストからの ssh 接続許可設定に失敗しました。"
	exit 1
fi

WHITE_LIST=`/sbin/ipset list | grep "^Name: white-list" | awk '{print $2}'`
for list in ${WHITE_LIST}; do
	# ホワイトリストからのSSHアクセスを許可する。
	/sbin/iptables -A INPUT -p tcp --dport ${CONNECTING_PORT} -m set --match-set ${list} src -j ACCEPT
done

