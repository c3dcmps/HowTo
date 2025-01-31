﻿# AutoHarden - A simple script that automates Windows Hardening
#
# Filename: AutoHarden.ps1
# Author: 1mm0rt41PC - immortal-pc.info - https://github.com/1mm0rt41PC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING. If not, write to the
# Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# Update: 2021-04-11
$AutoHarden_version="2021-04-11"
$global:AutoHarden_boradcastMsg=$true
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
Add-Type -AssemblyName System.Windows.Forms
function ask( $query, $config ){
	$config="C:\Windows\AutoHarden\${config}";
	$ret=cat $config -ErrorAction Ignore;
	Write-Host "# ASK..."
	try{
		if( "$ret" -eq "Yes" -Or ([string]::IsNullOrEmpty($ret) -And [System.Windows.Forms.MessageBox]::Show("${query}?","${query}?", "YesNo" , "Question" ) -eq "Yes") ){
			[System.IO.File]::WriteAllLines($config, "Yes", (New-Object System.Text.UTF8Encoding $False));
			Write-Host "# ASK... => YES!"
			return $true;
		}else{
			Write-Host "# ASK... => NO :-("
			[System.IO.File]::WriteAllLines($config, "No", (New-Object System.Text.UTF8Encoding $False));
			return $false;
		}
	}catch{
		if( $global:AutoHarden_boradcastMsg ) {
			$global:AutoHarden_boradcastMsg=$false
			msg * "An update of AutoHarden require an action from the administrator. Please run C:\Windows\AutoHarden\AutoHarden.ps1"
		}
		return $false;
	}
}
if( ![bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") ){  Write-Host -BackgroundColor Red -ForegroundColor White "Administrator privileges required ! This terminal has not admin priv. This script ends now !"; pause;exit;}
mkdir C:\Windows\AutoHarden\ -Force -ErrorAction Ignore
$AutoHardenLog = "C:\Windows\AutoHarden\Activities_"+(Get-Date -Format "yyyy-MM-dd")+".log"
Start-Transcript -Force -IncludeInvocationHeader -Append ($AutoHardenLog)
$DebugPreference = "Continue"
$VerbosePreference = "Continue"
$InformationPreference = "Continue"

echo "####################################################################################################"
echo "# Install AutoHarden Cert"
echo "####################################################################################################"
if( ask "Auto update AutoHarden and execute AutoHarden every day at 08h00 AM" "0-AutoUpdate.ask" ){
	$AutoHardenCert = "${env:temp}\"+[System.IO.Path]::GetRandomFileName()+".cer"
	[IO.File]::WriteAllBytes($AutoHardenCert, [Convert]::FromBase64String("MIIFGTCCAwGgAwIBAgIQobvWmnCC3YBAuYu4RT1skTANBgkqhkiG9w0BAQ0FADAYMRYwFAYDVQQDEw1BdXRvSGFyZGVuLUNBMB4XDTIxMDQxMTA4MjUxMFoXDTM5MTIzMTIzNTk1OVowFTETMBEGA1UEAxMKQXV0b0hhcmRlbjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAM5nLYR2Ew4oDqcFdR28IbrdUcIvbv/DL0axHD+8t27lVLfuQypSyuize0CdpkV3LlwPwvAf5jPE6ohF/bGiXWAbSk4azdIQmdC/MVUzxPFLT+yr32hiSLVs2nVm1HR30/vZeFdlllxuMaZvTfhZqVf4gJ5zYMUCRPG93HgW4oW6d137p982SadkdFaN6pOhLiUNH1gAPdbeRMngTnt5PzUFCyjx6n+mQ3sPNjMu4/FXfYAb2DIP/eAeiktOXZPwcSAbE35YV6vptT9AdhRu/44NcXOT9ftgq+MV1Aw4m6JWn2Z6aA7do2zHbW97HNCt0PUfreiKcUCb/nDqoN/0Uk9NdvjcplLb6ccuLN05YYF9uOmLT82XDaG8utGntH6X7V0Ldg5VQ7Pg3yFA3ahcRddcf525KQ+mJEdSgpYnWQ5+j++UUhVo2YijRmRWNkFSGgV9rCItGSiwBM5jhcVXq0A/Pul7g9Rij7eBOap1GFzSXzy9dLzRwC1zDMEh4Z1GoWA0vhb4NOa0/ISG7KZXUWq2MpXD2dMiakQTqmVnbMsCFN3/CbbPZt4GQfnfjo3y85eeBDcdXPStZoGtSjBbq0GKrHao1b8e98R1mVzsBOOtrppSdHzjMWcpJr+H1Q2SBYCeF5AjH1sJ9b7wHmJghujyBQ87sG3Le1grKXLy1jExAgMBAAGjYjBgMBMGA1UdJQQMMAoGCCsGAQUFBwMDMEkGA1UdAQRCMECAEOYDPlhk+/8GHZ4Uje3mOiehGjAYMRYwFAYDVQQDEw1BdXRvSGFyZGVuLUNBghD1NmqDy5ZuqE1inZr6g+JZMA0GCSqGSIb3DQEBDQUAA4ICAQBwStpDuIjnwHNcXCnkx4MYdYoOiDYiS62YhuVAfb1n1iDTzUF0v2s3pC0btVER8NuLdZmf9lk83VLqKV3PtXAELK3a4liMB5ODSpYdBrSLZjW393zyRC0GBu4DUQMVvFmkkKDFLjvxo3Y665nv1bW5GG/TP/BbSOFxGnRjGz+8citQ7uF68Db33rf6VBEuKBTRFpS6ck5yAAlqvi/j0VZjb4jLspsD5egY2t4U0UmQetUXnw6gGM9QhwwACElMeQKtc6+EwY8Nk+aq4EIt5lReG8Yjz/TY7/AYZHfQJPzYoOBSuAFfkFoFOkXvW9STAcQrt9uJLJg7YavKRTIVZMCgMk/Cir72LDyVHZU2WHUCHFURfqNT7Rv+4gsnEhpGeuDT0emwZK5eQswfp3/6VEOzTcZ5TIypTeftmg1Xl8Raz6+LWGOc4RaFRCr9k7rk7+w4IAiGRxbeBZ+2aH+/PYoyEWXb0loKsglZQ0muTEUiRCXTFth4kZ0xzp1BSs32owYs+LF8TmvuGdQvRENsw4Wzp5jjs9XMh87Gq52aj5lo2UuWExXDrPwcD8nZ819bdUufHmPZV7fF1kayuXthj1EsUbGcQwurIdD2xPtG1XylIdL2oE4Ae2jxITqECb259bC4h7o8K90qHZp1DStb6/bR/k/BMqVYkFEyxCmu7NteMw=="))
	Import-Certificate -Filepath $AutoHardenCert -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
	$AutoHardenCertCA = "${env:temp}\"+[System.IO.Path]::GetRandomFileName()+".cer"
	[IO.File]::WriteAllBytes($AutoHardenCertCA, [Convert]::FromBase64String("MIIFHDCCAwSgAwIBAgIQ9TZqg8uWbqhNYp2a+oPiWTANBgkqhkiG9w0BAQ0FADAYMRYwFAYDVQQDEw1BdXRvSGFyZGVuLUNBMB4XDTIxMDQxMTA4MjUwN1oXDTM5MTIzMTIzNTk1OVowGDEWMBQGA1UEAxMNQXV0b0hhcmRlbi1DQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAM66UuqdsAue5/iEHVTS2z2K8im3eMH0YHtzIF6vzK8aijCR9iHiR8hKm++qi0v0V6egGdoEVUNQF+jmSImBP6ivmMZyJ2kqFu0A/ULRa/bbpH8yNAVPMwP5vAaX35vtOOomYtuG0q5PqyeszfD+uQloebbQeQjDxGSTapRdWcZxLegEz6nQqjmIH93V869fuY+PPUHpgoDwwqql9RdHaS85s5pYosbRlmXidtOkM6Z4RkaSp0rpNpJ24sptqtscWkpIuEvZMunuH1+iwfDB1KzI5cucJnJRQsKw+cU3kOyrefp8ax90uk+2FkUPgbPnfxnFTsKlGQvmlhxp1FWXrK/9V94+nWIMxg04foeksqKH+83nqExSN7wNP+ZJpuOAVBYMUJFpUBSRTyVBoDHtsPkp+vZW2Gog13ymxgaTVohTOd4kXo64LbNwPzxMMPVYzz8DtSOML612Zt8Xl+GfmtMgoCGfTwc2jgTPjbN4E2wS2TSCjt1It375dVskK74izXr2Dfyh/qQwg9W8IWS9VDkeEm5D8WQUVdKSg+8IT1/AqsNiyqDD/sGLZxkF0sLjVuu9HxBJohegr2oQnke9/0vgvNOM0T2VycvBMu2YUTxfM88zX8JtCqmfu4zUJwlihumKax7N4NLVr8fA7KcCjZFSVhmJe7f09L5iSPUki9gpAgMBAAGjYjBgMBMGA1UdJQQMMAoGCCsGAQUFBwMDMEkGA1UdAQRCMECAEOYDPlhk+/8GHZ4Uje3mOiehGjAYMRYwFAYDVQQDEw1BdXRvSGFyZGVuLUNBghD1NmqDy5ZuqE1inZr6g+JZMA0GCSqGSIb3DQEBDQUAA4ICAQBNm4OTsxzQah3e2N5OPH2Jlyo+ruXPtZhVHJownr2+PpxVotnvNr2iCigPDOFgxwO1RDbVP3o105vNIb9c/v7NLzozulzy5ct5YnLvtX9JLZmVA2pJeYw90ZLX1qCm6p0C8RGwknzqbc/+pMLKLETOesbu6soom2GINA+dAvUJukpinTvgriTkkj9C2ayBH0lgqohLH/VoC6hIje61gW4NcuMz2dtjqki3d+4NPQCphueM1QN1EYus4HiY8bepJvqdUSy4IksoI0pTuu6G4Nv9vRMh5vwO9hfkOis7/tIphg/hIGdhP/TQZl3y5xWn/2w4MqxXMS8O+OdyRaa3OtLqe8i32W6rQjLrkJ3SM+BvIDz1ydobYKR9IljR1cDjifcUQ35je8jiimSol6eskjlGA6Z5ueHSHoiPDEX88A3Vee8C1Lh530HWZDvBD9/JrzeVnCqSUQSkwie42hoSP7g1Poiqw2wfcSoILW2C7YJimBehnqwtTbKRzb/AoE6Us16HwMxAFSgGy4H0cTCRy922biEZ3berSGNdOz+mHZdWbmOGpTwZLwjXYp2FTFvo8f/jpIx4qhVqHhfF1iglcl5bYE7xaiMa/M6pB0megbQaeqjUdG9ANECcMtSylmAwrQk3W/GgAFZR4BnOtB25J/UaLhF9ceRrvOz2TEDjw5tWyw=="))
	Import-Certificate -Filepath $AutoHardenCertCA -CertStoreLocation Cert:\LocalMachine\AuthRoot
}


echo "####################################################################################################"
echo "# 0-AutoUpdate"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "0-AutoUpdate" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running 0-AutoUpdate"
if( ask "Execute AutoHarden every day at 08h00 AM" "0-AutoUpdate.ask" ){
$Trigger = New-ScheduledTaskTrigger -At 08:00am -Daily
#$Action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-exec AllSigned -nop -File C:\Windows\AutoHarden\AutoHarden.ps1 > C:\Windows\AutoHarden\ScheduledTask.log"
$Action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-exec ByPass -nop -File C:\Windows\AutoHarden\AutoHarden.ps1 > C:\Windows\AutoHarden\ScheduledTask.log"
$Setting = New-ScheduledTaskSettingsSet -RestartOnIdle -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)
Register-ScheduledTask -TaskName "AutoHarden" -Trigger $Trigger -User "NT AUTHORITY\SYSTEM" -Action $Action -RunLevel Highest -Settings $Setting -Force
if( ask "Auto update AutoHarden every day at 08h00 AM" "0-AutoUpdateFromWeb.ask" ){
	Get-NetFirewallRule -Name '*AutoHarden*Powershell*' | Disable-NetFirewallRule
	Invoke-WebRequest -Uri https://raw.githubusercontent.com/c3dcmps/HowTo/master/Harden/Windows/AutoHarden_RELEASE.ps1 -OutFile C:\Windows\AutoHarden\AutoHarden_temp.ps1
	Get-NetFirewallRule -Name '*AutoHarden*Powershell*' | Enable-NetFirewallRule
	if( (Get-AuthenticodeSignature C:\Windows\AutoHarden\AutoHarden_temp.ps1).Status -eq [System.Management.Automation.SignatureStatus]::Valid ){
		Write-Host "[*] The downloaded PS1 has a valid signature !"
		move -force C:\Windows\AutoHarden\AutoHarden_temp.ps1 C:\Windows\AutoHarden\AutoHarden.ps1
	}else{
		Write-Warning "[!] The downloaded PS1 has an invalid signature !"
	}
}
}
else{
Unregister-ScheduledTask -TaskName "AutoHarden" -Confirm:$False -ErrorAction SilentlyContinue
}
Write-Progress -Activity AutoHarden -Status "0-AutoUpdate" -Completed


echo "####################################################################################################"
echo "# 1-Hardening-Firewall"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "1-Hardening-Firewall" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running 1-Hardening-Firewall"
# Cleaning firewall rules
netsh advfirewall set AllProfiles state on
Set-NetFirewallProfile -DefaultInboundAction Block
Write-Host '[*] Cleaning old rules ...'
Get-NetFirewallRule | where { -not $_.Name.StartsWith("[AutoHarden-$AutoHarden_version]") -and -not $_.Name.StartsWith("[AutoHarden]") } | Remove-NetFirewallRule
Get-NetFirewallRule -Name '*AutoHarden*' | Enable-NetFirewallRule

# Ref: https://en.wikipedia.org/wiki/Reserved_IP_addresses
$IPForInternet=@('1.0.0.0-9.255.255.255',
'11.0.0.0-100.63.255.255',
'100.128.0.0-126.255.255.255',
'128.0.0.0-169.253.255.255',
'169.255.0.0-172.15.255.255',
'172.32.0.0-191.255.255.255',
'192.0.1.0-192.0.1.255',
'192.0.3.0-192.167.255.255',
'192.169.0.0-198.17.255.255',
'198.20.0.0-198.51.99.255',
'198.51.101.0-203.0.112.255',
'203.0.114.0-255.255.255.254')

function blockExe( $name, $exe, $group, [Parameter(Mandatory=$false)] $allowNonRoutableIP=$false ){
	get-item -ErrorAction Ignore $exe | foreach {
		$bin=$_.Fullname
		Write-Host "[*] Block $bin"
		if( $allowNonRoutableIP ){	
			New-NetFirewallRule -direction Outbound -Action Block -Program $bin -RemoteAddress $IPForInternet -Group "AutoHarden-$group" -Name ("[AutoHarden-$AutoHarden_version][Except Intranet] "+$name+" : "+$bin) -DisplayName ("[AutoHarden-$AutoHarden_version][Except Intranet] "+$name+" : "+$bin) -ErrorAction Ignore
		}else{
			New-NetFirewallRule -direction Outbound -Action Block -Program $bin -Group "AutoHarden-$group" -Name ("[AutoHarden-$AutoHarden_version] "+$name+" : "+$bin) -DisplayName ("[AutoHarden-$AutoHarden_version] "+$name+" : "+$bin) -ErrorAction Ignore
		}
	}
}

if( (ask "Block communication for evil tools ?" "block-communication-for-powershell,eviltools.ask") -eq $true ){
	blockExe "Powershell" "C:\Windows\WinSxS\*\powershell.exe" "LOLBAS" $true
	blockExe "Powershell" "C:\Windows\WinSxS\*\PowerShell_ISE.exe" "LOLBAS" $true
	blockExe "Powershell" "C:\Windows\*\WindowsPowerShell\v1.0\powershell.exe" "LOLBAS" $true
	blockExe "Powershell" "C:\Windows\*\WindowsPowerShell\v1.0\PowerShell_ISE.exe" "LOLBAS" $true
	
	blockExe "WScript" "C:\Windows\system32\wscript.exe" "LOLBAS" $true
	blockExe "CScript" "C:\Windows\system32\cscript.exe" "LOLBAS" $true
	blockExe "BitsAdmin" "C:\Windows\system32\BitsAdmin.exe" "LOLBAS" $true
	blockExe "Mshta" "C:\Windows\system32\mshta.exe" "LOLBAS" $true
	blockExe "CertUtil" "C:\Windows\System32\certutil.exe" "LOLBAS" $true
	blockExe "HH" "C:\Windows\*\hh.exe" "LOLBAS" $true
	blockExe "HH" "C:\Windows\hh.exe" "LOLBAS" $true
	blockExe "IEexec" "C:\Windows\Microsoft.NET\*\*\ieexec.exe" "LOLBAS" $true
	blockExe "Dfsvc" "C:\Windows\Microsoft.NET\*\*\Dfsvc.exe" "LOLBAS" $true
	blockExe "Presentationhost" "C:\Windows\System32\Presentationhost.exe" "LOLBAS" $true
	blockExe "Presentationhost" "C:\Windows\SysWOW64\Presentationhost.exe" "LOLBAS" $true
	blockExe "Intel Graphics Control Panel" "C:\Windows\System32\driverstore\filerepository\*\GfxDownloadWrapper.exe" "LOLBAS" $true
#	blockExe "Windows Defender" "C:\ProgramData\Microsoft\Windows Defender\platform\*\MpCmdRun.exe" "LOLBAS" $true# Fixed in the latest version of Defender
#	https://malware.news/t/a-deep-dive-into-rundll32-exe/43840
#	blockExe "Rundll32" "C:\Windows\System32\rundll32.exe" "LOLBAS" $true
}else{
	Get-NetFirewallRule -Group "AutoHarden-LOLBAS" | Remove-NetFirewallRule
}

if( (ask "Block communication for Word and Excel ?" "block-communication-for-excel,word.ask") -eq $true ){
	blockExe "Excel" "C:\Program Files*\Microsoft Office*\root\*\EXCEL.EXE" "Office" $true
	blockExe "Excel" "C:\Program Files*\Microsoft Office*\*\root\*\EXCEL.EXE" "Office" $true
	blockExe "Excel" "C:\Program Files*\Microsoft Office*\*\EXCEL.EXE" "Office" $true
	
	blockExe "Word" "C:\Program Files*\Microsoft Office*\root\*\winword.exe" "Office" $true
	blockExe "Word" "C:\Program Files*\Microsoft Office*\*\root\*\winword.exe" "Office" $true
	blockExe "Word" "C:\Program Files*\Microsoft Office*\*\winword.exe" "Office" $true
	
	blockExe "PowerPoint" "C:\Program Files*\Microsoft Office*\root\*\Powerpnt.exe" "Office" $true
	blockExe "PowerPoint" "C:\Program Files*\Microsoft Office*\*\root\*\Powerpnt.exe" "Office" $true
	blockExe "PowerPoint" "C:\Program Files*\Microsoft Office*\*\Powerpnt.exe" "Office" $true
	
	blockExe "Teams" "${env:localappdata}\Microsoft\Teams\*\Squirrel.exe" "Office" $true
	blockExe "Teams" "${env:localappdata}\Microsoft\Teams\update.exe" "Office" $true
}else{
	Get-NetFirewallRule -Name '*AutoHarden*Excel*' | Remove-NetFirewallRule
	Get-NetFirewallRule -Name '*AutoHarden*Word*' | Remove-NetFirewallRule
	Get-NetFirewallRule -Name '*AutoHarden*PowerPoint*' | Remove-NetFirewallRule
	Get-NetFirewallRule -Name '*AutoHarden*Teams*' | Remove-NetFirewallRule
}

if( (ask "Block communication for InternetExplorer ?" "block-communication-for-InternetExplorer.ask") -eq $true ){
	blockExe "InternetExplorer" "C:\Program Files*\Internet Explorer\iexplore.exe" "InternetExplorer" $true
}else{
	Get-NetFirewallRule -Name '*AutoHarden*InternetExplorer*' | Remove-NetFirewallRule
}

if( (Get-Item "C:\Program Files*\Nmap\nmap.exe") -ne $null ){
	if( (ask "Allow NMAP to bypass the local firewall ?" "Allow-nmap.ask") -eq $true ){
		$nmap = (Get-Item "C:\Program Files*\Nmap\nmap.exe").Fullname
		New-NetFirewallRule -direction Outbound -Action Allow -Program $nmap -Group "AutoHarden-NMap" -Name "[AutoHarden-$AutoHarden_version][OUT] NMAP bypass SNMP & co" -DisplayName "[AutoHarden-$AutoHarden_version][OUT] NMAP bypass SNMP & co" -ErrorAction Ignore
		New-NetFirewallRule -direction Inbound -Action Allow -Program $nmap -Group "AutoHarden-NMap" -Name "[AutoHarden-$AutoHarden_version][IN] NMAP bypass SNMP & co" -DisplayName "[AutoHarden-$AutoHarden_version][IN] NMAP bypass SNMP & co" -ErrorAction Ignore
	}else{
		Get-NetFirewallRule -Name '*AutoHarden*NMAP*' | Remove-NetFirewallRule
	}
}
if( (Get-Item "C:\Program Files*\VMware\*\vmnat.exe") -ne $null ){
	if( (ask "Allow VMWARE to bypass the local firewall ?" "Allow-vmware.ask") -eq $true ){
		$vmware = (Get-Item "C:\Program Files*\VMware\*\vmnat.exe").Fullname
		New-NetFirewallRule -direction Inbound -Action Allow -Program $vmware -Group "AutoHarden-VMWare" -Name "[AutoHarden-$AutoHarden_version][IN] VMWare bypass SNMP & co" -DisplayName "[AutoHarden-$AutoHarden_version][IN] VMWare bypass SNMP & co" -ErrorAction Ignore
		New-NetFirewallRule -direction Outbound -Action Allow -Program $vmware -Group "AutoHarden-VMWare" -Name "[AutoHarden-$AutoHarden_version][OUT] VMWare bypass SNMP & co" -DisplayName "[AutoHarden-$AutoHarden_version][OUT] VMWare bypass SNMP & co" -ErrorAction Ignore
	}else{
		Get-NetFirewallRule -Name '*AutoHarden*VMWare*' | Remove-NetFirewallRule
	}
}
New-NetFirewallRule -direction Outbound -Action Block -Protocol tcp -RemotePort 445 -RemoteAddress $IPForInternet -Group "AutoHarden-SMB" -Name ("[AutoHarden-$AutoHarden_version][Except Intranet] SMB") -DisplayName ("[AutoHarden-$AutoHarden_version][Except Intranet] SMB") -ErrorAction Ignore
# Note about 135/TCP => https://superuser.com/questions/669199/how-to-stop-listening-at-port-135/1012382#1012382
# Port 135/TCP can be killed in 100% of server and workstation if CreateObject("Excel.Application", RemoteMachine) is not used
Write-Progress -Activity AutoHarden -Status "1-Hardening-Firewall" -Completed


echo "####################################################################################################"
echo "# 2-Hardening-HardDriveEncryption"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "2-Hardening-HardDriveEncryption" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running 2-Hardening-HardDriveEncryption"
if( ask "Encrypt the HardDrive C:" "2-Hardening-HardDriveEncryption.ask" ){
# AES 256-bit 
reg add 'HKLM\SOFTWARE\Policies\Microsoft\FVE' /v EncryptionMethod  /t REG_DWORD /d 4 /f

try{
	(Get-BitLockerVolume -MountPoint 'C:').KeyProtector |foreach {
		Write-Host ("C: is protected with: "+$_.KeyProtectorType)
	}
	# Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -UsedSpaceOnly -TpmProtector -RecoveryKeyProtector -RecoveryKeyPath "C:\"
}catch{
	Enable-BitLocker -MountPoint 'C:' -EncryptionMethod Aes256 -UsedSpaceOnly -TpmProtector -ErrorAction Continue
	if( ((Get-BitLockerVolume -MountPoint 'C:').KeyProtector | where { $_.KeyProtectorType -eq "RecoveryPassword" }).Count -eq 0 ){
		Enable-BitLocker -MountPoint 'C:' -EncryptionMethod Aes256 -UsedSpaceOnly -RecoveryPasswordProtector -ErrorAction Continue
	}
	(Get-BitLockerVolume -MountPoint 'C:').KeyProtector | foreach {
		if( -not [string]::IsNullOrEmpty($_.RecoveryPassword) ){
			Add-Type -AssemblyName System.Windows.Forms
			[System.Windows.Forms.MessageBox]::Show("Please keep a note of this RecoveryPassword "+$_.RecoveryPassword);
		}
	}
}
}
else{
Disable-BitLocker -MountPoint 'C:'
manage-bde -off C:
}
Write-Progress -Activity AutoHarden -Status "2-Hardening-HardDriveEncryption" -Completed


echo "####################################################################################################"
echo "# Crapware-Cortana"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Crapware-Cortana" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Crapware-Cortana"
if( ask "Disable Cortana in Windows search bar" "Crapware-Cortana.ask" ){
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /t REG_DWORD /v AllowCortana /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Search" /t REG_DWORD /v AllowCortana /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /t REG_DWORD /v AllowSearchToUseLocation /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /t REG_DWORD /v AllowCortanaAboveLock /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /t REG_DWORD /v DisableWebSearch /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /t REG_DWORD /v ConnectedSearchUseWeb /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /t REG_DWORD /v BingSearchEnabled /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /t REG_DWORD /v PublishUserActivities /d 0 /f
# From: Fireice
# https://www.winhelponline.com/blog/disable-web-results-windows-10-start-menu/
reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /t REG_DWORD /v DisableSearchBoxSuggestions /d 1 /f
Get-appxpackage -allusers *Microsoft.549981C3F5F10* | Remove-AppxPackage
}
else{
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /t REG_DWORD /v AllowCortana /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Search" /t REG_DWORD /v AllowCortana /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /t REG_DWORD /v AllowSearchToUseLocation /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /t REG_DWORD /v AllowCortanaAboveLock /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /t REG_DWORD /v DisableWebSearch /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /t REG_DWORD /v ConnectedSearchUseWeb /d 1 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /t REG_DWORD /v BingSearchEnabled /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /t REG_DWORD /v PublishUserActivities /d 1 /f
reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /t REG_DWORD /v DisableSearchBoxSuggestions /d 0 /f
}
Write-Progress -Activity AutoHarden -Status "Crapware-Cortana" -Completed


echo "####################################################################################################"
echo "# Crapware-DisableTelemetry-and-ADS"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Crapware-DisableTelemetry-and-ADS" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Crapware-DisableTelemetry-and-ADS"
# Disable Windows telemetry
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v AITEnable /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v Start /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowDeviceNameInTelemetry /t REG_DWORD /d 0 /f
schtasks.exe /Change /TN "\Microsoft\Windows\Device Information\Device" /Disable

sc.exe stop DiagTrack
sc.exe config DiagTrack "start=" disabled
sc.exe stop dmwappushservice
sc.exe config dmwappushservice "start=" disabled

# Disable Wifi sense telemetry
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v AutoConnectAllowedOEM /t REG_DWORD /d 0 /f

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 0  /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f
# Disable “Suggested Apps” in Windows 10
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v OemPreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEverEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RemediationRequired /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContentEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338387Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338393Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-314563Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353698Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353694Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableTailoredExperiencesWithDiagnosticData /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CloudContent" /v DisableThirdPartySuggestions /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
# Disable notifications/ads in File Explorer
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSyncProviderNotifications /t REG_DWORD /d 0 /f

# Start Menu: Disable Bing Search Results
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 0 /f

# Privacy - Disable Microsoft Help feedback.
reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\Assistance\Client\1.0" /v "NoExplicitFeedback" /t REG_DWORD /d 1 /f
reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\Assistance\Client\1.0" /v "NoImplicitFeedback" /t REG_DWORD /d 1 /f
reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\Assistance\Client\1.0" /v "NoOnlineAssist" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoActiveHelp" /t REG_DWORD /d 1 /f

# Privacy - Disable feedback in Office.
reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\office\16.0\common\feedback" /v "enabled" /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\office\16.0\common\feedback" /v "includescreenshot" /t REG_DWORD /d 0 /f




#https://github.com/crazy-max/WindowsSpyBlocker/raw/master/data/hosts/spy.txt
Write-Progress -Activity AutoHarden -Status "Crapware-DisableTelemetry-and-ADS" -Completed


echo "####################################################################################################"
echo "# Crapware-Onedrive"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Crapware-Onedrive" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Crapware-Onedrive"
if( ask "Remove OneDrive" "Crapware-Onedrive.ask" ){
$x86="$env:SYSTEMROOT\System32\OneDriveSetup.exe"
$x64="$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
$onedriverPath = $false
if( [System.IO.File]::Exists($x86) ){
	$onedriverPath = "$x86"
}elseif( [System.IO.File]::Exists($x64) ){
	$onedriverPath = "$x64"
}
if( $onedriverPath ){
	taskkill /f /im OneDrive.exe >$null 2>&1
	# Suppression du fichier
	takeown /F "$onedriverPath" /A
	icacls "$onedriverPath" /grant:r Utilisateurs:F
	icacls "$onedriverPath" /grant:r Administrateurs:F
	Remove-Item -Recurse -Force "$onedriverPath" -ErrorAction SilentlyContinue
	
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:USERPROFILE\OneDrive"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:USERPROFILE\OneDrive"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:LOCALAPPDATA\Microsoft\OneDrive"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:PROGRAMDATA\Microsoft OneDrive"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:PROGRAMDATA\Microsoft OneDrive"
	echo "Removing OneDrive from the Explorer Side Panel."
	echo .
	reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >$null 2>&1
	reg delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >$null 2>&1
}
# Suppression du OneDrive de explorer
reg add 'HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f
reg add 'HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f

# Désactivation de OneDrive
reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\OneDrive' /v PreventNetworkTrafficPreUserSignIn /t REG_DWORD /d 1 /f
reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive' /v DisableFileSync /t REG_DWORD /d 1 /f
reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive' /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f
}
Write-Progress -Activity AutoHarden -Status "Crapware-Onedrive" -Completed


echo "####################################################################################################"
echo "# Crapware-RemoveUseLessSoftware"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Crapware-RemoveUseLessSoftware" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Crapware-RemoveUseLessSoftware"
Get-AppxPackage -Name king.com.CandyCrushSaga
Get-AppxPackage *3dbuilder* | Remove-AppxPackage
Get-AppxPackage *officehub* | Remove-AppxPackage
Get-AppxPackage *getstarted* | Remove-AppxPackage
Get-AppxPackage *zunemusic* | Remove-AppxPackage
Get-AppxPackage *bingfinance* | Remove-AppxPackage
Get-AppxPackage *zunevideo* | Remove-AppxPackage
Get-AppxPackage *people* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage *windowsphone* | Remove-AppxPackage
Get-AppxPackage *bingsports* | Remove-AppxPackage
Get-AppxPackage *xboxapp* | Remove-AppxPackage

if( (ask "Uninstall OneNote ?" "Uninstall-OneNote.ask") -eq $true ){
	Get-AppxPackage *onenote* | Remove-AppxPackage
}
if( (ask "Uninstall Skype ?" "Uninstall-Skype.ask") -eq $true ){
	Get-AppxPackage *skypeapp* | Remove-AppxPackage
}
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main /v AllowPrelaunch /d 0 /t REG_DWORD /f

# List: Get-AppxPackage
Write-Progress -Activity AutoHarden -Status "Crapware-RemoveUseLessSoftware" -Completed


echo "####################################################################################################"
echo "# Crapware-Windows10UpgradeOldFolder"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Crapware-Windows10UpgradeOldFolder" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Crapware-Windows10UpgradeOldFolder"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue 'C:\$Windows.~BT'
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue 'C:\Windows.old'
Write-Progress -Activity AutoHarden -Status "Crapware-Windows10UpgradeOldFolder" -Completed


echo "####################################################################################################"
echo "# Harden-DisableShortPath"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Harden-DisableShortPath" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Harden-DisableShortPath"
fsutil.exe 8dot3name set 1
Write-Progress -Activity AutoHarden -Status "Harden-DisableShortPath" -Completed


echo "####################################################################################################"
echo "# Harden-RDP-Credentials"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Harden-RDP-Credentials" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Harden-RDP-Credentials"
remove-item "HKCU:\Software\Microsoft\Terminal Server Client\Servers\*" -Force -Recurse
Write-Progress -Activity AutoHarden -Status "Harden-RDP-Credentials" -Completed


echo "####################################################################################################"
echo "# Harden-VMWareWorkstation"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Harden-VMWareWorkstation" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Harden-VMWareWorkstation"
# Disable VM Sharing (free the port 443/TCP)
sc.exe config VMwareHostd start= disabled
Write-Progress -Activity AutoHarden -Status "Harden-VMWareWorkstation" -Completed


echo "####################################################################################################"
echo "# Harden-VoiceControl"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Harden-VoiceControl" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Harden-VoiceControl"
if( ask "Disable voice control" "Harden-VoiceControl.ask" ){
reg add "HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /t REG_DWORD /v AgentActivationEnabled /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /t REG_DWORD /v AgentActivationOnLockScreenEnabled /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\InputPersonalization" /t REG_DWORD /v AllowInputPersonalization /d 0 /f
}
else{
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v AgentActivationEnabled /f
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v AgentActivationOnLockScreenEnabled /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\InputPersonalization" /v AllowInputPersonalization /f
}
Write-Progress -Activity AutoHarden -Status "Harden-VoiceControl" -Completed


echo "####################################################################################################"
echo "# Harden-WindowsDefender"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Harden-WindowsDefender" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Harden-WindowsDefender"
if( -not (ask "Disable WindowsDefender" "Optimiz-DisableDefender.ask") -and (ask "Harden Windows Defender" "Harden-WindowsDefender.ask") ){
	# From https://gist.github.com/decay88/5bd6b2c9ebf681324847e541ba1fb191
	# From https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/attack-surface-reduction
	################################################################################################################
	# Windows Defender Device Guard - Exploit Guard Policies (Windows 10 Only)
	# Enable ASR rules in Win10 ExploitGuard (>= 1709) to mitigate Office malspam
	# Blocks Office childprocs, Office proc injection, Office win32 api calls & executable content creation
	# Note these only work when Defender is your primary AV
	# Sources:
	# https://www.darkoperator.com/blog/2017/11/11/windows-defender-exploit-guard-asr-rules-for-office
	# https://www.darkoperator.com/blog/2017/11/8/windows-defender-exploit-guard-asr-obfuscated-script-rule
	# https://www.darkoperator.com/blog/2017/11/6/windows-defender-exploit-guard-asr-vbscriptjs-rule
	# https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-exploit-guard/enable-attack-surface-reduction
	# https://demo.wd.microsoft.com/Page/ASR2
	# https://www.powershellgallery.com/packages/WindowsDefender_InternalEvaluationSettings/1.2/Content/WindowsDefender_InternalEvaluationSettings.ps1
	# ---------------------
	#%programfiles%\"Windows Defender"\MpCmdRun.exe -RestoreDefaults
	#
	# Block Office applications from creating child processes
	Add-MpPreference -AttackSurfaceReductionRules_Ids D4F940AB-401B-4EFC-AADC-AD5F3C50688A -AttackSurfaceReductionRules_Actions Enabled
	#
	# Block Office applications from injecting code into other processes
	Add-MpPreference -AttackSurfaceReductionRules_Ids 75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84 -AttackSurfaceReductionRules_Actions Enabled
	#
	# Block Win32 API calls from Office macro
	Add-MpPreference -AttackSurfaceReductionRules_Ids 92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B -AttackSurfaceReductionRules_Actions Enabled
	#
	# Block Office applications from creating executable content
	Add-MpPreference -AttackSurfaceReductionRules_Ids 3B576869-A4EC-4529-8536-B80A7769E899 -AttackSurfaceReductionRules_Actions Enabled
	#
	# Block execution of potentially obfuscated scripts
	Add-MpPreference -AttackSurfaceReductionRules_Ids 5BEB7EFE-FD9A-4556-801D-275E5FFC04CC -AttackSurfaceReductionRules_Actions Enabled
	#
	# Block executable content from email client and webmail
	Add-MpPreference -AttackSurfaceReductionRules_Ids BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550 -AttackSurfaceReductionRules_Actions Enabled
	#
	# Block JavaScript or VBScript from launching downloaded executable content
	Add-MpPreference -AttackSurfaceReductionRules_Ids D3E037E1-3EB8-44C8-A917-57927947596D -AttackSurfaceReductionRules_Actions Enabled
	#
	# Block executable files from running unless they meet a prevalence, age, or trusted list criteria
	Add-MpPreference -AttackSurfaceReductionRules_Ids 01443614-cd74-433a-b99e-2ecdc07bfc25 -AttackSurfaceReductionRules_Actions Enabled
	#
	# Use advanced protection against ransomware
	Add-MpPreference -AttackSurfaceReductionRules_Ids C1DB55AB-C21A-4637-BB3F-A12568109D35 -AttackSurfaceReductionRules_Actions Enabled
	
	if( (Get-Item "C:\Program Files*\VMware\*\vmnat.exe") -eq $null ){
		# Block credential stealing from the Windows local security authority subsystem (lsass.exe)
		Add-MpPreference -AttackSurfaceReductionRules_Ids 9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2 -AttackSurfaceReductionRules_Actions Enabled
	}else{
		Remove-MpPreference -AttackSurfaceReductionRules_Ids 9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2
	}
	#
	# Block untrusted and unsigned processes that run from USB
	#A TEST#########Add-MpPreference -AttackSurfaceReductionRules_Ids B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4 -AttackSurfaceReductionRules_Actions Enabled
	#
	# Enable Controlled Folder
	#Set-MpPreference -EnableControlledFolderAccess Enabled
	#
	# Enable Cloud functionality of Windows Defender
	#A TEST#########Set-MpPreference -MAPSReporting Advanced
	#A TEST#########Set-MpPreference -SubmitSamplesConsent Always
	#
	# Enable Network protection
	# Enabled - Users will not be able to access malicious IP addresses and domains
	# Disable (Default) - The Network protection feature will not work. Users will not be blocked from accessing malicious domains
	# AuditMode - If a user visits a malicious IP address or domain, an event will be recorded in the Windows event log but the user will not be blocked from visiting the address.
	Set-MpPreference -EnableNetworkProtection Enabled 
	#
	################################################################################################################
	# Enable exploit protection (EMET on Windows 10)
	# Sources:
	# https://www.wilderssecurity.com/threads/process-mitigation-management-tool.393096/
	# https://blogs.windows.com/windowsexperience/2018/03/20/announcing-windows-server-vnext-ltsc-build-17623/
	# ---------------------
	Get-NetFirewallRule -Name '*AutoHarden*Powershell*' | Disable-NetFirewallRule
	Invoke-WebRequest -Uri https://demo.wd.microsoft.com/Content/ProcessMitigation.xml -OutFile $env:temp\ProcessMitigation.xml
	Get-NetFirewallRule -Name '*AutoHarden*Powershell*' | Enable-NetFirewallRule
	Set-ProcessMitigation -PolicyFilePath $env:temp\ProcessMitigation.xml
	rm $env:temp\ProcessMitigation.xml
}else{
	Remove-MpPreference -AttackSurfaceReductionRules_Ids 9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2 2>$null
	Remove-MpPreference -AttackSurfaceReductionRules_Ids D4F940AB-401B-4EFC-AADC-AD5F3C50688A 2>$null
	Remove-MpPreference -AttackSurfaceReductionRules_Ids 75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84 2>$null
	Remove-MpPreference -AttackSurfaceReductionRules_Ids 92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B 2>$null
	Remove-MpPreference -AttackSurfaceReductionRules_Ids 3B576869-A4EC-4529-8536-B80A7769E899 2>$null
	Remove-MpPreference -AttackSurfaceReductionRules_Ids 5BEB7EFE-FD9A-4556-801D-275E5FFC04CC 2>$null
	Remove-MpPreference -AttackSurfaceReductionRules_Ids BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550 2>$null
	Remove-MpPreference -AttackSurfaceReductionRules_Ids D3E037E1-3EB8-44C8-A917-57927947596D 2>$null
	Remove-MpPreference -AttackSurfaceReductionRules_Ids 01443614-cd74-433a-b99e-2ecdc07bfc25 2>$null
	Remove-MpPreference -AttackSurfaceReductionRules_Ids C1DB55AB-C21A-4637-BB3F-A12568109D35 2>$null
	Set-MpPreference -EnableNetworkProtection Disabled 2>$null
}
Write-Progress -Activity AutoHarden -Status "Harden-WindowsDefender" -Completed


echo "####################################################################################################"
echo "# Hardening-AccountRename"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-AccountRename" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-AccountRename"
if( ask "Invert the administrator and guest accounts" "Hardening-AccountRename.ask" ){
try{
if( (New-Object System.Security.Principal.NTAccount('Administrateur')).Translate([System.Security.Principal.SecurityIdentifier]).value.EndsWith('-500') ){
	Rename-LocalUser -Name Administrateur -NewName Adm
	Rename-LocalUser -Name Invité -NewName Administrateur
	Rename-LocalUser -Name Adm -NewName Invité
}
}catch{}
try{
if( (New-Object System.Security.Principal.NTAccount('Administrator')).Translate([System.Security.Principal.SecurityIdentifier]).value.EndsWith('-500') ){
	Rename-LocalUser -Name Administrator -NewName Adm
	Rename-LocalUser -Name Guest -NewName Administrator
	Rename-LocalUser -Name Adm -NewName Guest
}
}catch{}
}
else{
try{
if( (New-Object System.Security.Principal.NTAccount('Invité')).Translate([System.Security.Principal.SecurityIdentifier]).value.EndsWith('-500') ){
	Rename-LocalUser -Name Administrateur -NewName Adm
	Rename-LocalUser -Name Invité -NewName Administrateur
	Rename-LocalUser -Name Adm -NewName Invité
}
}catch{}
try{
if( (New-Object System.Security.Principal.NTAccount('Guest')).Translate([System.Security.Principal.SecurityIdentifier]).value.EndsWith('-500') ){
	Rename-LocalUser -Name Administrator -NewName Adm
	Rename-LocalUser -Name Guest -NewName Administrator
	Rename-LocalUser -Name Adm -NewName Guest
}
}catch{}
}
Write-Progress -Activity AutoHarden -Status "Hardening-AccountRename" -Completed


echo "####################################################################################################"
echo "# Hardening-BlockOutgoingSNMP"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-BlockOutgoingSNMP" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-BlockOutgoingSNMP"
if( ask "Disable SNMP communication (can break printers)" "Hardening-BlockOutgoingSNMP.ask" ){
New-NetFirewallRule -direction Outbound -Action Block -Protocol "TCP" -RemotePort "161" -Group AutoHarden-SNMP -Name "[AutoHarden-$AutoHarden_version] SNMP-TCP" -DisplayName "[AutoHarden-$AutoHarden_version] SNMP" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol "UDP" -RemotePort "161" -Group AutoHarden-SNMP -Name "[AutoHarden-$AutoHarden_version] SNMP-UDP" -DisplayName "[AutoHarden-$AutoHarden_version] SNMP" -ErrorAction Ignore
}
else{
Get-NetFirewallRule | where { $_.Name.StartsWith("[AutoHarden-$AutoHarden_version] SNMP") } | foreach { 
	echo ('Cleaning old rules '+$_.Name)
	$_ | Disable-NetFirewallRule
	$_ | Remove-NetFirewallRule
}
}
Write-Progress -Activity AutoHarden -Status "Hardening-BlockOutgoingSNMP" -Completed


echo "####################################################################################################"
echo "# Hardening-BlockUntrustedFonts"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-BlockUntrustedFonts" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-BlockUntrustedFonts"
# https://adsecurity.org/?p=3299
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" /v MitigationOptions /t REG_QWORD /d 0x2000000000000 /f
Write-Progress -Activity AutoHarden -Status "Hardening-BlockUntrustedFonts" -Completed


echo "####################################################################################################"
echo "# Hardening-DisableCABlueCoat"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DisableCABlueCoat" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DisableCABlueCoat"
# See http://blogs.msmvps.com/alunj/2016/05/26/untrusting-the-blue-coat-intermediate-ca-from-windows/
#Invoke-WebRequest -Uri "https://crt.sh/?id=19538258" -OutFile "${env:temp}/Hardening-DisableCABlueCoat.crt"
echo @'
-----BEGIN CERTIFICATE-----
MIIGTDCCBTSgAwIBAgIQUWMOvf4tj/x5cQN2PXVSwzANBgkqhkiG9w0BAQsFADCB
yjELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQL
ExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTowOAYDVQQLEzEoYykgMjAwNiBWZXJp
U2lnbiwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MUUwQwYDVQQDEzxW
ZXJpU2lnbiBDbGFzcyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0
aG9yaXR5IC0gRzUwHhcNMTUwOTI0MDAwMDAwWhcNMjUwOTIzMjM1OTU5WjCBhDEL
MAkGA1UEBhMCVVMxIDAeBgNVBAoTF0JsdWUgQ29hdCBTeXN0ZW1zLCBJbmMuMR8w
HQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMTIwMAYDVQQDEylCbHVlIENv
YXQgUHVibGljIFNlcnZpY2VzIEludGVybWVkaWF0ZSBDQTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAJ/Go2aR50MoHttT0E7g9bDUUzKomaIkCRy5gI8A
BRkAed7v1mKUk/tn7pKxOvYHnd8BG3iT+eQ2P1ha2oB+vymj4b35gOAcYQIEEYCO
vH35pSqRKlmflrI5RwjX/+l9O+YUn2cK0uYeJBXNMfTse6/azxksNQjK1CFqFcWz
XIK12+THFiFQuuCc5lON6nkhpBkGJSCN43nevFigNhW3YWZG/Z1l86Y9Se0Sf96o
fL7VnV2Ri0kSwJuxNYH7ei5ZBG8GVuNFuqPhmfE2YD2yjbXMnnn4hKOWsM8Oe0xL
ocjPgMTGVgvgeqZo8tV2gvaAycPO4PcJ+yHlgXtdyV7qztECAwEAAaOCAnAwggJs
MBIGA1UdEwEB/wQIMAYBAf8CAQAwLwYDVR0fBCgwJjAkoCKgIIYeaHR0cDovL3Mu
c3ltY2IuY29tL3BjYTMtZzUuY3JsMA4GA1UdDwEB/wQEAwIBBjAuBggrBgEFBQcB
AQQiMCAwHgYIKwYBBQUHMAGGEmh0dHA6Ly9zLnN5bWNkLmNvbTCCAVkGA1UdIASC
AVAwggFMMFwGBmeBDAECAjBSMCYGCCsGAQUFBwIBFhpodHRwOi8vd3d3LnN5bWF1
dGguY29tL2NwczAoBggrBgEFBQcCAjAcGhpodHRwOi8vd3d3LnN5bWF1dGguY29t
L3JwYTB1BgorBgEEAfElBAIBMGcwZQYIKwYBBQUHAgIwWRpXSW4gdGhlIGV2ZW50
IHRoYXQgdGhlIEJsdWVDb2F0IENQUyBhbmQgU3ltYW50ZWMgQ1BTIGNvbmZsaWN0
LCB0aGUgU3ltYW50ZWMgQ1BTIGdvdmVybnMuMHUGCisGAQQB8SUEAgIwZzBlBggr
BgEFBQcCAjBZGldJbiB0aGUgZXZlbnQgdGhhdCB0aGUgQmx1ZUNvYXQgQ1BTIGFu
ZCBTeW1hbnRlYyBDUFMgY29uZmxpY3QsIHRoZSBTeW1hbnRlYyBDUFMgZ292ZXJu
cy4wHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMCkGA1UdEQQiMCCkHjAc
MRowGAYDVQQDExFTeW1hbnRlY1BLSS0yLTIxNDAdBgNVHQ4EFgQUR5UKC6ehgqJt
yZuczT7zkELkb5kwHwYDVR0jBBgwFoAUf9Nlp8Ld7LvwMAnzQzn6Aq8zMTMwDQYJ
KoZIhvcNAQELBQADggEBAJjsKAGzmIEavosNMHxJVCidIGF1r3+vmGBoSVU5iT9R
1DKnrQc8KO5l+LgMuyDUMmH5CxbLbOWT/GtEC/ZvyiVTfn2xNE9SXw46zNUz1oOO
DMJLyvTMuRt7LsExqqsg3KZo6esNW5gmCYbLyfcjn7dKbtjkHvOdxJJ7VrDDayeC
Z5rBgiTj1+l09Uxo+2rwfEvHXzVtWSQyuqxRc8DVwCgFGrnJNGJS1coOQdQ91i6Q
zij5S/djgP1rVHH+MkgJcUQ/2km9GC6B6Y3yMGq6XLVjLvi73Ch2G5mUWkeoZibb
yQSxTBWG6GJjyDY7543ZK3FH4Ctih/nFgXrjuY7Ghrk=
-----END CERTIFICATE-----
'@ > $env:temp/Hardening-DisableCABlueCoat.crt
Import-Certificate -Filepath "${env:temp}/Hardening-DisableCABlueCoat.crt" -CertStoreLocation Cert:\LocalMachine\Disallowed | out-null
Write-Progress -Activity AutoHarden -Status "Hardening-DisableCABlueCoat" -Completed


echo "####################################################################################################"
echo "# Hardening-DisableIPv6"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DisableIPv6" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DisableIPv6"
# Block IPv6
New-NetFirewallRule -direction Outbound -Action Block -Protocol 41 -Group AutoHarden-IPv6 -Name "[AutoHarden-$AutoHarden_version] IPv6" -DisplayName "[AutoHarden-$AutoHarden_version] IPv6" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol 43 -Group AutoHarden-IPv6 -Name "[AutoHarden-$AutoHarden_version] IPv6-Route" -DisplayName "[AutoHarden-$AutoHarden_version] IPv6-Route" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol 44 -Group AutoHarden-IPv6 -Name "[AutoHarden-$AutoHarden_version] IPv6-Frag" -DisplayName "[AutoHarden-$AutoHarden_version] IPv6-Frag" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol 59 -Group AutoHarden-IPv6 -Name "[AutoHarden-$AutoHarden_version] IPv6-NoNxt" -DisplayName "[AutoHarden-$AutoHarden_version] IPv6-NoNxt" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol 60 -Group AutoHarden-IPv6 -Name "[AutoHarden-$AutoHarden_version] IPv6-Opts" -DisplayName "[AutoHarden-$AutoHarden_version] IPv6-Opts" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol 58 -Group AutoHarden-IPv6 -Name "[AutoHarden-$AutoHarden_version] ICMPv6" -DisplayName "[AutoHarden-$AutoHarden_version] ICMPv6" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol "UDP" -RemotePort "547" -Group AutoHarden-IPv6 -Name "[AutoHarden-$AutoHarden_version] DHCPv6" -DisplayName "[AutoHarden-$AutoHarden_version] DHCPv6" -ErrorAction Ignore

# reg add "HKLM\SYSTEM\CurrentControlSet\services\tcpip6\parameters" /v DisabledComponents /t REG_DWORD /d 0xFF /f
# Netsh int ipv6 set int 12 routerdiscovery=disabled
# Netsh int ipv6 set int 12 managedaddress=disabled

# Protection against CVE-2020-16898: “Bad Neighbor”
netsh int ipv6 show int | foreach { $p=$_.trim().split(' ')[0]; [int]::TryParse($p,[ref]$null) -and (netsh int ipv6 set int $p rabaseddnsconfig=disable) -and (write-host "int >$p<") }
Write-Progress -Activity AutoHarden -Status "Hardening-DisableIPv6" -Completed


echo "####################################################################################################"
echo "# Hardening-DisableLLMNR"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DisableLLMNR" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DisableLLMNR"
# Disable LLMNR
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /t REG_DWORD /v EnableMulticast /d 0 /f
nbtstat.exe /n
New-NetFirewallRule -direction Outbound -Action Block -Protocol "UDP" -RemotePort "5355" -Group AutoHarden-LLMNR -Name "[AutoHarden-$AutoHarden_version] LLMNR-UDP" -DisplayName "[AutoHarden-$AutoHarden_version] LLMNR" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol "UDP" -RemotePort "5353" -Group AutoHarden-LLMNR -Name "[AutoHarden-$AutoHarden_version] MBNS" -DisplayName "[AutoHarden-$AutoHarden_version] MBNS" -ErrorAction Ignore
Write-Progress -Activity AutoHarden -Status "Hardening-DisableLLMNR" -Completed


echo "####################################################################################################"
echo "# Hardening-DisableMimikatz"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DisableMimikatz" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DisableMimikatz"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v Negotiate /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA" /v RunAsPPL /t REG_DWORD /d 1 /f

if( (ask "Is this computer is a laptop connected to a domain ?" "Mimikatz-DomainCred.ask") -eq $false ){
	reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableDomainCreds /f 2>$null
	reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v TokenLeakDetectDelaySecs /f 2>$null
	reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v RestrictReceivingNTLMTraffic /f 2>$null
	reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v RestrictSendingNTLMTraffic /f 2>$null
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v NTLMMinClientSec /t REG_DWORD /d 0x20000000 /f
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v NTLMMinServerSec /t REG_DWORD /d 0x20000000 /f
}else{
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableDomainCreds /t REG_DWORD /d 1 /f
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v TokenLeakDetectDelaySecs /t REG_DWORD /d 30 /f
	# 'Allow all' = '0'
	# 'Deny all domain accounts' = '1'
	# 'Deny all accounts' = '2'
	#A TEST#######reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v RestrictReceivingNTLMTraffic /t REG_DWORD /d 2 /f
	#A TEST#######reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v RestrictSendingNTLMTraffic /t REG_DWORD /d 2 /f
	#A TEST#######reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v NTLMMinClientSec /t REG_DWORD /d 0x20080000 /f
	#A TEST#######reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v NTLMMinServerSec /t REG_DWORD /d 0x20080000 /f
}

# This sets up your RDP session to NOT store credentials in the memory of the target host.
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA" /v DisableRestrictedAdmin /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA" /v DisableRestrictedAdminOutboundCreds /t REG_DWORD /d 1 /f

if( (Get-Item "C:\Program Files*\VMware\*\vmnat.exe") -eq $null ){
	if( ask "Do you want to enable `"Credentials Guard`" and disable VMWare/VirtualBox" "CredentialsGuard.ask" ){
		# Credentials Guard
		reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA" /v LsaCfgFlags /t REG_DWORD /d 1 /f
		reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA" /v LsaCfgFlagsDefault /t REG_DWORD /d 1 /f
		# Credentials Guard bloque VMWare...
		# En cas de blocage, il faut d�sactive CG via DG_Readiness.ps1 -Disable
		# cf https://stackoverflow.com/questions/39858200/vmware-workstation-and-device-credential-guard-are-not-compatible
		# cf https://www.microsoft.com/en-us/download/details.aspx?id=53337
	}else{
		reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA" /v LsaCfgFlags /f
		reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA" /v LsaCfgFlagsDefault /t REG_DWORD /d 0 /f
	}
}
Write-Progress -Activity AutoHarden -Status "Hardening-DisableMimikatz" -Completed


echo "####################################################################################################"
echo "# Hardening-DisableNetbios"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DisableNetbios" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DisableNetbios"
New-NetFirewallRule -direction Outbound -Action Block -Protocol "TCP" -RemotePort "135" -Group AutoHarden-NetBios -Name "[AutoHarden-$AutoHarden_version] NetBios-TCP135" -DisplayName "[AutoHarden-$AutoHarden_version] NetBios" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol "UDP" -RemotePort "137" -Group AutoHarden-NetBios -Name "[AutoHarden-$AutoHarden_version] NetBios-UDP137" -DisplayName "[AutoHarden-$AutoHarden_version] NetBios" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol "UDP" -RemotePort "138" -Group AutoHarden-NetBios -Name "[AutoHarden-$AutoHarden_version] NetBios-UDP138" -DisplayName "[AutoHarden-$AutoHarden_version] NetBios2" -ErrorAction Ignore
New-NetFirewallRule -direction Outbound -Action Block -Protocol "TCP" -RemotePort "139" -Group AutoHarden-NetBios -Name "[AutoHarden-$AutoHarden_version] NetBios-TCP139" -DisplayName "[AutoHarden-$AutoHarden_version] NetBios3" -ErrorAction Ignore
set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions -Value 2
Write-Progress -Activity AutoHarden -Status "Hardening-DisableNetbios" -Completed


echo "####################################################################################################"
echo "# Hardening-DisableRemoteServiceManagement"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DisableRemoteServiceManagement" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DisableRemoteServiceManagement"
# From: https://twitter.com/JohnLaTwC/status/802218490404798464?s=19
# Empeche la création de service via les RPC/SMB distant. => psexec upload ok mais exec fail
$tmp=(sc.exe sdshow scmanager).split("`r`n")[1].split(":")[1]
if( -not $tmp.Contains("(D;;GA;;;NU)") -and -not $tmp.Contains("(D;;KA;;;NU)") ){
	sc.exe sdset scmanager "D:(D;;GA;;;NU)$tmp"
}else{
	echo "Already patched"
}
Write-Progress -Activity AutoHarden -Status "Hardening-DisableRemoteServiceManagement" -Completed


echo "####################################################################################################"
echo "# Hardening-DisableSMBServer"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DisableSMBServer" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DisableSMBServer"
# Désactivation des partages administratifs
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v AutoShareWks /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v AutoShareServer /t REG_DWORD /d 0 /f

# Block CobaltStrike from using \\evil.kali\tmp$\becon.exe
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" /v AllowInsecureGuestAuth /t REG_DWORD /d 0 /f

#Set-SmbServerConfiguration -AnnounceServer $false -Force
#Get-SmbServerConfiguration

sc.exe config lanmanserver start= disabled
Write-Progress -Activity AutoHarden -Status "Hardening-DisableSMBServer" -Completed


echo "####################################################################################################"
echo "# Hardening-DisableSMBv1"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DisableSMBv1" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DisableSMBv1"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 0 /f
reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v EnableSecuritySignature /t REG_DWORD /d 1 /f
reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 1 /f
reg add "HKLM\System\CurrentControlSet\Services\Rdr\Parameters" /v EnableSecuritySignature /t REG_DWORD /d 1 /f
reg add "HKLM\System\CurrentControlSet\Services\Rdr\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 1 /f
Write-Progress -Activity AutoHarden -Status "Hardening-DisableSMBv1" -Completed


echo "####################################################################################################"
echo "# Hardening-DisableWPAD"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DisableWPAD" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DisableWPAD"
# Disable wpad service
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc" /t REG_DWORD /v Start /d 4 /f

reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "DefaultConnectionSettings" /f
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "SavedLegacySettings" /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" /t REG_DWORD /v WpadOverride /d 0 /f
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
ipconfig /flushdns
$_wpad=cat C:\Windows\System32\drivers\etc\hosts | findstr /c:"0.0.0.0 wpad"
if( [string]::IsNullOrEmpty($_wpad) ){
	echo "`r`n0.0.0.0 wpad" >> C:\Windows\System32\drivers\etc\hosts
}
$_wpad=cat C:\Windows\System32\drivers\etc\hosts | findstr /c:"0.0.0.0 ProxySrv"
if( [string]::IsNullOrEmpty($_wpad) ){
	echo "`r`n0.0.0.0 ProxySrv" >> C:\Windows\System32\drivers\etc\hosts
}
Write-Progress -Activity AutoHarden -Status "Hardening-DisableWPAD" -Completed


echo "####################################################################################################"
echo "# Hardening-DLLHijacking"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DLLHijacking" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DLLHijacking"
if( ask "Block DLL from SMB share and WebDav Share" "Hardening-DLLHijacking.ask" ){
# Prevent (remote) DLL Hijacking
# Sources:
# https://www.greyhathacker.net/?p=235
# https://www.verifyit.nl/wp/?p=175464
# https://support.microsoft.com/en-us/help/2264107/a-new-cwdillegalindllsearch-registry-entry-is-available-to-control-the
# The value data can be 0x1, 0x2 or 0xFFFFFFFF. If the value name CWDIllegalInDllSearch does not exist or the value data is 0 then the machine will still be vulnerable to attack.
# Please be aware that the value 0xFFFFFFFF could break certain applications (also blocks dll loading from USB).
# Blocks a DLL Load from the current working directory if the current working directory is set to a WebDAV folder  (set it to 0x1)
# Blocks a DLL Load from the current working directory if the current working directory is set to a remote folder (such as a WebDAV or UNC location) (set it to 0x2)
# ---------------------
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v CWDIllegalInDllSearch /t REG_DWORD /d 0x2 /f
}
else{
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v CWDIllegalInDllSearch /t REG_DWORD /d 0x0 /f
}
Write-Progress -Activity AutoHarden -Status "Hardening-DLLHijacking" -Completed


echo "####################################################################################################"
echo "# Hardening-DNSCache"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-DNSCache" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-DNSCache"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxCacheTtl /t REG_DWORD /d 10 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxNegativeCacheTtl /t REG_DWORD /d 10 /f
Write-Progress -Activity AutoHarden -Status "Hardening-DNSCache" -Completed


echo "####################################################################################################"
echo "# Hardening-FileExtension"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-FileExtension" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-FileExtension"
# assoc .txt
# .hta
cmd /c ftype  htafile="C:\Windows\notepad.exe" "%1"
# .js
cmd /c ftype  JSFile="C:\Windows\notepad.exe" "%1"
# .jse
cmd /c ftype  JSEFile="C:\Windows\notepad.exe" "%1"
# .vbe
cmd /c ftype VBEFile="C:\Windows\notepad.exe" "%1"
# .vbs
cmd /c ftype VBSFile="C:\Windows\notepad.exe" "%1"
# .wsf
cmd /c ftype WSFFile="C:\Windows\notepad.exe" "%1"
# .wsh
cmd /c ftype WSHFile="C:\Windows\notepad.exe" "%1"
# .reg
cmd /c ftype regfile="C:\Windows\notepad.exe" "%1"
# .inf
cmd /c ftype inffile="C:\Windows\notepad.exe" "%1"
# .scf 
cmd /c ftype SHCmdFile="C:\Windows\notepad.exe" "%1"
# .wsc
cmd /c ftype scriptletfile="C:\Windows\notepad.exe" "%1"
# .scr
cmd /c ftype scrfile="C:\Windows\notepad.exe" "%1"
# .pif
cmd /c ftype piffile="C:\Windows\notepad.exe" "%1"
# .ps1
cmd /c ftype Microsoft.PowerShellScript.1="C:\Windows\notepad.exe" "%1"
cmd /c ftype Microsoft.PowerShellXMLData.1="C:\Windows\notepad.exe" "%1"
cmd /c ftype Microsoft.PowerShellConsole.1="C:\Windows\notepad.exe" "%1"
# .xml
cmd /c ftype "XML Script Engine"="C:\Windows\notepad.exe" "%1"
Write-Progress -Activity AutoHarden -Status "Hardening-FileExtension" -Completed


echo "####################################################################################################"
echo "# Hardening-RemoteAssistance"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-RemoteAssistance" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-RemoteAssistance"
if( ask "Disable RDP server on this computer" "Hardening-RemoteAssistance.ask" ){
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" /t REG_DWORD /v fAllowToGetHelp /d 0 /f
}
else{
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /f
}
Write-Progress -Activity AutoHarden -Status "Hardening-RemoteAssistance" -Completed


echo "####################################################################################################"
echo "# Hardening-Wifi-RemoveOpenProfile"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-Wifi-RemoveOpenProfile" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-Wifi-RemoveOpenProfile"
netsh wlan export profile folder=C:\Windows\Temp
get-item C:\Windows\temp\Wi-Fi-*.xml | foreach {
	$xml=[xml] (cat $_.FullName)
	Write-Host "[*] Lecture du profile wifi $($_.Name)"
	if( $xml.WLANProfile.MSM.security.authEncryption.authentication.ToLower() -eq "open" ){
		$p=$xml.WLANProfile.SSIDConfig.SSID.name.Replace('"','')
		Write-Host "[*] Suppression du profile wifi $p"		
		netsh wlan delete profile name="$p" interface=*
	}
}
rm C:\Windows\temp\Wi-Fi-*.xml
Write-Progress -Activity AutoHarden -Status "Hardening-Wifi-RemoveOpenProfile" -Completed


echo "####################################################################################################"
echo "# Hardening-Wifi"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Hardening-Wifi" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Hardening-Wifi"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /t REG_DWORD /v DontDisplayNetworkSelectionUI /d 1 /f

# WiFi Sense: Shared HotSpot Auto-Connect: Disable
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /t REG_DWORD /v value /d 0 /f
Write-Progress -Activity AutoHarden -Status "Hardening-Wifi" -Completed


echo "####################################################################################################"
echo "# Log-Activity"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Log-Activity" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Log-Activity"
# Log powershell activity
# https://static1.squarespace.com/static/552092d5e4b0661088167e5c/t/5ba3dc87e79c703f9bfff29a/1537465479833/Windows+PowerShell+Logging+Cheat+Sheet+ver+Sept+2018+v2.2.pdf
# https://www.malwarearchaeology.com/cheat-sheets
reg add HKLM\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging /v EnableModuleLogging /t REG_DWORD /d 1 /f
reg add HKCU\Software\Policies\Microsoft\Windows\PowerShell\Transcription /v EnableTranscripting /t REG_DWORD /d 1 /f
reg add HKCU\Software\Policies\Microsoft\Windows\PowerShell\Transcription /v EnableInvocationHeader /t REG_DWORD /d 1 /f
reg add HKCU\Software\Policies\Microsoft\Windows\PowerShell\Transcription /v OutputDirectory /t REG_SZ /d "C:\Windows\AutoHarden\Powershell.log" /f
reg add HKCU\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f
# This is VERY noisy, do not set in most environments, or seriously test first (4105 & 4106)
#reg query HKCU\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging /v EnableScriptBlockInvocationLogging
#WevtUtil gl "Windows PowerShell"
#WevtUtil gl "Microsoft-Windows-PowerShell/Operational"

# Log DHCP
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Dhcp-Client/Operational" /v Enabled /t REG_DWORD /d 1 /f

# Log DHCPv6
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Dhcpv6-Client/Operational" /v Enabled /t REG_DWORD /d 1 /f

# Log DNS
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-DNS-Client/Operational" /v Enabled /t REG_DWORD /d 1 /f

if( -not [System.IO.File]::Exists("C:\Windows\AutoHarden\AuditPol_BEFORE.txt") ){
	Auditpol /get /category:* > C:\Windows\AutoHarden\AuditPol_BEFORE.txt
}

# From
#	https://github.com/rkovar/PowerShell/blob/master/audit.bat
#	https://forensixchange.com/posts/19_05_07_dns_investigation/

# SET THE LOG SIZE - What local size they will be
# ---------------------
#
# 540100100 will give you 7 days of local Event Logs with everything logging (Security and Sysmon)
# 1023934464 will give you 14 days of local Event Logs with everything logging (Security and Sysmon)
# Other logs do not create as much quantity, so lower numbers are fine
#
wevtutil sl Security /ms:540100100
wevtutil sl Application /ms:256000100
wevtutil sl Setup /ms:256000100
wevtutil sl System /ms:256000100
wevtutil sl "Windows Powershell" /ms:256000100
wevtutil sl "Microsoft-Windows-Sysmon/Operational" /ms:540100100


# PS C:\> auditpol /list /subcategory:* /r
#
# Catégorie/Sous-catégorie,GUID
# Système,{69979848-797A-11D9-BED3-505054503030}
#   Modification de l’état de la sécurité,{0CCE9210-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9210-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Extension système de sécurité,{0CCE9211-69AE-11D9-BED3-505054503030}
#   Intégrité du système,{0CCE9212-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9212-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Pilote IPSEC,{0CCE9213-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9213-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable
#   Autres événements système,{0CCE9214-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9214-69AE-11D9-BED3-505054503030}" /success:disable /failure:enable
# Ouverture/Fermeture de session,{69979849-797A-11D9-BED3-505054503030}
#   Ouvrir la session,{0CCE9215-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9215-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Fermer la session,{0CCE9216-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9216-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Verrouillage du compte,{0CCE9217-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9217-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Mode principal IPsec,{0CCE9218-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9218-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable
#   Mode rapide IPsec,{0CCE9219-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9219-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable
#   Mode étendu IPsec,{0CCE921A-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE921A-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable
#   Ouverture de session spéciale,{0CCE921B-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE921B-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Autres événements d’ouverture/fermeture de session,{0CCE921C-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE921C-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Serveur NPS,{0CCE9243-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9243-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Revendications utilisateur/de périphérique,{0CCE9247-69AE-11D9-BED3-505054503030}
#   Appartenance à un groupe,{0CCE9249-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9249-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
# Accès aux objets,{6997984A-797A-11D9-BED3-505054503030}
#   Système de fichiers,{0CCE921D-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE921D-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Registre,{0CCE921E-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE921E-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Objet de noyau,{0CCE921F-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE921F-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   SAM,{0CCE9220-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9220-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
#   Services de certification,{0CCE9221-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9221-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Généré par application,{0CCE9222-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9222-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Manipulation de handle,{0CCE9223-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9223-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
#   Partage de fichiers,{0CCE9224-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9224-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Rejet de paquet par la plateforme de filtrage,{0CCE9225-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9225-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
#   Connexion de la plateforme de filtrage,{0CCE9226-69AE-11D9-BED3-505054503030}
#   Autres événements d’accès à l’objet,{0CCE9227-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9227-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
#   Partage de fichiers détaillé,{0CCE9244-69AE-11D9-BED3-505054503030}
#   Stockage amovible,{0CCE9245-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9245-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
#   Stratégie centralisée intermédiaire,{0CCE9246-69AE-11D9-BED3-505054503030}
# Utilisation de privilège,{6997984B-797A-11D9-BED3-505054503030}
#   Utilisation de privilèges sensibles,{0CCE9228-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9228-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
#   Utilisation de privilèges non sensibles,{0CCE9229-69AE-11D9-BED3-505054503030}
#   Autres événements d’utilisation de privilèges,{0CCE922A-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE922A-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
# Suivi détaillé,{6997984C-797A-11D9-BED3-505054503030}
#   Création du processus,{0CCE922B-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
# Log process activity
reg.exe add "hklm\software\microsoft\windows\currentversion\policies\system\audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f
#   Fin du processus,{0CCE922C-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE922C-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
#   Activité DPAPI,{0CCE922D-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE922D-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
#   Événements RPC,{0CCE922E-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE922E-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Événements Plug-and-Play,{0CCE9248-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9248-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Événements de jeton ajustés à droite,{0CCE924A-69AE-11D9-BED3-505054503030}
# Changement de stratégie,{6997984D-797A-11D9-BED3-505054503030}
#   Modification de la stratégie d’audit,{0CCE922F-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE922F-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Modification de la stratégie d’authentification,{0CCE9230-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9230-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Modification de la stratégie d’autorisation,{0CCE9231-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9231-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Modification de la stratégie de niveau règle MPSSVC,{0CCE9232-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9232-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable
#   Modification de la stratégie de plateforme de filtrage,{0CCE9233-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9233-69AE-11D9-BED3-505054503030}" /success:enable /failure:disable
#   Autres événements de modification de stratégie,{0CCE9234-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9234-69AE-11D9-BED3-505054503030}" /success:disable /failure:enable
# Gestion des comptes,{6997984E-797A-11D9-BED3-505054503030}
#   Gestion des comptes d’utilisateur,{0CCE9235-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9235-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Gestion des comptes d’ordinateur,{0CCE9236-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9236-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Gestion des groupes de sécurité,{0CCE9237-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9237-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Gestion des groupes de distribution,{0CCE9238-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9238-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Gestion des groupes d’applications,{0CCE9239-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9239-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Autres événements de gestion des comptes,{0CCE923A-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE923A-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
# Accès DS,{6997984F-797A-11D9-BED3-505054503030}
#   Accès au service d’annuaire,{0CCE923B-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE923B-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Modification du service d’annuaire,{0CCE923C-69AE-11D9-BED3-505054503030}
#   Réplication du service d’annuaire,{0CCE923D-69AE-11D9-BED3-505054503030}
#   Réplication du service d’annuaire détaillé,{0CCE923E-69AE-11D9-BED3-505054503030}
# Connexion de compte,{69979850-797A-11D9-BED3-505054503030}
#   Validation des informations d’identification,{0CCE923F-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE923F-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Opérations de ticket du service Kerberos,{0CCE9240-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9240-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Autres événements d’ouverture de session,{0CCE9241-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9241-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#   Service d’authentification Kerberos,{0CCE9242-69AE-11D9-BED3-505054503030}
auditpol /set /subcategory:"{0CCE9242-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable


##############################################################################
# Log all autoruns to detect malware
# From: https://github.com/palantir/windows-event-forwarding/
start-job -scriptblock {
	autorunsc -nobanner /accepteula -a "*" -c -h -s -v -vt "*" > C:\Windows\AutoHarden\autorunsc.csv
	$autorunsc7z = ("C:\Windows\AutoHarden\autorunsc_"+(Get-Date -Format "yyyy-MM-dd")+".7z")
	7z a -t7z $autorunsc7z "C:\Windows\AutoHarden\autorunsc.csv"
	if( [System.IO.File]::Exists($autorunsc7z) ){
		rm -Force "C:\Windows\AutoHarden\autorunsc.csv"
	}
}
Write-Progress -Activity AutoHarden -Status "Log-Activity" -Completed


echo "####################################################################################################"
echo "# Optimiz-ClasicExplorerConfig"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Optimiz-ClasicExplorerConfig" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Optimiz-ClasicExplorerConfig"
if( ask "Optimiz the Windows GUI" "Optimiz-ClasicExplorerConfig.ask" ){
# These make "Quick Access" behave much closer to the old "Favorites"
# Disable Quick Access: Recent Files
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v ShowFrequent /t REG_DWORD /d 0 /f
# Disable Quick Access: Frequent Folders
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v ShowRecent /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarSmallIcons /t REG_DWORD /d 1 /f
# Disable Icon Grouping
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarGlomLevel /t REG_DWORD /d 1 /f
# Change Explorer home screen back to "This PC"
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f
}
Write-Progress -Activity AutoHarden -Status "Optimiz-ClasicExplorerConfig" -Completed


echo "####################################################################################################"
echo "# Optimiz-CleanUpWindowFolder"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Optimiz-CleanUpWindowFolder" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Optimiz-CleanUpWindowFolder"
# https://www.malekal.com/comment-reduire-la-taille-du-dossier-windows-de-windows-10/

# Réduire la taille du dossier WinSxS
Dism.exe /online /Cleanup-Image /StartComponentCleanup
# En appliquant ces deux commandes, vous ne pourrez plus désinstaller les mises à jour Windows.
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
Dism.exe /online /Cleanup-Image /SPSuperseded

# Réparation des DLL et drivers
DISM /Online /Cleanup-image /Restorehealth
sfc /SCANNOW
Write-Progress -Activity AutoHarden -Status "Optimiz-CleanUpWindowFolder" -Completed


echo "####################################################################################################"
echo "# Optimiz-CleanUpWindowsName"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Optimiz-CleanUpWindowsName" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Optimiz-CleanUpWindowsName"
$finalUser='Administrateur'
try{
	if( -Not (New-Object System.Security.Principal.NTAccount($finalUser)).Translate([System.Security.Principal.SecurityIdentifier]).value.EndsWith('-500') ){
		$finalUser='Invité'
	}
}catch{
	$finalUser='Administrator'
	if( -Not (New-Object System.Security.Principal.NTAccount($finalUser)).Translate([System.Security.Principal.SecurityIdentifier]).value.EndsWith('-500') ){
		$finalUser='Guest'
	}
}


function killfakename( $file ){
	echo "$file ========="
	#takeown.exe /f $file
	icacls.exe "$file" /setowner $env:username
	remove-item -Force $file
	echo '' | Out-File $file
	icacls.exe "$file" /setowner $finalUser
	attrib +s +h $file
	(Get-Acl $file).Owner
	#(Get-Acl $file).Access
}


killfakename 'C:\Users\desktop.ini'
killfakename 'C:\Program Files\desktop.ini'
killfakename 'C:\Program Files (x86)\desktop.ini'
Write-Progress -Activity AutoHarden -Status "Optimiz-CleanUpWindowsName" -Completed


echo "####################################################################################################"
echo "# Optimiz-DisableAutoReboot"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Optimiz-DisableAutoReboot" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Optimiz-DisableAutoReboot"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /t REG_DWORD /v NoAutoRebootWithLoggedOnUsers /d 1 /f
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Disable
if( !(Test-Path -PathType Container "$env:WINDIR\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\Reboot") ){
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Reboot" /Disable
	ren "$env:WINDIR\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\Reboot" "$env:WINDIR\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\Reboot.bak"
	md "$env:WINDIR\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\Reboot"
}
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /t REG_DWORD /v ActiveHoursStart /d 4 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /t REG_DWORD /v ActiveHoursEnd /d 23 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /t REG_DWORD /v IsActiveHoursEnabled /d 1 /f
Write-Progress -Activity AutoHarden -Status "Optimiz-DisableAutoReboot" -Completed


echo "####################################################################################################"
echo "# Optimiz-DisableAutoUpdate"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Optimiz-DisableAutoUpdate" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Optimiz-DisableAutoUpdate"
if( ask "Disable auto Windows Update during work time ?" "Optimiz-DisableAutoUpdate.ask" ){
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v RebootRelaunchTimeoutEnabled /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v RebootWarningTimeoutEnabled /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v ScheduledInstallDay /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v ScheduledInstallTime /t REG_DWORD /d 3 /f
}
Write-Progress -Activity AutoHarden -Status "Optimiz-DisableAutoUpdate" -Completed


echo "####################################################################################################"
echo "# Optimiz-DisableDefender"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Optimiz-DisableDefender" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Optimiz-DisableDefender"
if( ask "Disable WindowsDefender" "Optimiz-DisableDefender.ask" ){
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend" /v Start /t REG_DWORD /d 4 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /v Start /t REG_DWORD /d 4 /f
# https://twitter.com/jonasLyk/status/1293815234805760000?s=20


#Remove-Item "C:\ProgramData\Microsoft\Windows Defender" -stream "omgwtfbbq" -Force -ErrorAction SilentlyContinue 
#fsutil reparsepoint delete "C:\ProgramData\Microsoft\Windows Defender"
## Can crash WINDOWS. This part will be removed in december 2020 !!!!
#cmd /c 'mklink "C:\ProgramData\Microsoft\Windows Defender:omgwtfbbq" "\??\NUL"'
}
else{
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend" /v Start /t REG_DWORD /d 2 /f
# https://twitter.com/jonasLyk/status/1293815234805760000?s=20
Remove-Item "C:\ProgramData\Microsoft\Windows Defender" -stream "omgwtfbbq" -Force -ErrorAction SilentlyContinue 
fsutil reparsepoint delete "C:\ProgramData\Microsoft\Windows Defender"
}
Write-Progress -Activity AutoHarden -Status "Optimiz-DisableDefender" -Completed


echo "####################################################################################################"
echo "# Software-install-notepad++"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Software-install-notepad++" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Software-install-notepad++"
if( ask "Replace notepad with notepad++" "Software-install-notepad++.ask" ){
################################################################################
# Installation de choco
#
if( !(Get-Command "choco" -errorAction SilentlyContinue) ){
	echo "==============================================================================="
	echo "Install: choco"
	Get-NetFirewallRule -Name '*AutoHarden*Powershell*' | Disable-NetFirewallRule
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
	Get-NetFirewallRule -Name '*AutoHarden*Powershell*' | Enable-NetFirewallRule
}
################################################################################
# Installation des soft de base
#
function chocoInstall( $pk )
{
	if( "$global:chocoList" -Match "$pk" ){
		return ;
	}
	echo "==============================================================================="
	echo "Install: $pk"
	choco install $pk -y
}
$global:chocoList = & choco list -localonly 

chocoInstall notepadplusplus.install
$npp_path=(Get-Item "C:\Program Files*\Notepad++\notepad++.exe").FullName.Replace('.exe','.vbs')

@'
'// DISCLAIMER
'// THIS COMES WITH NO WARRANTY, IMPLIED OR OTHERWISE. USE AT YOUR OWN RISK
'// IF YOU ARE NOT COMFORTABLE EDITING THE REGISTRY THEN DO NOT USE THIS SCRIPT
'//
'// NOTES:
'// This affects all users.
'// This will prevent ANY executable named notepad.exe from running located anywhere on this computer!!
'//
'// Save this text to your notepad++ folder as a text file named npp.vbs (some AV don't like vbs, get a different AV :-P )
'//
'// USAGE
'// 1)
'// Navigate to registry key HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\
'//
' // 2)
'// Add new subkey called notepad.exe
'// This step is what tells windows to use the notepad++ exe, to undo simply delete this key
'//
'// 3)
'// Create new Sting Value called Debugger
'//
'// 4)
'// Modify value and enter wscript.exe "path to npp.vbs" e.g. wscript.exe "C:\Program Files\Notepad++\npp.vbs"

Option Explicit
Dim sCmd, x
sCmd = """" & LeftB(WScript.ScriptFullName, LenB(WScript.ScriptFullName) - LenB(WScript.ScriptName)) & "notepad++.exe" & """ """
For x = 1 To WScript.Arguments.Count - 1
   sCmd = sCmd & WScript.Arguments(x) & " "
Next
sCmd = sCmd & """"
CreateObject("WScript.Shell").Exec(sCmd)
WScript.Quit
'@ | out-file -encoding ASCII $npp_path

if( [System.IO.File]::Exists($npp_path) ){
	# Create sub folder
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /v Debugger /t REG_SZ /d x /f
	# Create key
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" -Name Debugger -Value ('wscript.exe "'+$npp_path+'"') -PropertyType String -Force
}
}
else{
$npp_path=(Get-Item "C:\Program Files*\Notepad++\notepad++.exe")
if( $npp_path -ne $null ){
	$npp_path = $npp_path.FullName.Replace('.exe','.vbs')
	rm $npp_path
	choco uninstall notepadplusplus.install -y
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /f
}
}
Write-Progress -Activity AutoHarden -Status "Software-install-notepad++" -Completed


echo "####################################################################################################"
echo "# Software-install"
echo "####################################################################################################"
Write-Progress -Activity AutoHarden -Status "Software-install" -PercentComplete 0
Write-Host -BackgroundColor Blue -ForegroundColor White "Running Software-install"
################################################################################
# Installation de choco
#
if( !(Get-Command "choco" -errorAction SilentlyContinue) ){
	echo "==============================================================================="
	echo "Install: choco"
	Get-NetFirewallRule -Name '*AutoHarden*Powershell*' | Disable-NetFirewallRule
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
	Get-NetFirewallRule -Name '*AutoHarden*Powershell*' | Enable-NetFirewallRule
}

################################################################################
# Installation des soft de base
#
function chocoInstall( $pk )
{
	if( "$global:chocoList" -Match "$pk" ){
		return ;
	}
	echo "==============================================================================="
	echo "Install: $pk"
	choco install $pk -y
}
$global:chocoList = & choco list -localonly 

#chocoInstall vcredist-all
chocoInstall 7zip.install
#chocoInstall greenshot
chocoInstall vlc
#chocoInstall sysinternals
#chocoInstall keepass.install

#linkshellextension,veracrypt

choco upgrade all -y
Write-Progress -Activity AutoHarden -Status "Software-install" -Completed


Stop-Transcript
7z a -t7z ($AutoHardenLog+".7z") $AutoHardenLog
if( [System.IO.File]::Exists($AutoHardenLog+".7z") ){
	rm -Force $AutoHardenLog
}

# SIG # Begin signature block
# MIINoAYJKoZIhvcNAQcCoIINkTCCDY0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBzyTbj3mIjWW9gKQtHwmKW+6
# Ruigggo9MIIFGTCCAwGgAwIBAgIQobvWmnCC3YBAuYu4RT1skTANBgkqhkiG9w0B
# AQ0FADAYMRYwFAYDVQQDEw1BdXRvSGFyZGVuLUNBMB4XDTIxMDQxMTA4MjUxMFoX
# DTM5MTIzMTIzNTk1OVowFTETMBEGA1UEAxMKQXV0b0hhcmRlbjCCAiIwDQYJKoZI
# hvcNAQEBBQADggIPADCCAgoCggIBAM5nLYR2Ew4oDqcFdR28IbrdUcIvbv/DL0ax
# HD+8t27lVLfuQypSyuize0CdpkV3LlwPwvAf5jPE6ohF/bGiXWAbSk4azdIQmdC/
# MVUzxPFLT+yr32hiSLVs2nVm1HR30/vZeFdlllxuMaZvTfhZqVf4gJ5zYMUCRPG9
# 3HgW4oW6d137p982SadkdFaN6pOhLiUNH1gAPdbeRMngTnt5PzUFCyjx6n+mQ3sP
# NjMu4/FXfYAb2DIP/eAeiktOXZPwcSAbE35YV6vptT9AdhRu/44NcXOT9ftgq+MV
# 1Aw4m6JWn2Z6aA7do2zHbW97HNCt0PUfreiKcUCb/nDqoN/0Uk9NdvjcplLb6ccu
# LN05YYF9uOmLT82XDaG8utGntH6X7V0Ldg5VQ7Pg3yFA3ahcRddcf525KQ+mJEdS
# gpYnWQ5+j++UUhVo2YijRmRWNkFSGgV9rCItGSiwBM5jhcVXq0A/Pul7g9Rij7eB
# Oap1GFzSXzy9dLzRwC1zDMEh4Z1GoWA0vhb4NOa0/ISG7KZXUWq2MpXD2dMiakQT
# qmVnbMsCFN3/CbbPZt4GQfnfjo3y85eeBDcdXPStZoGtSjBbq0GKrHao1b8e98R1
# mVzsBOOtrppSdHzjMWcpJr+H1Q2SBYCeF5AjH1sJ9b7wHmJghujyBQ87sG3Le1gr
# KXLy1jExAgMBAAGjYjBgMBMGA1UdJQQMMAoGCCsGAQUFBwMDMEkGA1UdAQRCMECA
# EOYDPlhk+/8GHZ4Uje3mOiehGjAYMRYwFAYDVQQDEw1BdXRvSGFyZGVuLUNBghD1
# NmqDy5ZuqE1inZr6g+JZMA0GCSqGSIb3DQEBDQUAA4ICAQBwStpDuIjnwHNcXCnk
# x4MYdYoOiDYiS62YhuVAfb1n1iDTzUF0v2s3pC0btVER8NuLdZmf9lk83VLqKV3P
# tXAELK3a4liMB5ODSpYdBrSLZjW393zyRC0GBu4DUQMVvFmkkKDFLjvxo3Y665nv
# 1bW5GG/TP/BbSOFxGnRjGz+8citQ7uF68Db33rf6VBEuKBTRFpS6ck5yAAlqvi/j
# 0VZjb4jLspsD5egY2t4U0UmQetUXnw6gGM9QhwwACElMeQKtc6+EwY8Nk+aq4EIt
# 5lReG8Yjz/TY7/AYZHfQJPzYoOBSuAFfkFoFOkXvW9STAcQrt9uJLJg7YavKRTIV
# ZMCgMk/Cir72LDyVHZU2WHUCHFURfqNT7Rv+4gsnEhpGeuDT0emwZK5eQswfp3/6
# VEOzTcZ5TIypTeftmg1Xl8Raz6+LWGOc4RaFRCr9k7rk7+w4IAiGRxbeBZ+2aH+/
# PYoyEWXb0loKsglZQ0muTEUiRCXTFth4kZ0xzp1BSs32owYs+LF8TmvuGdQvRENs
# w4Wzp5jjs9XMh87Gq52aj5lo2UuWExXDrPwcD8nZ819bdUufHmPZV7fF1kayuXth
# j1EsUbGcQwurIdD2xPtG1XylIdL2oE4Ae2jxITqECb259bC4h7o8K90qHZp1DStb
# 6/bR/k/BMqVYkFEyxCmu7NteMzCCBRwwggMEoAMCAQICEPU2aoPLlm6oTWKdmvqD
# 4lkwDQYJKoZIhvcNAQENBQAwGDEWMBQGA1UEAxMNQXV0b0hhcmRlbi1DQTAeFw0y
# MTA0MTEwODI1MDdaFw0zOTEyMzEyMzU5NTlaMBgxFjAUBgNVBAMTDUF1dG9IYXJk
# ZW4tQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDOulLqnbALnuf4
# hB1U0ts9ivIpt3jB9GB7cyBer8yvGoowkfYh4kfISpvvqotL9FenoBnaBFVDUBfo
# 5kiJgT+or5jGcidpKhbtAP1C0Wv226R/MjQFTzMD+bwGl9+b7TjqJmLbhtKuT6sn
# rM3w/rkJaHm20HkIw8Rkk2qUXVnGcS3oBM+p0Ko5iB/d1fOvX7mPjz1B6YKA8MKq
# pfUXR2kvObOaWKLG0ZZl4nbTpDOmeEZGkqdK6TaSduLKbarbHFpKSLhL2TLp7h9f
# osHwwdSsyOXLnCZyUULCsPnFN5Dsq3n6fGsfdLpPthZFD4Gz538ZxU7CpRkL5pYc
# adRVl6yv/VfePp1iDMYNOH6HpLKih/vN56hMUje8DT/mSabjgFQWDFCRaVAUkU8l
# QaAx7bD5Kfr2VthqINd8psYGk1aIUzneJF6OuC2zcD88TDD1WM8/A7UjjC+tdmbf
# F5fhn5rTIKAhn08HNo4Ez42zeBNsEtk0go7dSLd++XVbJCu+Is169g38of6kMIPV
# vCFkvVQ5HhJuQ/FkFFXSkoPvCE9fwKrDYsqgw/7Bi2cZBdLC41brvR8QSaIXoK9q
# EJ5Hvf9L4LzTjNE9lcnLwTLtmFE8XzPPM1/CbQqpn7uM1CcJYobpimsezeDS1a/H
# wOynAo2RUlYZiXu39PS+Ykj1JIvYKQIDAQABo2IwYDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBJBgNVHQEEQjBAgBDmAz5YZPv/Bh2eFI3t5jonoRowGDEWMBQGA1UEAxMN
# QXV0b0hhcmRlbi1DQYIQ9TZqg8uWbqhNYp2a+oPiWTANBgkqhkiG9w0BAQ0FAAOC
# AgEATZuDk7Mc0God3tjeTjx9iZcqPq7lz7WYVRyaMJ69vj6cVaLZ7za9ogooDwzh
# YMcDtUQ21T96NdObzSG/XP7+zS86M7pc8uXLeWJy77V/SS2ZlQNqSXmMPdGS19ag
# puqdAvERsJJ86m3P/qTCyixEznrG7urKKJthiDQPnQL1CbpKYp074K4k5JI/Qtms
# gR9JYKqISx/1aAuoSI3utYFuDXLjM9nbY6pIt3fuDT0AqYbnjNUDdRGLrOB4mPG3
# qSb6nVEsuCJLKCNKU7ruhuDb/b0TIeb8DvYX5DorO/7SKYYP4SBnYT/00GZd8ucV
# p/9sODKsVzEvDvjnckWmtzrS6nvIt9luq0Iy65Cd0jPgbyA89cnaG2CkfSJY0dXA
# 44n3FEN+Y3vI4opkqJenrJI5RgOmebnh0h6IjwxF/PAN1XnvAtS4ed9B1mQ7wQ/f
# ya83lZwqklEEpMInuNoaEj+4NT6IqsNsH3EqCC1tgu2CYpgXoZ6sLU2ykc2/wKBO
# lLNeh8DMQBUoBsuB9HEwkcvdtm4hGd23q0hjXTs/ph2XVm5jhqU8GS8I12KdhUxb
# 6PH/46SMeKoVah4XxdYoJXJeW2BO8WojGvzOqQdJnoG0Gnqo1HRvQDRAnDLUspZg
# MK0JN1vxoABWUeAZzrQduSf1Gi4RfXHka7zs9kxA48ObVssxggLNMIICyQIBATAs
# MBgxFjAUBgNVBAMTDUF1dG9IYXJkZW4tQ0ECEKG71ppwgt2AQLmLuEU9bJEwCQYF
# Kw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJ
# KoZIhvcNAQkEMRYEFHJyrI0eOYyOgw3+u8DCnzM6AljlMA0GCSqGSIb3DQEBAQUA
# BIICAFAnBYeMgobt6ELJt6Y6W3VKQxJBmRQSG2KzWwFkcOPU0xFP9llbmgRTHUXH
# kodZQ/oNzn4WYK4TpZuJrK9EmWDmXPlEDN3wiawRSiPinKFS9jKh1B8YyrwzC1gQ
# /g9zFmOSiWnnbh+VHUFNJUmW6ZSEiXW3ROCOsc+vpy4p4eSsl+AG5jkEvEbGsPI2
# SpdzumLFLNYmTzzSh1vXTnKvjt+2Yb9m25NIXB5wz90iy/3x5xCEk7ugi2cXsHSt
# kdR0iECnnvi8dxu7S2mhdWQPqKEHdPXn4xwRS7FVFiGm2jYtOBmV+2rnNwQg/Z1E
# RBWhXRzRSRV1B1LVv6BlT1rOVieJ3TsfFH1YbHUOFYz+Kp1Ksc5KAeDPFcvG6osN
# sVzxPA+nDq6pljEJj9Sv62s9m7vzhurryFThRGkH1gcPbe2ikjuJF+Ty2BLoSoQS
# pblwHatysCzwM+UskecF6EyrDWw/6ijbqsqZK0kpa1mxoo3mTXFd2BBOEXiJvT1N
# FdhulKMepJ0geejDyV5LfkPisQKo0joVAZuIFiC2Yjui204/2f7kRA7hrWQyRmuu
# 11C3VltdAPLdlqhzfbl+XuMSFP7Cul6ZGfeR/2IACUNTj1BckJ65ZmTwWkttomhm
# zfl7UHMCbiDf2YDhQbI/1xZiX5TYUJVL/zTYyd4jy/ZTtkTl
# SIG # End signature block
