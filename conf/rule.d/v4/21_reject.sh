# ==============================================================================
#  レスポンス低下防止
# ==============================================================================
#  外部に対してサービスを提供しないポートは、基本的に DROP するべきである。
#  しかし、IDENT/AUTH (Port 113) など、応答性能を高めるために、
#  REJECT 設定するものを以下に記載する。
#
#  IDENT/AUTH:
#    接続元クライアント確認のため、サーバーがクライアントの Port 113 に接続する。
#    Eメールサーバーなどで利用されることがあるが、クライアントが応答を返さなくとも
#    処理が継続されることが多い。
#    しかし、DROP 設定していると、サーバーは Timeout 発生まで処理を待機するため、
#    メールの処理が遅くなったりする。
#    => REJECT を返すことで、サーバーはすぐに応答が得られないことを認識でき、
#   レスポンス低下を防止することが可能である。
#
iptables -A INPUT -p tcp --dport 113 -j REJECT --reject-with tcp-reset

