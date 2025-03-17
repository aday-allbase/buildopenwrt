#!/bin/sh

uci batch <<EOF
set system.@system[0].hostname='OPENWRT'
set system.@system[0].timezone='Asia/Jakarta'
set system.@system[0].zonename='Asia/Jakarta'
commit system

EOF

uci commit

/etc/init.d/system restart

exit 0