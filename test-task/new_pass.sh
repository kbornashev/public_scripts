archive_dir=/home/bo/om/test-task-archives
archive_name="om-test-task"
archive=${archive_dir}/${archive_name}
password_old="AveOptimacros2016"
while [[ $
  case $1 in
    -h|--help)
      echo "-all | -a  changing all archives "
      echo "-v         arrays of archives like: -v 001 002 003 004 "
  	  shift
    	;;
    --all|-a)
      archive_num=({001..010})
      shift
      ;;
    -v)
      shift
      archive_num=( "$@" )
      break
      ;;
  esac
done
for target in "${archive_num[@]}";
do
  echo $target;
  rm $archive_dir/ovpn/hr-org_test.user.${target}_hr-vpn-server.ovpn
  unzip $archive_dir/ovpn_zip/hr-org_test.user.${target}.zip -d $archive_dir/ovpn
  cp $archive_dir/ovpn/hr-org_test.user.${target}_hr-vpn-server.ovpn $archive_dir/om-test-task-${target}/;
  password=$(pwgen -c 10 1);
  ssh optiroot@$(awk '/Linux ssh/{print $3}' $archive_dir/om-test-task-${target}/'RDP + SSH.txt') -- passwd optiroot << EOF
${password_old}
${password}
${password}
EOF
if [[ $? -ne 0 ]]
then
      password_old=$(awk '/Password/ {a=$0} END{print $2}' $archive_dir/om-test-task-${target}/'RDP + SSH.txt';)
      ssh optiroot@$(awk '/Linux ssh/{print $3}' $archive_dir/om-test-task-${target}/'RDP + SSH.txt') -- passwd optiroot << EOF
${password_old}
${password}
${password}
EOF
fi
  if [[ $? -eq 0 ]]
  then
    sed -i "$ s/\(Password:\)\s\(.*\)$/\1 ${password}/" $archive_dir/om-test-task-${target}/'RDP + SSH.txt';
  fi
  if [[ -f $archive_dir/fresh/om-test-task-${target}.zip ]]
  then 
    rm -r $archive_dir/fresh/om-test-task-${target}.zip;
  fi
  zip -jr $archive_dir/fresh/om-test-task-${target}.zip $archive_dir/om-test-task-${target}/;
done
