# ==============================================================================
#  公開サーバー設定 (全体に公開するサーバー)
# ==============================================================================

# HTTPS 公開
iptables -A INPUT -p tcp --dport 80  -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
