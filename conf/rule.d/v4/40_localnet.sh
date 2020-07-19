# SSH 以外のアクセス許可
# ローカルネット, 信頼できるIPアドレスリストからアクセスされた場合の許可

#
# プロキシサーバーへのアクセスを許可
#
/sbin/iptables -A INPUT -p tcp --dport 3128 -m set --match-set localnet-list src -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 3128 -m set --match-set trasted-list  src -j ACCEPT

