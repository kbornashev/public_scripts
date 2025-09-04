#!/usr/bin/env bash
file="am.list"
lines=$(cat $file)
for line in $lines
do
  echo $line
        #bash ghost $line
				#ssh optiroot@$line -- sudo grep 'jenkins-master' /home/jenkins/.ssh/authorized_keys 
#				ssh optiroot@$line -- sudo tee -a /home/jenkins/.ssh/authorized_keys > /dev/null << EOF 
#ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8UwjVSS8uZdlbGgEWA8P5YLhuD1lFD0S0YuHeELRHKgJYS/vvgR/1/9eqZpt1ccGMJyVwjXV1hH1qNmUxkj9WlXrOgFl5G76KnwgG/4+c0jCav4Xu8jrSXtN+DX6hfKzQ6UL+v+KAtPsjMBcq3PIdXsVKwWlI5tW4PSCjVLWAaffs44RcpRynzUxm1+81sNvtMloofPCiSes6sVghohz4dVu4aSR5ogI5X1qIM7BvSSxbmW4zwfS2/OpOgRLdllA/N9iTLb/uUtwzZMSvNIootJkIqiQY0Zw3fn7lMPrDp0GvjNV4zLYj6Ni5Utq377WUekcehcYEs5BEF2MXH4VRIobKYzW1crsGJufJ8GhgZ9ilWufoRyjqeehjHx9Fa6Iq4u9mHncuq4xnt0Iu964B4dhNTUQWZ1s/tfOM5l4+N9p5lFetSVVA9/WCShfayH0axH6KDN3cfW0sQUWWe4/yFj4jnlPcTYwgcdf/5AIU4Y3dhMN9PzHgBEt9eMY89FE= jenkins@c001-vm207-mw-jenkins-master
#EOF
#				ssh optiroot@$line -- sudo grep '^PasswordAuthentication' /etc/ssh/sshd_config
#				ssh optiroot@$line -- sudo systemctl restart sshd
ssh optiroot@$line -- cat ~/.ssh/authorized_keys | grep i.smolko
#ssh $line -- sudo tee -a /home/optiroot/.ssh/authorized_keys > /dev/null << EOF
#
## aegorov
#ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDig2QahNAFK75quDzF6vPwO6JeabxLXJwWCYNqgC75nip+bu8kQWY+N5hLIQmbDhf9c5gK+44xSLdUeYYtI7kPL50A8vgt7zoZ+oC9ghYtdZ8AAY69Mc5o17wH2V5kjKXs7WmVYeAHNl4lZzkcwLR7PWIgE8JDiNhdkZ0sDtxgMExcsOHL3Lntv/UjAeBMs7TFf9nlwURKmgPz0AZWLOgRMaibi6cTIlbao/7TfUtqCYHHTbfIyIP7CCTJdSKfJAtpP9S99FkNhjkUHfy852QvaDSxsmzWieIYMvfwAl6EZ5A31QiH4UeNdJF4+II/1E02wiQKzeFuTLIbuCGkA2gwCPGYwR0hUmjyeZAET42//Gf2l0ltKt9e2BVhiWI7moCMKquyZJ1gytc5SB/ZL5B+haA4WL285sRXWUO4Nawo46vRJ0OJKkLibvYoyIVs2R4OO3wR/luVHsU5Aatl9X45vbgm0UiH0dbpnjdvgdNvcp0rzGllG3mHu9DRAIqz+SQ6xxU7OeFlg8Jrj5eDymcBYC783uJvprWCMMqrUUcMEfEbHe5AcBHgOEGrIStxZ9OhNMeXZSleUf6AjrzGgE+ryGak0Hg/cpauQReZYXaMEfEhkk96mW2cU6QfbtSgAD+PyDnmN0/EKohb4qAoowaXNDCdG3FNwc82s00mieUWbQ== a.egorov@optimacros.com
EOF
done
