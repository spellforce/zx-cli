#!/usr/bin/expect
set user "1243236087@qq.com"
set password "Zx3209231994"
set path "/apps/prod/uop"
set uoEnv [lindex $argv 1]
set timeout 60

if {$uoEnv=="prod"} {
  $path="/apps/prod/uop"
  exit
}
  
spawn ssh -i ~/gridx_work/pems/xin.pem -p2222 xin@jms.internal.gridx.com
expect "Opt>"
send "p\r"
expect "Opt>"
send "1\r"
expect "xin@ui-prod-08 ~"
send "sudo su\r"
expect "root@ui-prod-08 xin"
send "cd $path\r"
expect "root@ui-prod-08 uop"
send "git pull\r"
expect "Username*"
send "$user\r"
expect "Password*"
send "$password\r"
expect "root@ui-prod-08 uop"
send "cd ./server\r"
expect "root@ui-prod-08 server"
send "./deploy.sh\r"
interact