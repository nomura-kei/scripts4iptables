# ==============================================================================
#  攻撃対策
#  SYN_FLOOD 対策
# ==============================================================================
iptables -N SYN_FLOOD
iptables -A SYN_FLOOD -p tcp --syn              \
        -m hashlimit                            \
        --hashlimit 200/s                       \
        --hashlimit-burst 3                     \
        --hashlimit-htable-expire 300000        \
        --hashlimit-mode srcip                  \
        --hashlimit-name t_SYN_FLOOD            \
        -j RETURN
iptables -A SYN_FLOOD -j LOG --log-prefix 'syn_flood_attack: '
iptables -A SYN_FLOOD -j DROP
iptables -A INPUT -p tcp --syn -j SYN_FLOOD

