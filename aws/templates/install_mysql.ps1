New-NetFirewallRule -DisplayName \"Habitat TCP\" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9631,9638
New-NetFirewallRule -DisplayName \"Habitat UDP\" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9638

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

C:/ProgramData/chocolatey/choco install habitat -y --no-progress
C:/ProgramData/chocolatey/choco install powershell-core -y

hab pkg install core/windows-service
hab pkg exec core/windows-service install

mv -force c:\HabService.exe.config c:\hab\svc\windows-service\
start-service habitat

start-sleep -s 15

create-item -type directory c:\hab\svc\mysql
cp c:\mysql_user.toml c:\hab\svc\mysql\user.toml

$env:HAB_AUTH_TOKEN = '${hab_auth_token}'

hab svc load ${origin}/mysql --channel ${release_channel} --strategy at-once
