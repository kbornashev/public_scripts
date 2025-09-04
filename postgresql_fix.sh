#!/bin/bash
WS_HOME=/om/workspace1
pg_conf=/etc/postgresql/13/main/postgresql.conf
pg_hba=/etc/postgresql/13/main/pg_hba.conf
cd $WS_HOME/container
vagrant ssh -t -- << EOF
sudo su
if grep 'listen_addresses' $pg_conf
then
	sed -i '/listen_addresses/s/127.0.0.1/0.0.0.0/' $pg_conf
else
	sed -i "/^port\s=/i listen_addresses = '0.0.0.0'" $pg_conf
fi
sed -i '/^host\s*all\s*all\s*127.0.0.1/ {p;s/127.0.0.1/10.0.3.1/}' $pg_hba
sed -i '/^host\s*replication\s*all\s*127.0.0.1/ {p;s/127.0.0.1/10.0.3.1/}' $pg_hba
systemctl restart postgresql
EOF
