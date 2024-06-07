# Overview  
This is a PowerShell script to automate client pentests / checkups - at least to a certain extend.  
You can use it together with my PwnDoc vulns to further get rid of unneccessary work -> https://github.com/LuemmelSec/PwnDoc-Vulns  

# How
![image](https://github.com/LuemmelSec/Client-Checker/assets/58529760/5324bf2e-efc8-47d2-87f1-cecc5a8b7f3a)


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
iex(new-object net.webclient).downloadstring("https://raw.githubusercontent.com/LuemmelSec/Client-Checker/main/Client-Checker.ps1")
```
then just
```
Client-Checker
```

# What does it do  
You should run it as admin, as certain stuff can only be queried with elevated rights.  
It is used to check a client for common misconfigurations. The list currently includes:  
  - Default Domain Password Policy
  - LSA Protection Settings
  - WDAC Usage
  - AppLocker Usage
  - Credential Guard Settings
  - Co-installer Settings
  - DMA Protection Settings
  - BitLocker Settings
  - Secure Boot Settings
  - System PATH ACL checks
  - Unquoted Service Path checks
  - Always Install Elevated checks
  - UAC checks
  - Guest Account checks
  - System Tool access as low priv user checks
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
  - PrintNightmare checks
  - Recall checks
  
# The looks
You will have a detailed section which gets generated on the fly with a category, what the script found as well as links to resources for more detail, abuse paths and remmediations.  
![image](https://github.com/LuemmelSec/Client-Checker/assets/58529760/b65e34d6-38d2-4274-a402-84a5b20c584d)


At the very end you will get a tabular overview that will help you to quickly get an overview of all checks done.
![image](https://github.com/LuemmelSec/Client-Checker/assets/58529760/7bc04ff0-acb0-4277-b249-d175ca61b66c)

