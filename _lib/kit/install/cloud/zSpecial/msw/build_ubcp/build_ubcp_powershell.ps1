
# /bin/PowerShell?

# WARNING: Persistent MSW is *strongly discouraged* for such a native MSW (ie. 'CMD', 'PowerShell') script.
# WARNING: Script may change directory relative to directories which may not exist if some commands fail, causing uncontrolled filesystem damage.



# https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
#  'Go to your classic VM resource. Select Extensions under Settings.' 'Select + Add. In the list of resources, select Custom Script Extension.'

# https://docs.microsoft.com/en-us/azure/automation/learn/automation-tutorial-runbook-textual





# https://docs.microsoft.com/en-us/azure/virtual-machines/custom-data
# ' Custom data is placed in %SYSTEMDRIVE%\AzureData\CustomData.bin as a binary file, but it isn't processed. If you want to process this file, you'll need to build a custom image and write code to process CustomData.bin. '

# https://devkimchi.com/2020/08/26/app-provisioning-on-azure-vm-with-chocolatey-for-live-streaming/
# ' To run the custom script, add this extension to the ARM template. '

# 'RunPowerShellScript'



# https://devkimchi.com/2020/08/26/app-provisioning-on-azure-vm-with-chocolatey-for-live-streaming/
# https://azure.microsoft.com/en-us/blog/chocolatey-with-custom-script-extension-on-azure-vms/

# https://blog.ryanbetts.co.uk/2020/05/installing-docker-ce-on-windows-server.html
# https://www.docker.com/blog/file-sharing-with-docker-desktop/



# MAJOR - # Cygwin/MSW is the only reliable and portable means to control MSW with shell scripts. Possibility of a 'nixexecvm' container managed by 'ubiquitous_bash' with automatic shutdown through filesystem or serial port Inter-Process Communication to automatically call a full Linux VM to act on MSW filesystem, etc. Otherwise, well integrated automated mixed MSW/Linux seems very unlikely.
# MAJOR - MS obviously may perceive incentives to use WSL, possibly also Docker, as vaporware to continue delaying adoption of Linux.

# https://gitlab.com/gitlab-org/gitlab-runner/-/issues/3565
# Tutorial for mixed Linux and Windows containers

# Neither Docker nor WSL should be expected usable on MSW .
# https://blog.ryanbetts.co.uk/2020/05/installing-docker-ce-on-windows-server.html
# https://github.com/actions/virtual-environments/issues/1143
#  'Sorry we don't support Linux container on Windows Server 2016/2019, because the main requirement is Docker Desktop Enterprise. Out of the box, Docker on Windows only run Windows container.'
#  '@h0p3zZ WSL2 has been removed from Windows Server 2022 so it's not possible to run Linux containers in WSL' 'See microsoft/WSL#6301 (comment)' 'commented on 18 Nov 2021'
# https://github.com/microsoft/WSL/issues/6301#issuecomment-858816891
#  'WSL was created to support inner development loop scenarios. The Windows Desktop SKUs (where WSL 2 is supported) are recommended SKUs for these scenarios.'
#  'Telling customers that want to use WSL2 on a Server to use Desktop SKUs just strikes me as an incredibly tone deaf move by Microsoft. Why even have WSL1 on Windows Server at that point?'
#   In other words, MS obviously does not wish to allow well-integrated UNIX/Linux to 
#Install-Module DockerMsftProvider -Force
#Install-Package Docker -ProviderName DockerMsftProvider -Force

# https://stackoverflow.com/questions/15166839/powershell-reboot-and-continue-script
#workflow Script-And-Reboot-And-Script {
  #param ([string]$Name)
  #Do stuff
  #Restart-Computer -Wait
  #Do-MoreStuff
#}
#Script-And-Reboot-And-Script PowerShellWorkflows

# https://docs.microsoft.com/en-us/answers/questions/442463/error-when-enabling-wsl2-in-azure-vm.html
#  'You'll need to choose an Azure VM size that is capable of nested virtualization, check for the SKU Family with Hyper-threaded and capable of running nested virtualization:'



# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Software
choco install git -y
choco install nmap -y
choco install qalculate -y

choco install dos2unix -y

# https://www.reddit.com/r/PowerShell/comments/ofrsue/unattended_nuget_installation/
Install-PackageProvider -Name NuGet -Force -Scope AllUsers -ForceBootstrap

# https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-PowerShell
Install-Module PowerShellGet -Force -SkipPublisherCheck
Install-Module posh-git -Scope CurrentUser -Force
#Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force # Newer beta version with PowerShell Core support
Import-Module posh-git
Add-PoshGitToProfile -AllHosts
Import-Module posh-git

cmd /c "C:\Program Files\Git\bin\git.exe" config --global core.autocrlf input

choco install rclone -y

echo '[mega]
type = type
user = user
pass = pass

' | cmd /c MORE /P > C:\rclone.conf
dos2unix




cmd /c "C:\Program Files\Git\bin\git.exe" clone --recursive --depth 1 https://github.com/mirage335/ubiquitous_bash.git


mkdir ubiquitous_bash
mkdir ./ubiquitous_bash/_local
mkdir ./ubiquitous_bash/_local/ubcp
cd ./ubiquitous_bash/_local/ubcp
.\ubcp-cygwin-portable-installer
cp ubcp_rename-to-enable.cmd ubcp.cmd


cd ../..


cmd /c .\_setupUbiquitous.bat


echo 'begin: mitigate-ubcp'
#./_bin _mitigate-ubcp | tee _mitigate-ubcp.log
./_bin _mitigate-ubcp > _mitigate-ubcp.log
echo 'end: mitigate-ubcp'

./_bin _package-cygwinOnly

./_bin _setup_ubcp



cd ..

rclone --progress --config="/rclone.conf" copy ./ubiquitous_bash/_local/ubcp/package_ubcp-cygwinOnly.tar.xz mega:/zSpecial/dump/






Stop-Computer -ComputerName localhost



