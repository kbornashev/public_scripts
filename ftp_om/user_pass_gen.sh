#!/usr/bin/bash
domain='olapsoft_om'
c=10
i=1
while [ "$c" -ge "$i" ]
do
  echo user${i}
  PASS=$(echo -n 'letmein' | ansible-vault encrypt_string --vault-id /home/bo/om/.vault_pass.txt --stdin-name $( pwgen -c 16 1 ))
 cat << EOF >> ${domain}_${c}users.txt
   ftp_containers:
    - id: $i
      present: true
      quote: '50G'
      address: "10.10.3.254"
      port: $(expr 3000 + $i)
      connections: 50
      user: 'ftpuser'
      password: $PASS
      tls: 1
      crt_domain: '${domain}'
EOF
((i++))
done
