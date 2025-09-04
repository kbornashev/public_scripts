set filename "/home/bo/om/ssh_keys.txt"
set file [open $filename r]
while {[gets $file line] != -1} {
  puts $line
}
close $file
