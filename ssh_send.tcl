#!/usr/bin/tclsh
if {$argc != 2} {
    puts "Usage: $argv0 {user1,user2,user3} {host1,host2,host3,host4}"
    exit 1
}
set users [lindex $argv 0]
set hosts [lindex $argv 1]
set user_list [split [string map {" " ""} $users] ","]
set host_list [split [string map {" " ""} $hosts] ","]
set keys_file "/home/bo/om/ssh_keys.txt"
set fh [open $keys_file r]
set keys_data [read $fh]
close $fh
set keys_lines [split $keys_data "\n"]
foreach user $user_list {
    foreach host $host_list {
        set ssh_command "ssh -o StrictHostKeyChecking=no $user@$host 'echo \"$keys_data\" >> ~/.ssh/authorized_keys'"
        
        set check_command "ssh -o StrictHostKeyChecking=no $user@$host 'grep \"$user\" ~/.ssh/authorized_keys'"
        set result [exec $check_command]
        if {[string length $result] > 0} {
            puts "Ключ пользователя $user уже существует на хосте $host"
        } else {
            set result [exec $ssh_command]
            if {$result eq ""} {
                puts "Ключ пользователя $user успешно добавлен на хост $host"
            } else {
                puts "Ошибка при добавлении ключа пользователя $user на хост $host: $result"
            }
        }
    }
}
