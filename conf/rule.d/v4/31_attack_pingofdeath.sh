# ==============================================================================
#  攻撃対策
#  PING OF DEATH 対策
# ==============================================================================
iptables -N PING_OF_DEATH
iptables -A PING_OF_DEATH -p icmp --icmp-type echo-request \
        -m hashlimit                            \
        --hashlimit 1/s                         \
        --hashlimit-burst 10                    \
        --hashlimit-htable-expire 300000        \
        --hashlimit-mode srcip                  \
        --hashlimit-name t_PINT_OF_DEATH        \
        -j RETURN
iptables -A PING_OF_DEATH -j LOG --log-prefix 'ping_of_death_attack: '
iptables -A PING_OF_DEATH -j DROP
iptables -A INPUT -p icmp --icmp-type echo-request -j PING_OF_DEATH

