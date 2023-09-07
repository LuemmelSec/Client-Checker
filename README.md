# Overview  
This is my PowerShell script to automate client pentest / checkups - at least to a certain extend.  
You can use it together with my PwnDoc vulns to further get rid of unneccessary work -> https://github.com/LuemmelSec/PwnDoc-Vulns  

# How
![image](https://github.com/LuemmelSec/Pentest-Tools-Collection/assets/58529760/39b4b892-2d22-4dce-a436-b61d4ac0bfd8)

If possible run as Admin, otherwise some checks might / will fail.  

```
. .\Client-Checker.ps1
```
or
```
import-module .\Client-Checker.ps1
```
or
```
iex(new-object net.webclient).downloadstring("https://raw.githubusercontent.com/LuemmelSec/Pentest-Tools-Collection/main/tools/Client-Checker/Client-Checker.ps1")
```
then just
```
Client-Checker
```

# What does it do  
You should run it as admin, as certain stuff can only be queries with elevated rights.  
It is used to check a client for common misconfigurations. The list currently includes:  
  - Default Domain Password Policy
  - LSA Protection Settings
  - WDAC Usage
  - AppLocker Usage
  - Credential Guard Settings
  - DMA Protection Settings
  - BitLocker Settings
  - Secure Boot Settings
  - System PATH ACL checks
  - Unquoted Service Path checks
  - Always Install Elevated checks
  - UAC checks
  - WSUS Settings
  - PowerShell Settings
  - IPv6 Settings
  - NetBIOS / LLMNR Settings
  - SMB Server Settings
  - Firewall Settings
  - AV Settings
  - Proxy Settings
  - Windows Updates
  - 3rd Party Installations
  - RDP Settings
  - WinRM Settings
  
# The looks
You will have a detailed section which gets generated on the fly with a category, what the script found as well as links to resources for more detail, abuse paths and remmediations.  
![image](https://github.com/LuemmelSec/Pentest-Tools-Collection/assets/58529760/084d6a43-2bcd-4013-a95b-2cc3bf3283a9)

At the very end you will get a tabular overview that will help you to quickly get an overview of all checks done.
![image](https://github.com/LuemmelSec/Pentest-Tools-Collection/assets/58529760/a5b7c4c2-9c05-4dde-9682-66a4409cde78)