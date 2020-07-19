# ==============================================================================
#  攻撃対策
#  ステルススキャン対策
# ==============================================================================
iptables -N STEALTH_SCAN
iptables -A STEALTH_SCAN -j LOG --log-prefix 'stealth_scan_attack: ' -m limit --limit 1/s --limit-burst 10
iptables -A STEALTH_SCAN -j DROP

iptables -A INPUT -p tcp --tcp-flags ACK,FIN FIN                                -j STEALTH_SCAN
iptables -A INPUT -p tcp --tcp-flags ACK,PSH PSH                                -j STEALTH_SCAN
iptables -A INPUT -p tcp --tcp-flags ACK,URG URG                                -j STEALTH_SCAN
iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST                            -j STEALTH_SCAN
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN                            -j STEALTH_SCAN
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST                            -j STEALTH_SCAN
iptables -A INPUT -p tcp --tcp-flags ALL NONE                                   -j STEALTH_SCAN
iptables -A INPUT -p tcp --tcp-flags ALL ALL                                    -j STEALTH_SCAN
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG                    -j STEALTH_SCAN
iptables -A INPUT -p tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW       -j STEALTH_SCAN

