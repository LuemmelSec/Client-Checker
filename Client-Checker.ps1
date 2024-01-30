<#
This is such an awesome script - not
Better run twice, 1x as admin because some shit can not be queried without (e.g. BitLocker status) and 1x as low priv user to check things like software installable as low priv user or access to systemtools like registry etc.
Green = good
Red = Not good
Purple = possibly not good

Author: @LuemmelSec
License: BSD 3-Clause

#>


$results = @()
$elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
function Client-Checker{

    Write-host "##########################################################################################" -ForegroundColor DarkGray
    Write-host "####################################################################+=####################" -ForegroundColor DarkGray
    Write-host "#################################################################*######**################" -ForegroundColor DarkGray
    Write-host "################################################################*=######++################" -ForegroundColor DarkGray
    Write-host "####################################################################**####################" -ForegroundColor DarkGray
    Write-host "###%%%%%%%%%%###########%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%###########+=####################" -ForegroundColor DarkGray
    Write-host "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%@#+======================#%###############################" -ForegroundColor DarkGray
    Write-host "%%%**********%%%%%%%%%%%*******#" -ForegroundColor DarkRed -NoNewline; Write-Host "@::::::::::--::-=::::::::-@###############################" -ForegroundColor DarkGray
    Write-host "+++++++++++++++++++++++++++++++*" -ForegroundColor Red -NoNewline; Write-Host "@::::=-::::::::=+=:::-:::-@%#%%###########################" -ForegroundColor DarkGray
    Write-host "+++----------=++++++++++-------+" -ForegroundColor DarkYellow -NoNewline; Write-Host "@:::::::::::::+****=:-:::-@@%**%%#########################" -ForegroundColor DarkGray
    Write-host "------------------------+++++--=" -ForegroundColor Yellow -NoNewline; Write-Host "@:::::::::--::%+===**=++++#====@@#########################" -ForegroundColor DarkGray
    Write-host "----------------------=#*" -ForegroundColor Green -NoNewline; Write-Host "++*@##%@:::::--::::::%+=====+++++=====@@#########################" -ForegroundColor DarkGray
    Write-host "----------------------+##" -ForegroundColor Blue -NoNewline; Write-Host "*****#%@:::-::::::-*@+===:=+======:-+==*@########################" -ForegroundColor DarkGray
    Write-host "-------------------------++++@%%" -ForegroundColor DarkBlue -NoNewline; Write-Host "@:::-:::::::=@+===*%%-==*#-*%%-=*@########################" -ForegroundColor DarkGray
    Write-host "-------------------------------+" -ForegroundColor Magenta -NoNewline; Write-Host "@::::-:::=-:=@+---=++-=++=-*+=--+@########################" -ForegroundColor DarkGray
    Write-host "---==========-----------======#%" -ForegroundColor DarkMagenta -NoNewline; Write-Host "@::::-:::::::-#+=-=#@%%@@%%@#-=%%#########################" -ForegroundColor DarkGray
    Write-host "++++++++++++++++++++++++++++#####@#++++++++++++%@*************@###########################" -ForegroundColor DarkGray
    Write-host "+++##########*++++++++++####@+=+%%@%**%@%%%%%%%%@**%@%@#**@%##############################" -ForegroundColor DarkGray
    Write-host "############################%%%%###%%%%%#########%%%%##%%%%###############################" -ForegroundColor DarkGray
    Write-host "##########################################################################################" -ForegroundColor DarkGray
    Write-host "##########################################################################################" -ForegroundColor DarkGray
    Write-host "##################################### Client-Checker #####################################" -ForegroundColor DarkGray
    Write-host "##################################### by @LuemmelSec #####################################" -ForegroundColor DarkGray
    Write-host "############################ Automated Client Security Checks ############################" -ForegroundColor DarkGray
    Write-host "##########################################################################################" -ForegroundColor DarkGray
    Write-host ""
    Write-Host "Stuff marked in green is good" -ForegroundColor Green
    Write-Host "Stuff marked in magenta is a 'might be' finding" -ForegroundColor Magenta
    Write-Host "Stuff marked in red is bad stuff" -ForegroundColor Red
    Write-Host "Stuff marked yellow are errors" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If you happen to use PwnDoc or PwnDoc-ng, you can use my templates alongside this tool:"
    Write-Host "https://github.com/LuemmelSec/PwnDoc-Vulns/blob/main/SystemSecurity.yml"
    Write-Host ""

    ########### Preflight Checks ###########

    # Check if we run in elevated context so all checks can be done
    if($elevated -eq $true){
        Write-Host "Local Admin: " -ForegroundColor white -NoNewline; Write-Host $elevated -ForegroundColor Green
        Write-Host "We have superpowers. All checks should go okay." -ForegroundColor DarkGray
        Write-Host ""
    }
    else{
        Write-Host "Local Admin: " -ForegroundColor white -NoNewline; Write-Host $elevated -ForegroundColor Red
        Write-Host "You don't have super powers. Some checks might fail!" -ForegroundColor DarkGray
        Write-Host ""
    }

    # Check if all needed PS modules are installed that we need for the tests
    # Array of module names to check
    Write-Host "Checking for installed PowerShell modules..."
    $moduleNames = @("ActiveDirectory", "BitLocker")

    # Check if modules are installed
    $missingModules = @()
    $installedModules = @()
    foreach ($moduleName in $moduleNames) {
        if (Get-Module -ListAvailable -Name $moduleName) {
            $installedModules += $moduleName
            Write-Host "The '$moduleName' module is installed." -ForegroundColor Green
        } else {
            $missingModules += $moduleName
            Write-Host "The '$moduleName' module is not installed." -ForegroundColor Red
        }
    }

    # Prompt to install missing modules
    if ($missingModules.Count -gt 0) {
        $installModules = Read-Host "Do you want to install the missing modules? (Y/N)"
        if ($installModules -eq "Y" -or $installModules -eq "y") {
            foreach ($module in $missingModules) {
                Write-Host "Installing module '$module'..."
                Install-Module -Name $module -Scope CurrentUser
            }
        }
    }

    ########### Beginning of the actual checks ###########

    # Domain Password Policy checks
    Write-Host ""
    Write-Host "##############################################"
    Write-Host "# Now checking Default Domain Password stuff #"
    Write-Host "##############################################"
    Write-Host "References: https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations?view=o365-worldwide" -ForegroundColor DarkGray
    Write-Host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/account-lockout-duration" -ForegroundColor DarkGray
    Write-Host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/account-lockout-threshold" -ForegroundColor DarkGray
    Write-Host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/store-passwords-using-reversible-encryption" -ForegroundColor DarkGray
    Write-Host ""

    try {
        $defaultPolicy = Get-ADDefaultDomainPasswordPolicy

        if ($defaultPolicy.ComplexityEnabled -eq $false){
            Write-Host "Complexity Enabled: $false" -ForegroundColor Red
            $pwpolicy_complexity = 2
        }
        else {
            Write-Host "Complexity Enabled: $true" -ForegroundColor Green
            $pwpolicy_complexity = 0
        }

        if ($defaultPolicy.lockoutduration.TotalMinutes -gt 14){
            Write-Host "Lockout Duration: $($defaultPolicy.lockoutduration.TotalMinutes)" -ForegroundColor Green
            $pwpolicy_lockoutduration = 0
        }
        elseif ($defaultPolicy.lockoutduration.TotalMinutes -eq 0) {
            Write-Host "Lockout Duration: Will never lock" -ForegroundColor Red
            $pwpolicy_lockoutduration = 2
        }
        else {
            Write-Host "Lockout Duration: $($defaultPolicy.lockoutduration.TotalMinutes)" -ForegroundColor Magenta
            $pwpolicy_lockoutduration = 1
        }

        if ($defaultPolicy.lockoutthreshold -eq 0) {
            Write-Host "Lockout Threshold: Will never lock" -ForegroundColor Red
            $pwpolicy_lockoutthreshold = 2
        }
        elseif ($defaultPolicy.lockoutthreshold -lt 11){
            Write-Host "Lockout Threshold: $($defaultPolicy.lockoutthreshold)" -ForegroundColor Green
            $pwpolicy_lockoutthreshold = 0
        }
        else {
            Write-Host "Lockout Threshold: $($defaultPolicy.lockoutthreshold)" -ForegroundColor Magenta
            $pwpolicy_lockoutthreshold = 1
        }

        if ($defaultPolicy.MinPasswordLength -lt 12){
            Write-Host "Min Password Length: $($defaultPolicy.MinPasswordLength)" -ForegroundColor Red
            $pwpolicy_pwlength = 2
        }
        else {
            Write-Host "Min Password Length: $($defaultPolicy.MinPasswordLength)" -ForegroundColor Green
            $pwpolicy_pwlength = 0
        }

        if ($defaultPolicy.ReversibleEncryptionEnabled -eq $true){
            Write-Host "Reversible Encryption Enabled: $true" -ForegroundColor Red
            $pwpolicy_revenc = 2
        }
        else {
            Write-Host "Reversible Encryption Enabled: $false" -ForegroundColor Green
            $pwpolicy_revenc = 0
        }

        Write-Host "Lockout Duration: $($defaultPolicy.LockoutDuration)" -ForegroundColor DarkGray
        Write-Host "Lockout Observation Window: $($defaultPolicy.LockoutObservationWindow)" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "Failed to query domain information. Check if the domain is accessible." -ForegroundColor Yellow
        $pwpolicy_error = 1
    }


    # Run As PPL checks
    Write-host ""
    Write-host "#####################################"
    Write-host "# Now checking LSA Protection stuff #"
    Write-host "#####################################"
    Write-host "References: https://itm4n.github.io/lsass-runasppl/" -ForegroundColor DarkGray
    Write-host "References: https://learn.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/configuring-additional-lsa-protection" -ForegroundColor DarkGray
    Write-host ""
    try {
        $value = Get-ItemPropertyvalue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "RunAsPPL: Enabled with UEFI Lock" -ForegroundColor Green
            $RunAsPPL = 0
        }
        if ($value -eq 2) {
            Write-Host "RunAsPPL: Enabled without UEFI Lock" -ForegroundColor Green
            $RunAsPPL = 0
        }
        elseif ($value -eq 0) {
            Write-Host "RunAsPPL: Disabled" -ForegroundColor Red
            $RunAsPPL = 2
        }
        else {
            Write-Host "RunAsPPL: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
            $RunAsPPL = 1
        }
    }
    catch {
        Write-Host "RunAsPPL: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        $RunAsPPL = 1
    }

    <# Deprecated due to WDAC checks. According to MS Device Guard is no longer used: https://learn.microsoft.com/en-us/windows/security/threat-protection/device-guard/introduction-to-device-guard-virtualization-based-security-and-windows-defender-application-control
    # Device Guard checks
    Write-host ""
    Write-host "###################################"
    Write-host "# Now checking Device Guard stuff #"
    Write-host "###################################"
    Write-host "References: https://techcommunity.microsoft.com/t5/iis-support-blog/windows-10-device-guard-and-credential-guard-demystified/ba-p/376419" -ForegroundColor DarkGray
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/device-guard/introduction-to-device-guard-virtualization-based-security-and-windows-defender-application-control" -ForegroundColor DarkGray
    Write-host ""
    $computerInfo = Get-ComputerInfo
    $DeviceGuardStatus = $computerInfo.DeviceGuardSmartStatus

    if ($DeviceGuardStatus -eq "Running") {
        Write-Host "Device Guard is enabled." -ForegroundColor Green
    } else {
        Write-Host "Device Guard is not enabled." -ForegroundColor Red
    } #>

    # WDAC checks
    Write-host ""
    Write-host "###########################"
    Write-host "# Now checking WDAC stuff #"
    Write-host "###########################"
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/device-guard/introduction-to-device-guard-virtualization-based-security-and-windows-defender-application-control" -ForegroundColor DarkGray
    Write-host "References: https://learn.microsoft.com/en-us/answers/questions/536416/checking-microsoft-defender-application-control-is" -ForegroundColor DarkGray
    Write-host "References: https://www.stigviewer.com/stig/windows_paw/2017-11-21/finding/V-78163" -ForegroundColor DarkGray
    Write-host "References: https://www.stigviewer.com/stig/windows_paw/2017-11-21/finding/V-78157" -ForegroundColor DarkGray
    Write-host ""
    $deviceGuard = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard

    $CodeIntegrityPolicyEnforcementStatus = $deviceGuard.CodeIntegrityPolicyEnforcementStatus
    $UsermodeCodeIntegrityPolicyEnforcementStatus = $deviceGuard.UsermodeCodeIntegrityPolicyEnforcementStatus

    if ($CodeIntegrityPolicyEnforcementStatus -eq 2) {
        Write-Host "Code Integrity Policy Enforcement is enabled." -ForegroundColor Green
        $wdac_codeintegrity = 0
    }
    elseif ($CodeIntegrityPolicyEnforcementStatus -eq 0) {
        Write-Host "Code Integrity Policy Enforcement is disabled." -ForegroundColor Red
        $wdac_codeintegrity = 2
    }
    elseif ($CodeIntegrityPolicyEnforcementStatus -eq 1) {
        Write-Host "Code Integrity Policy Enforcement is set to observe." -ForegroundColor Magenta
        $wdac_codeintegrity = 1
    }
    else {
        Write-Host "Code Integrity Policy Enforcement status is unknown." -ForegroundColor Red
        $wdac_codeintegrity = 2
    }

    if ($UsermodeCodeIntegrityPolicyEnforcementStatus -eq 2) {
        Write-Host "Usermode Code Integrity Policy Enforcement is enabled." -ForegroundColor Green
        $wdac_usercodeintegrity = 0
    }
    elseif ($UsermodeCodeIntegrityPolicyEnforcementStatus -eq 0) {
        Write-Host "Usermode Code Integrity Policy Enforcement is disabled." -ForegroundColor Red
        $wdac_usercodeintegrity = 2
    }
    elseif ($UsermodeCodeIntegrityPolicyEnforcementStatus -eq 1) {
        Write-Host "Usermode Code Integrity Policy Enforcement is set to observe." -ForegroundColor Magenta
        $wdac_usercodeintegrity = 1
    }
    else {
        Write-Host "Usermode Code Integrity Policy Enforcement status is unknown." -ForegroundColor Red
        $wdac_usercodeintegrity = 2
    }

    # AppLocker checks
    Write-host ""
    Write-host "#################################"
    Write-host "# Now checking AppLocker stuff #"
    Write-host "################################"
    Write-host "References: https://learn.microsoft.com/de-de/windows/security/threat-protection/windows-defender-application-control/applocker/applocker-overview" -ForegroundColor DarkGray
    Write-host ""
    $appLockerService = Get-Service -Name AppIDSvc
    if ($appLockerService.Status -eq "Running") {
        Write-Host "AppLocker is running." -ForegroundColor Green
        $applocker = 0
    } else {
        Write-Host "AppLocker is not running." -ForegroundColor Red
        $applocker = 2
    }

    # UAC checks
    Write-host ""
    Write-host "##################################"
    Write-host "# Now checking if UAC is enabled #"
    Write-host "##################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/application-security/application-control/user-account-control/how-it-works" -ForegroundColor DarkGray
    Write-host ""
    $uacStatus = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA"

    if ($uacStatus.EnableLUA -eq 1) {
        Write-Host "UAC is enabled." -ForegroundColor Green
        $uac = 0
    } else {
        Write-Host "UAC is disabled." -ForegroundColor Red
        $uac = 2
    }

    # Guest Account check
    Write-host ""
    Write-host "############################################"
    Write-host "# Now checking if Guest Account is enabled #"
    Write-host "############################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/accounts-guest-account-status" -ForegroundColor DarkGray
    Write-host ""
    # Get local user accounts
    $guestAccount = Get-CimInstance -ClassName Win32_UserAccount | Where-Object {
        $_.SID -match "-501" # The local Guest Account always has RID 501
    }
    
    # Check if the Guest account exists
    if ($guestAccount) {
        # Check if the Guest account is enabled
        if ($guestAccount.Disabled -eq $false) {
            Write-Host "Guest account enabled" -ForegroundColor Red
            $guestacc = 2
        } else {
            Write-Host "Guest account disabled" -ForegroundColor Green
            $guestacc = 0
        }
    } else {
        Write-Host "Guest account not found" -ForegroundColor Yellow
        $guestacc = 3
    }

    # System Tools as Low Priv User check
    # We only want to check if not ran as admin
    if($elevated -eq $false){ 
    Write-host ""
    Write-host "#######################################################"
    Write-host "# Now checking if Low Priv User can run System Tools  #"
    Write-host "#######################################################"
    Write-host "References: " -ForegroundColor DarkGray
    Write-host ""

    Write-host "We are now trying to open several system tools with our low priv user. Please do only close them manually if they do not autoclose after the test." -ForegroundColor yellow
    Write-host "You may observe error messages when programs were run with UAC, which is absolutely normal, and can be ignored." -ForegroundColor yellow
    Write-host "You need to answer the questions in this PowerShell window!!!" -ForegroundColor yellow
    $response = Read-Host "ARE YOU READY FOR THE TESTS???? (y/n)(Choosing n will skip the tests)"
    if ($response -eq 'y') {
        # Check if can run registry
        $registrySuccess = $null
        try {
            $registrySuccess = Start-Process 'regedit.exe' -PassThru
            $response = Read-Host "Was the registry editor started successfully? (y/n)"
            if ($response -eq 'y') {
                Write-Host "Normal user can run regedit" -ForegroundColor Red
                $stregedit = 2
            } else {
                Write-Host "Normal user cannot run regedit" -ForegroundColor Green
                $stregedit = 0
            }
        } catch {
            Write-Host "An error occured" -ForegroundColor yellow
            $stregedit = 3
        } finally {
            if ($registrySuccess) {
                Stop-Process -Id $registrySuccess.Id -Force
            }
        }
    
        # Check if can run cmd
        $cmdSuccess = $null
        try {
            $cmdSuccess = Start-Process 'cmd.exe' -PassThru
            $response = Read-Host "Was the command prompt started successfully? (y/n)"
            if ($response -eq 'y') {
                Write-Host "Normal user can run cmd" -ForegroundColor Red
                $stcmd = 2
            } else {
                Write-Host "Normal user cannot run cmd" -ForegroundColor Green
                $stcmd = 0
            }
        } catch {
            Write-Host "An error occured" -ForegroundColor yellow
            $stcmd = 3
        } finally {
            if ($cmdSuccess) {
                Stop-Process -Id $cmdSuccess.Id -Force
            }
        }
    
        # Check if can run PowerShell
        $powershellSuccess = $null
        try {
            $powershellSuccess = Start-Process 'powershell.exe' -PassThru 
            $response = Read-Host "Was PowerShell started successfully? (y/n)"
            if ($response -eq 'y') {
                Write-Host "Normal user can run PowerShell" -ForegroundColor Red
                $stpowershell = 2
            } else {
                Write-Host "Normal user cannot run PowerShell" -ForegroundColor Green
                $stpowershell = 0
            }
        } catch {
            Write-Host "An error occured" -ForegroundColor yellow
            $stpowershell = 3
        } finally {
            if ($powershellSuccess) {
                Stop-Process -Id $powershellSuccess.Id -Force
            }
        }    
            } 
        elseif ($response -eq 'n') {
            Write-Host "Okay, we will skip those" -ForegroundColor Red
        }
        else {
            Write-Host "God dammit, only y or n!!!" -ForegroundColor yellow
        }
    }
        
    # Always install elevated active?
    Write-host ""
    Write-host "######################################################"
    Write-host "# Now checking if Always Install Elevated is enabled #"
    Write-host "######################################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows/win32/msi/alwaysinstallelevated" -ForegroundColor DarkGray
    Write-host "References: https://pentestlab.blog/2017/02/28/always-install-elevated/" -ForegroundColor DarkGray
    Write-host ""
    $keysToCheck = @(
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Installer",
    "Registry::HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Installer"
    )

    $enabled = $false

    foreach ($keyPath in $keysToCheck) {
        $alwaysInstallElevated = Get-ItemProperty -Path $keyPath -Name "AlwaysInstallElevated" -ErrorAction SilentlyContinue

        if ($alwaysInstallElevated -ne $null) {
            if ($alwaysInstallElevated.AlwaysInstallElevated -eq 1) {
                $enabled = $true
                break  # Exit the loop if enabled in any of the keys
            }
        }
    }

    if ($enabled) {
        Write-Host "Always install elevated is active." -ForegroundColor Red
        $aie = 2
    } else {
        Write-Host "Always install elevated is not active." -ForegroundColor Green
        $aie = 0
    }

    # Credential Guard checks
    Write-host ""
    Write-host "#######################################"
    Write-host "# Now checking Credential Guard stuff #"
    Write-host "#######################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard-manage" -ForegroundColor DarkGray
    Write-host ""
    $credentialGuardEnabled = (Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard).SecurityServicesRunning

    if ($credentialGuardEnabled -eq 1) {
        Write-Host "Credential Guard is enabled." -ForegroundColor Green
        $credguard = 0
    } else {
        Write-Host "Credential Guard  is not enabled." -ForegroundColor red
        $credguard = 2
    }

    # Co-Installer checks
    Write-host ""
    Write-host "###################################"
    Write-host "# Now checking Co-installer stuff #"
    Write-host "###################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows-hardware/drivers/install/registering-a-device-specific-co-installer" -ForegroundColor DarkGray
    Write-host "References: https://www.bleepingcomputer.com/news/microsoft/how-to-block-windows-plug-and-play-auto-installing-insecure-apps" -ForegroundColor DarkGray
    Write-host "References: https://www.scip.ch/en/?labs.20211209" -ForegroundColor DarkGray
    Write-host ""
    try {
        $value = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer" -Name "DisableCoInstallers" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "Allow installation of Co-installers: Disabled" -ForegroundColor Green
            $coinstaller = 0
        }
        elseif ($value -eq 0) {
            Write-Host "Allow installation of Co-installers: Enabled" -ForegroundColor Red
            $coinstaller = 2
        }
    }
    catch {
        Write-Host "Allow installation of Co-installers: Error (probably regkey doesn't exist - hence enabled)" -ForegroundColor Red
        $coinstaller = 2
    }

    # DMA protection related stuff
    Write-host ""
    Write-host "#####################################"
    Write-host "# Now checking DMA Protection stuff #"
    Write-host "#####################################"
    Write-host "References: https://www.synacktiv.com/en/publications/practical-dma-attack-on-windows-10.html" -ForegroundColor DarkGray
    Write-host "References: https://www.scip.ch/?labs.20211209" -ForegroundColor DarkGray
    Write-host "References: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-dataprotection" -ForegroundColor DarkGray
    Write-host ""
    try {
        $value = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceLock" -Name "AllowDirectMemoryAccess" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "AllowDirectMemoryAccess: Enabled" -ForegroundColor Red
            $dma_access = 2
        }
        elseif ($value -eq 0) {
            Write-Host "AllowDirectMemoryAccess: Disabled" -ForegroundColor Green
            $dma_access = 0
        }
        else {
            Write-Host "AllowDirectMemoryAccess: Error (probably regkey doesn't exist - hence enabled)" -ForegroundColor Magenta
            $dma_access = 1
        }
    }
    catch {
        Write-Host "AllowDirectMemoryAccess: Error (probably regkey doesn't exist - hence enabled)" -ForegroundColor Magenta
        $dma_access = 1
    }

    try {
        $value = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "EnableVirtualizationBasedSecurity: Enabled" -ForegroundColor Green
            $dma_vbs = 0
        }
        elseif ($value -eq 0) {
            Write-Host "EnableVirtualizationBasedSecurity: Disabled" -ForegroundColor Red
            $dma_vbs = 2
        }
        else {
            Write-Host "EnableVirtualizationBasedSecurity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
            $dma_vbs = 1
        }
    }
    catch {
        Write-Host "EnableVirtualizationBasedSecurity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        $dma_vbs = 1
    }

    try {
        $value = Get-ItemPropertyValue -Path Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "HypervisorEnforcedCodeIntegrity: Enabled" -ForegroundColor Green
            $dma_heci = 0
        }
        elseif ($value -eq 0) {
            Write-Host "HypervisorEnforcedCodeIntegrity: Disabled" -ForegroundColor Red
            $dma_heci = 2
        }
        else {
            Write-Host "HypervisorEnforcedCodeIntegrity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
            $dma_heci = 1
        }
    }
    catch {
        Write-Host "HypervisorEnforcedCodeIntegrity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        $dma_heci = 1
    }

    try {
        $value = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "LockConfiguration" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Enabled" -ForegroundColor Green
            $dma_heci_locked = 0
        }
        elseif ($value -eq 0) {
            Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Disabled" -ForegroundColor Red
            $dma_heci_locked = 2
        }
        else {
            Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
            $dma_heci_locked = 1
        }
    }
    catch {
        Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        $dma_heci_locked = 1
    }

    # BitLocker status
    Write-host ""
    Write-host "###################################"
    Write-host "# Now checking BitLocker settings #"
    Write-host "# If TPM only > possibly insecure #"
    Write-host "###################################"
    Write-host "References: https://learn.microsoft.com/en-us/powershell/module/bitlocker/add-bitlockerkeyprotector?view=windowsserver2022-ps" -ForegroundColor DarkGray
    Write-host "References: https://luemmelsec.github.io/Go-away-BitLocker-you-are-drunk/" -ForegroundColor DarkGray
    Write-host ""
    $volumes = $null
    $bl_greenCount = 0
    $bl_magentaCount = 0
    $bl_redCount = 0
    $bl_yellowCount = 0
    try {
        $volumes = Get-BitLockerVolume -ErrorAction Stop
        foreach ($volume in $volumes) {
            $volumeLabel = $volume.MountPoint
            $bitLockerStatus = $volume.ProtectionStatus
            $keyProtectorType = $volume.KeyProtector.KeyProtectorType

            if ($bitLockerStatus -eq "On") {
                Write-Host "BitLocker on volume $volumeLabel - enabled" -ForegroundColor Green
                $bl_greenCount++

                if ($keyProtectorType -like "*ExternalKey*") {
                    Write-Host "Protection of key material on volume $volumeLabel - possibly insecure" -ForegroundColor Magenta
                    $bl_magentaCount++
                }
                elseif ($keyProtectorType -like "*key*" -or $keyProtectorType -like "*pin*") {
                    Write-Host "Protection of key material on volume $volumeLabel - okay" -ForegroundColor Green
                    $bl_greenCount++
                }
                else {
                    Write-Host "Protection of key material on volume $volumeLabel - possibly insecure" -ForegroundColor Magenta
                    $bl_magentaCount++
                }
            }
            else {
                Write-Host "BitLocker on volume $volumeLabel - disabled" -ForegroundColor Red
                $bl_redCount++
            }
        }
    } catch {
        $errorMessage = $_.Exception.Message
        if ($errorMessage -like "*Access Denied*") {
            Write-Host "Could not query the information with current rights." -ForegroundColor Yellow
            $bl_yellowCount++
        } else {
            Write-Host "An error occurred: $errorMessage" -ForegroundColor Red
            $bl_redCount++
        }
    }

    # Secure Boot enabled?
    Write-host ""
    Write-host "#####################################"
    Write-host "# Now checking Secure Boot settings #"
    Write-host "#####################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/oem-secure-boot" -ForegroundColor DarkGray
    Write-host ""
    try {
        $value = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State" -Name "UEFISecureBootEnabled" -ErrorAction Stop

        if ($value.UEFISecureBootEnabled -eq 1) {
            Write-Host "Secure Boot is enabled" -ForegroundColor Green
            $secureboot = 0
        }
        elseif ($value.UEFISecureBootEnabled -eq 0) {
            Write-Host "Secure Boot is disabled" -ForegroundColor Red
            $secureboot = 2
        }
    }
    catch {
        Write-Host "Secure Boot settings: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Red
        $secureboot = 2
    }

    # Can the Users group write to SYSTEM PATH folders > Hijacking possibilities?
    Write-host ""
    Write-host "###########################################################"
    Write-host "# Now checking ACLs on folders from `$PATH System variable #"
    Write-host "###########################################################"
    Write-host "References: https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation/dll-hijacking/writable-sys-path-+dll-hijacking-privesc" -ForegroundColor DarkGray
    Write-host ""
    $spa_greenCount = 0
    $spa_redCount = 0
    $env:Path -split ';' | ForEach-Object {
        $folder = $_

        if (Test-Path -Path $folder) {
            $acl = Get-Acl -Path $folder
            $usersGroup = New-Object System.Security.Principal.NTAccount("BUILTIN", "Users")
            $usersAccess = $acl.Access | Where-Object { $_.IdentityReference -eq $usersGroup -and $_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Write }

            if ($usersAccess -ne $null) {
                Write-Host "Members of the Users Group can write to folder: $folder" -ForegroundColor Red
                $spa_redCount++
            } else {
                Write-Host "Members of the Users Group cannot write to folder: $folder" - -ForegroundColor Green
                $spa_greenCount++
            }
        } else {
            Write-Host "Folder does not exist: $folder"
        }
    }

    # Do we have unqoted service paths? > Hijacking possibilities?
    Write-host ""
    Write-host "###########################################"
    Write-host "# Now checking for unquoted service paths #"
    Write-host "###########################################"
    Write-host "References: https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation/dll-hijacking/writable-sys-path-+dll-hijacking-privesc" -ForegroundColor DarkGray
    Write-Host "References: https://github.com/itm4n/PrivescCheck/tree/master" -ForegroundColor DarkGray
    Write-host ""
    $uqsp_redcount = 0
    $services = Get-CimInstance -Class Win32_Service -Property Name, DisplayName, PathName, StartMode |
    Where-Object {
        $_.PathName -notlike "C:\Windows*" -and
        $_.PathName -notlike '"*"*' -and
        $_.PathName -ne $null
    }

    foreach ($service in $services) {
        $serviceName = $service.Name
        $path = $service.PathName
        $displayName = $service.DisplayName
        $startMode = $service.StartMode

        Write-Host "Service Name: $($serviceName)" -ForegroundColor Red
        Write-Host "Path: $($path)" -ForegroundColor Red
        Write-Host "Display Name: $($displayName)" -ForegroundColor Red
        Write-Host "Start Mode: $($startMode)" -ForegroundColor Red
        Write-Host "" -ForegroundColor Red
        $uqsp_redcount++
    }

    # Check if WSUS is fetching updates over HTTP instaed of HTTPS?
    Write-host ""
    Write-host "##############################"
    Write-host "# Now checking WSUS settings #"
    Write-host "##############################"
    Write-host "References: https://www.gosecure.net/blog/2020/09/03/wsus-attacks-part-1-introducing-pywsus/" -ForegroundColor DarkGray
    Write-host ""
    try {
        $wsusPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

        if (Test-Path -Path $wsusPath) {
            $wsusConfiguration = Get-ItemProperty -Path $wsusPath -Name "WUServer"
            $wsusServerUrl = $wsusConfiguration.WUServer

            if ($wsusServerUrl -match "^http://") {
                Write-Host "WSUS updates are fetched over HTTP." -ForegroundColor Red
                $wsus = 2
            } else {
                Write-Host "WSUS updates are not fetched over HTTP." -ForegroundColor Green
                $wsus = 0
            }
        } else {
            Write-Host "WSUS is not configured." -ForegroundColor Green
            $wsus = 0
        }
    } catch {
        Write-Host "An error occurred while checking the WSUS configuration."
        $wsus = 3
    }

    # PowerShell related checks
    Write-host ""
    Write-host "####################################"
    Write-host "# Now checking PowerShell settings #"
    Write-host "####################################"
    Write-host "References: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.3" -ForegroundColor DarkGray
    Write-host ""

    # Check if PowerShell v2 can be run
    $psVersion2Enabled = $false

    $psInfo = New-Object System.Diagnostics.ProcessStartInfo
    $psInfo.FileName = 'powershell.exe'
    $psInfo.Arguments = '-Version 2 -NoExit -Command "exit"'
    $psInfo.RedirectStandardOutput = $true
    $psInfo.RedirectStandardError = $true
    $psInfo.UseShellExecute = $false
    $psInfo.CreateNoWindow = $true

    $psProcess = New-Object System.Diagnostics.Process
    $psProcess.StartInfo = $psInfo

    try {
        [void]$psProcess.Start()
        [void]$psProcess.WaitForExit()

        if ($psProcess.ExitCode -eq 0) {
            $psVersion2Enabled = $true
        }
    } finally {
        [void]$psProcess.Dispose()
    }

    if ($psVersion2Enabled) {
        Write-Host "PowerShell v2 can be run." -ForegroundColor Red
        $ps_v2 = 2
    } else {
        Write-Host "PowerShell v2 cannot be run." -ForegroundColor Green
        $ps_v2 = 0
    }

    # Check the execution policy
    $executionPolicy = Get-ExecutionPolicy
    if ($executionPolicy -eq "AllSigned") {
        Write-Host "Execution Policy is $executionPolicy" -ForegroundColor Green
        $ps_ep = 0
    } elseif ($executionPolicy -eq "Unrestricted" -or $executionPolicy -eq "Bypass") {
        Write-Host "Execution Policy is $executionPolicy" -ForegroundColor Red
        $ps_ep = 2
    } else {
        Write-Host "Execution Policy is $executionPolicy" -ForegroundColor Magenta
        $ps_ep = 1
    }

    # Check the language mode
    $languageMode = $ExecutionContext.SessionState.LanguageMode
    if ($languageMode -eq "FullLanguage") {
        Write-Host "Language Mode is $languageMode" -ForegroundColor Red
        $ps_lm = 2
    } else {
        Write-Host "Language Mode is $languageMode" -ForegroundColor Green
        $ps_lm = 0
    }

    # IPv6 settings
    Write-host ""
    Write-host "##############################"
    Write-host "# Now checking IPv6 settings #"
    Write-host "##############################"
    Write-host "References: https://blog.fox-it.com/2018/01/11/mitm6-compromising-ipv4-networks-via-ipv6/" -ForegroundColor DarkGray
    Write-host "References: https://www.blackhillsinfosec.com/mitm6-strikes-again-the-dark-side-of-ipv6/" -ForegroundColor DarkGray
    Write-host ""

    $adapterStatus = Get-NetAdapterBinding | Where-Object {$_.ComponentID -eq "ms_tcpip6"} | Select-Object -Property Name, Enabled
    $adapterStatus | ForEach-Object {
        $adapterName = $_.Name
        if (-not $_.Enabled) {
            Write-Host "IPv6 is disabled on Adapter $adapterName." -ForegroundColor Green
            $ipv6 = 0
        } else {
            Write-Host "IPv6 is enabled on Adapter $adapterName." -ForegroundColor Red
            $ipv6 = 2
        }
    }

    # NetBIOS Name Resolution and LLMNR checks
    Write-host ""
    Write-host "#########################################"
    Write-host "# Now checking NetBIOS / LLMNR settings #"
    Write-host "#########################################"
    Write-host "References: https://luemmelsec.github.io/Relaying-101/" -ForegroundColor DarkGray
    Write-host ""

    # Check if LLMNR is enabled or disabled
    $dnsClientKey = "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient"
    try {
        $llmnrValue = (Get-ItemProperty -Path $dnsClientKey -Name "EnableMulticast" -ErrorAction Stop).EnableMulticast

        if ($llmnrValue -eq 0) {
            Write-Host "LLMNR status: disabled" -ForegroundColor Green
            $llmnr = 0
        } elseif ($llmnrValue -eq 1) {
            Write-Host "LLMNR status: enabled" -ForegroundColor Red
            $llmnr = 2
        }
    } catch {
        Write-Host "LLMNR status: reg key not found - hence enabled" -ForegroundColor Red
        $llmnr = 2
    }

    # Check if NetBIOS is enabled for each network adapter
    $netbtInterfacePath = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces"
    $adapterKeys = Get-ChildItem -Path $netbtInterfacePath -ErrorAction SilentlyContinue

    $netbiosEnabled = $false
    $enabledAdapters = @()

    foreach ($adapterKey in $adapterKeys) {
        $adapterName = $adapterKey.PSChildName
        if ($adapterName -like "Tcpip_*") {
            $adapterName = $adapterName -replace "^Tcpip_", ""

            $netbiosOptions = (Get-ItemProperty -Path "$netbtInterfacePath\$($adapterKey.PSChildName)" -Name "NetbiosOptions" -ErrorAction SilentlyContinue).NetbiosOptions

            if ($netbiosOptions -eq 1 -or $netbiosOptions -eq 0) {
                $netbiosEnabled = $true
                $enabledAdapters += $adapterName
            }
        }
    }

    if ($netbiosEnabled) {
        Write-Host "NetBIOS status: Enabled on at least one network adapter" -ForegroundColor Red
        $netbios = 2
        Write-Host ""
        foreach ($adapter in $enabledAdapters) {
            $adapterInstance = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.SettingID -like "*$adapter*" }
            Write-Host $adapterInstance.Description -ForegroundColor Red
        }
    }
    else {
        Write-Host "NetBIOS status: Not enabled on any network adapter" -ForegroundColor Green
        $netbios = 0
        }


    # SMB Checks
    Write-host ""
    Write-host "####################################"
    Write-host "# Now checking SMB Server settings #"
    Write-host "####################################"
    Write-host "References: https://luemmelsec.github.io/Relaying-101/" -ForegroundColor DarkGray
    Write-host "References: https://techcommunity.microsoft.com/t5/storage-at-microsoft/configure-smb-signing-with-confidence/ba-p/2418102" -ForegroundColor DarkGray
    Write-host ""

    $smbConfig = Get-SmbServerConfiguration

    # Check SMB1 settings
    if ($smbConfig.EnableSMB1Protocol) {
        Write-Host "SMB version 1 is used. No Signing available here!!!" -ForegroundColor Red
        $smb_v1 = 2
    } else {
        Write-Host "SMB version 1 is not used" -ForegroundColor Green
        $smb_v1 = 0
    }

    # Check SMB Signing settings
    if ($smbConfig.RequireSecuritySignature) {
        Write-Host "SMB signing is enabled for SMB2 and newer" -ForegroundColor Green
        $smb_sig = 0
    } else {
        Write-Host "SMB signing is disabled for SMB2 and newer" -ForegroundColor Red
        $smb_sig = 2
    }

    # Firewall Checks
    Write-host ""
    Write-host "##################################"
    Write-host "# Now checking Firewall settings #"
    Write-host "##################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/best-practices-configuring" -ForegroundColor DarkGray
    Write-host ""

    try {
        $firewallProfile = Get-NetFirewallProfile -Profile Domain, Public, Private -ErrorAction Stop

        if ($firewallProfile.Enabled) {
            Write-Host "Windows Firewall is enabled." -ForegroundColor Magenta
            Write-Host "Firewall Rules (check them for dangerous stuff):" -ForegroundColor Magenta

            # Get all Firewall rules
            $firewallRules = Get-NetFirewallRule 2>&1

            if ($firewallRules -match "Access is denied") {
                Write-Host "Could not query the information with current rights." -ForegroundColor Yellow
                $firewall = 3
            }
            elseif ($firewallRules) {
                $ruleTable = @()
                $firewall = 1
                foreach ($rule in $firewallRules) {
                    $ruleName = $rule.Name

                    # The ports are not stored directly in the rules but in the associated Port Filter set
                    $portFilters = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $rule -ErrorAction SilentlyContinue

                    $localAddresses = @()
                    $remoteAddresses = @()

                    # Local and remote addresses are not directly stored in the rule but in the associated Address Filter set
                    $addressFilters = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $rule -ErrorAction SilentlyContinue
                    foreach ($addressFilter in $addressFilters) {
                        if ($addressFilter.LocalAddress -ne "*") {
                            $localAddresses += $addressFilter.LocalAddress
                        }

                        if ($addressFilter.RemoteAddress -ne "*") {
                            $remoteAddresses += $addressFilter.RemoteAddress
                        }
                    }

                    $localAddress = if ($localAddresses) { $localAddresses -join ', ' } else { "N/A" }
                    $remoteAddress = if ($remoteAddresses) { $remoteAddresses -join ', ' } else { "N/A" }

                    $ruleEntry = [PSCustomObject]@{
                        "Rule Name"        = $rule.DisplayName
                        "Action"           = $rule.Action
                        "Enabled"          = $rule.Enabled
                        "Protocol"         = $rule.Protocol
                        "Allowed Ports"    = if ($portFilters) { $portFilters.LocalPort -join ', ' } else { "None" }
                        "Direction"        = $rule.Direction
                        "Local Address"    = $localAddress
                        "Remote Address"   = $remoteAddress
                    }

                    $ruleTable += $ruleEntry
                }

                $ruleTable | Format-Table -AutoSize
            } else {
                Write-Host "No firewall rules found." -ForegroundColor Green
                $firewall = 0
            }
        } else {
            Write-Host "Windows Firewall is disabled." -ForegroundColor Red
            $firewall = 2
        }
    } catch {
        Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Yellow
        $firewall = 3
    }



    # AV Checks
    Write-host ""
    Write-host "############################"
    Write-host "# Now checking AV settings #"
    Write-host "############################"
    Write-host "References: https://www.itnator.net/antivirus-status-auslesen-mit-powershell/" -ForegroundColor DarkGray
    Write-host ""

    # Produkt Status Flags
    [Flags()] enum ProductState {
        Off         = 0x0000
        On          = 0x1000
        Snoozed     = 0x2000
        Expired     = 0x3000
    }

    # Signature Status Flags
    [Flags()] enum SignatureStatus {
        UpToDate     = 0x00
        OutOfDate    = 0x10
    }

    # Product Owner Flags
    [Flags()] enum ProductOwner {
        NotMS        = 0x000
        Windows      = 0x100
    }

    [Flags()] enum ProductFlags {
        SignatureStatus = 0x00F0
        ProductOwner    = 0x0F00
        ProductState    = 0xF000
    }

    # Get installed AV software
    $avinfo = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct

    # if more AV installed...
    foreach ($av in $avinfo) {
        # get status in decimal
        $state = $av.productState
        # convert decimal to hex
        $state = '0x{0:x}' -f $state

        # decode flags
        $productStatus = [ProductState]($state -band [ProductFlags]::ProductState)
        $signatureStatus = [SignatureStatus]($state -band [ProductFlags]::SignatureStatus)

        if ($productStatus -eq "On") {
            Write-Host "Name: $($av.displayName)"
            Write-Host "Product Status: $($productStatus.ToString())" -ForegroundColor Green
            $av_on = 0

            if ($signatureStatus -ne "UpToDate") {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Red
                $av_utd = 2
            } else {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Green
                $av_utd = 0
            }

            Write-Host ""
        } elseif ($productStatus -eq "Snoozed") {
            Write-Host "Name: $($av.displayName)"
            Write-Host "Product Status: $($productStatus.ToString())" -ForegroundColor Magenta
            $av_on = 1

            if ($signatureStatus -ne "UpToDate") {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Red
                $av_utd = 2
            } else {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Green
                $av_utd = 0
            }

            Write-Host ""
        } else {
            Write-Host "Name: $($av.displayName)"
            Write-Host "Product Status: $($productStatus.ToString())" -ForegroundColor Red
            $av_on = 2

            if ($signatureStatus -ne "UpToDate") {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Red
                $av_utd = 2
            } else {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Green
                $av_utd = 0
            }

            Write-Host ""
        }
    }
    Write-Host "Don't forget to check exclusions!" -ForegroundColor Magenta

    # Proxy Checks
    Write-host ""
    Write-host "###############################"
    Write-host "# Now checking Proxy settings #"
    Write-host "###############################"
    Write-host "References: " -ForegroundColor DarkGray
    Write-host ""

    $proxySettings = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'

    if ($proxySettings.ProxyEnable) {
        Write-Host "Proxy enabled: Yes - check if it does a good job or not" -ForegroundColor Magenta
        Write-Host "Proxy Server: $($proxySettings.ProxyServer)" -ForegroundColor Magenta
        Write-Host "Bypass list: $($proxySettings.ProxyOverride)" -ForegroundColor Magenta
        $proxy_enabled = 1
    } else {
        Write-Host "Proxy enabled: No" -ForegroundColor Red
        $proxy_enabled = 2
    }

    if ($proxySettings.AutoConfigUrl) {
        Write-Host "Auto Config set: Yes - check if it does a good job or not" -ForegroundColor Magenta
        Write-Host "Automatic Configuration URL: $($proxySettings.AutoConfigUrl)" -ForegroundColor Magenta
        $proxy_autoconfig = 1
    } else {
        Write-Host "Auto Config set: No" -ForegroundColor Red
        $proxy_autoconfig = 2
    }


    # Windows Update Checks
    Write-host ""
    Write-host "################################"
    Write-host "# Now checking Windows Updates #"
    Write-host "################################"
    Write-host "References: " -ForegroundColor DarkGray
    Write-host ""

    $UpdateSession = New-Object -ComObject "Microsoft.Update.Session"
    $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
    $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and IsHidden=0")
    $pendingUpdates = $SearchResult.Updates | Where-Object { $_.Categories.Count -eq 0 -or $_.Categories.CategoryID -notcontains "Installed" }
    $importantUpdates = $pendingUpdates | Where-Object { $_.Categories.CategoryID -eq "ImportantUpdates" }
    $systemUpToDate = $importantUpdates.Count -eq 0

    if ($systemUpToDate) {
        Write-Host "System is up-to-date." -ForegroundColor Green
        $winupdate = 0
    } else {
        Write-Host "System is not up-to-date." -ForegroundColor Red
        $winupdate = 2
    }

    Write-Host ""

    if ($importantUpdates.Count -gt 0) {
        Write-Host "Pending Important Updates:" -ForegroundColor Red
        foreach ($update in $importantUpdates) {
            Write-Host "- $($update.Title)" -ForegroundColor Red
        }
    }

    $otherUpdates = $pendingUpdates | Where-Object { $_.Categories.CategoryID -ne "ImportantUpdates" }

    if ($otherUpdates.Count -gt 0) {
        Write-Host "Pending Other Updates:" -ForegroundColor Magenta
        $winupdate = 1
        foreach ($update in $otherUpdates) {
            Write-Host "- $($update.Title)" -ForegroundColor Magenta
        }
    }

    if ($systemUpToDate -and $otherUpdates.Count -eq 0) {
        Write-Host "No pending updates." -ForegroundColor Green
        $winupdate = 0
    }

    # Installed Software Checks
    Write-host ""
    Write-host "###################################"
    Write-host "# Now checking installed Software #"
    Write-host "###################################"
    Write-host "References: " -ForegroundColor DarkGray
    Write-host ""

    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" |
                         Get-ItemProperty |
                         Select-Object DisplayName, DisplayVersion, @{n='InstallDate';e={([datetime]::ParseExact($_.InstallDate,'yyyyMMdd',$null)).ToString('dd-MM-yyyy')}}

    $InstalledSoftware += Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
                          Get-ItemProperty |
                          Select-Object DisplayName, DisplayVersion, @{n='InstallDate';e={([datetime]::ParseExact($_.InstallDate,'yyyyMMdd',$null)).ToString('dd-MM-yyyy')}}

    $InstalledSoftware += Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" |
                          Get-ItemProperty |
                          Select-Object DisplayName, DisplayVersion, @{n='InstallDate';e={([datetime]::ParseExact($_.InstallDate,'yyyyMMdd',$null)).ToString('dd-MM-yyyy')}}
    $InstalledSoftware | Sort-Object DisplayName | Format-Table -AutoSize


    # RDP Checks
    Write-host ""
    Write-host "##########################"
    Write-host "# Now checking RDP stuff #"
    Write-host "##########################"
    Write-host "References: https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_SECURITY_LAYER_POLICY" -ForegroundColor DarkGray
    Write-host "References: https://viperone.gitbook.io/pentest-everything/everything/everything-active-directory/adversary-in-the-middle/rdp-mitm" -ForegroundColor DarkGray
    Write-host "References: https://www.tenable.com/plugins/nessus/18405" -ForegroundColor DarkGray
    Write-host ""

    # Check if RDP is enabled
    $rdpEnabled = Get-CimInstance -Namespace "root/CIMv2/TerminalServices" -ClassName "Win32_TerminalServiceSetting" | Select-Object -ExpandProperty AllowTSConnections
    if ($rdpEnabled -eq 1) {
        Write-Host "Remote Desktop is enabled." -ForegroundColor Magenta
        $rdp_enabled = 1
    } else {
        Write-Host "Remote Desktop is disabled." -ForegroundColor Green
        $rdp_enabled = 0
    }

    # Check Security Settings for RDP
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
    $securityLayer = (Get-ItemProperty -Path $regPath -Name "SecurityLayer").SecurityLayer
    switch ($securityLayer) {
        0 {
            Write-Host "RDP Security Layer: Disabled" -ForegroundColor Red
            $rdp_sec = 2
            break
        }
        1 {
            Write-Host "RDP Security Layer: Negotiate" -ForegroundColor Magenta
            $rdp_sec = 1
            break
        }
        2 {
            Write-Host "RDP Security Layer: SSL" -ForegroundColor Green
            $rdp_sec = 0
            break
        }
        default {
            Write-Host "RDP Security Layer: Unknown" -ForegroundColor Yellow
            $rdp_sec = 3
            break
        }
    }

    # Check local NLA enforcement
    $regKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
    $regValueName = 'UserAuthentication'

    $userAuthentication = (Get-ItemProperty -Path $regKeyPath -Name $regValueName).$regValueName

    if ($userAuthentication -eq 1) {
        Write-Host "NLA (Network Level Authentication) is enforced." -ForegroundColor Green
        $rdp_nla = 0
    } else {
        Write-Host "NLA (Network Level Authentication) is not enforced." -ForegroundColor Red
        $rdp_nla = 2
    }

    # WinRM Checks
    Write-host ""
    Write-host "############################"
    Write-host "# Now checking WinRM stuff #"
    Write-host "############################"
    Write-host "References: https://learn.microsoft.com/en-us/powershell/scripting/learn/remoting/winrmsecurity?view=powershell-7.3" -ForegroundColor DarkGray
    Write-host ""

    # Check if WinRM service is running
    $winrmService = Get-Service -Name "winrm"

    if ($winrmService.Status -eq "Running") {
        Write-Host "WinRM service is running." -ForegroundColor Magenta
        $winrm = 1

        # Retrieve WinRM configuration
        $winrmSettings = winrm get winrm/config

        # Display the security settings
        Write-Host "WinRM Security Settings:" -ForegroundColor Magenta
        $winrmSettings
    }
    else {
        Write-Host "WinRM service is not running." -ForegroundColor Green
        $winrm = 0
    }

    # PrintNightmare Checks
    Write-host ""
    Write-host "#####################################"
    Write-host "# Now checking PrintNightmare stuff #"
    Write-host "#####################################"
    Write-host "References: https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.Printing::RestrictDriverInstallationToAdministrators" -ForegroundColor DarkGray
    Write-host "References: https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.Printing::PointAndPrint_Restrictions" -ForegroundColor DarkGray
    Write-host "References: https://support.microsoft.com/en-gb/topic/kb5005652-manage-new-point-and-print-default-driver-installation-behavior-cve-2021-34481-873642bf-2634-49c5-a23b-6d8e9a302872" -ForegroundColor DarkGray
    Write-host "References: https://itm4n.github.io/printnightmare-exploitation/" -ForegroundColor DarkGray
    Write-host ""

    # Check if normal users can install package aware printer drivers
    try {
        $value = Get-ItemPropertyvalue -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "RestrictDriverInstallationToAdministrators" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "Only Admins can install package aware printer drivers." -ForegroundColor Green
            $printnightmare_pa = 0
        }
        elseif ($value -eq 0) {
            Write-Host "Normal users can install package aware printer drivers." -ForegroundColor Red
            $printnightmare_pa = 2
        }
        else {
            Write-Host "Install package aware printer driver as lowpriv user: regkey doesn't exist - hence disabled" -ForegroundColor Green
            $printnightmare_pa = 0
        }
    }
    catch {
        Write-Host "Install package aware printer driver as lowpriv user: regkey doesn't exist - hence disabled" -ForegroundColor Green
        $printnightmare_pa = 0
    }

    # Check if normal users can install non package aware printer drivers
    # Drivers for new connections
    try {
        $value = Get-ItemPropertyvalue -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "NoWarningNoElevationOnInstall" -ErrorAction Stop

        if ($value -eq 0) {
            Write-Host "Only Admins can install non package aware printer drivers for new connections." -ForegroundColor Green
            $printnightmare_npa_new = 0
        }
        elseif ($value -eq 1) {
            Write-Host "Normal users can install non package aware printer drivers for new connections." -ForegroundColor Red
            $printnightmare_npa_new = 2
        }
        else {
            Write-Host "Install non package aware printer driver as lowpriv user for new connections: regkey doesn't exist - hence disabled" -ForegroundColor Green
            $printnightmare_npa_new = 0
        }
    }
    catch {
        Write-Host "Install non package aware printer driver as lowpriv user for new connections: regkey doesn't exist - hence disabled" -ForegroundColor Green
        $printnightmare_npa_new = 0
    }

    # Drivers for updated connections
    try {
        $value = Get-ItemPropertyvalue -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "UpdatePromptSettings" -ErrorAction Stop

        if ($value -eq 0) {
            Write-Host "Only Admins can install non package aware printer drivers for updated connections." -ForegroundColor Green
            $printnightmare_npa_upd = 0
        }
        elseif ($value -eq 1) {
            Write-Host "Normal users can install non package aware printer drivers for updated connections." -ForegroundColor Red
            $printnightmare_npa_upd = 2
        }
        elseif ($value -eq 2) {
            Write-Host "Normal users can install non package aware printer drivers for updated connections." -ForegroundColor Red
            $printnightmare_npa_upd = 2
        }
        else {
            Write-Host "Install non package aware printer driver as lowpriv user for updated connections: regkey doesn't exist - hence disabled" -ForegroundColor Green
            $printnightmare_npa_upd = 0
        }
    }
    catch {
        Write-Host "Install non package aware printer driver as lowpriv user for updated connections: regkey doesn't exist - hence disabled" -ForegroundColor Green
        $printnightmare_npa_upd = 0
    }
    

    # Summary
    Write-host ""
    Write-host "###########" -ForegroundColor DarkCyan
    Write-host "# Summary #" -ForegroundColor DarkCyan
    Write-host "###########" -ForegroundColor DarkCyan
    Write-host ""

    if ($elevated -eq $true) {
        Add-Result "Ran as Admin" "-" "OK"
    }
    else {
        Add-Result "Ran as Admin" "-" "BAD"
    }

    switch ($pwpolicy_complexity){
        0 {Add-Result "Password Policy" "Password complexity" "OK"}
        2 {Add-Result "Password Policy" "Password complexity" "BAD"}
    }
    switch ($pwpolicy_lockoutduration){
        0 {Add-Result "Password Policy" "Lockout duration" "OK"}
        2 {Add-Result "Password Policy" "Lockout duration" "BAD"}
    }
    switch ($pwpolicy_lockoutthreshold){
        0 {Add-Result "Password Policy" "Lockout threshold" "OK"}
        1 {Add-Result "Password Policy" "Lockout threshold" "MAYBE"}
        2 {Add-Result "Password Policy" "Lockout threshold" "BAD"}
    }
    switch ($pwpolicy_pwlength){
        0 {Add-Result "Password Policy" "Password length" "OK"}
        2 {Add-Result "Password Policy" "Password length" "BAD"}
    }
    switch ($pwpolicy_revenc){
        0 {Add-Result "Password Policy" "Reverse encryption" "OK"}
        1 {Add-Result "Password Policy" "Reverse encryption" "MAYBE"}
        2 {Add-Result "Password Policy" "Reverse encryption" "BAD"}
    }
    switch ($pwpolicy_error){
        0 {}
        1 {Add-Result "Password Policy" "-" "Error"}
    }

    switch ($RunAsPPL){
        0 {Add-Result "RunAsPPL" "-" "OK"}
        1 {Add-Result "RunAsPPL" "-" "MAYBE"}
        2 {Add-Result "RunAsPPL" "-" "BAD"}
    }

    switch ($wdac_usercodeintegrity){
        0 {Add-result "WDAC" "User Mode Code Integrity Policy Enforcement" "OK"}
        1 {Add-result "WDAC" "User Mode Code Integrity Policy Enforcement" "MAYBE"}
        2 {Add-result "WDAC" "User Mode Code Integrity Policy Enforcement" "BAD"}
    }
    switch ($wdac_codeintegrity){
        0 {Add-result "WDAC" "Code Integrity Policy Enforcement" "OK"}
        1 {Add-result "WDAC" "Code Integrity Policy Enforcement" "MAYBE"}
        2 {Add-result "WDAC" "Code Integrity Policy Enforcement" "BAD"}
    }

    switch ($applocker){
        0 {Add-Result "Applocker" "-" "OK"}
        2 {Add-Result "Applocker" "-" "BAD"}
    }

    switch ($uac){
        0 {Add-Result "UAC" "-" "OK"}
        2 {Add-Result "UAC" "-" "BAD"}
    }
    switch ($guestacc){
        0 {Add-Result "Guest Account" "-" "OK"}
        1 {Add-Result "Guest Account" "-" "MAYBE"}
        2 {Add-Result "Guest Account" "-" "BAD"}
        3 {Add-Result "Guest Account" "-" "Error"}
    }

    switch ($stregedit){
        0 {Add-result "System Tools" "regedit" "OK"}
        2 {Add-result "System Tools" "regedit" "BAD"}
        3 {Add-result "System Tools" "regedit" "Error"}
    }

    switch ($stcmd){
        0 {Add-result "System Tools" "cmd" "OK"}
        2 {Add-result "System Tools" "cmd" "BAD"}
        3 {Add-result "System Tools" "cmd" "Error"}
    }

    switch ($stpowershell){
        0 {Add-result "System Tools" "PowerShell" "OK"}
        2 {Add-result "System Tools" "PowerShell" "BAD"}
        3 {Add-result "System Tools" "PowerShell" "Error"}
    }
    
    switch ($aie){
        0 {Add-Result "Always Install Elevated" "-" "OK"}
        2 {Add-Result "Always Install Elevated" "-" "BAD"}
    }

    switch ($credguard){
        0 {Add-Result "Credential Guard" "-" "OK"}
        2 {Add-Result "Credential Guard" "-" "BAD"}
    }

    switch ($coinstaller){
        0 {Add-Result "Co-installer" "-" "OK"}
        2 {Add-Result "Co-installer" "-" "BAD"}
    }

    switch ($dma_access){
        0 {Add-Result "DMA" "Status" "OK"}
        1 {Add-Result "DMA" "Status" "MAYBE"}
        2 {Add-Result "DMA" "Status" "BAD"}
    }
    switch ($dma_vbs){
        0 {Add-Result "DMA" "VBS" "OK"}
        1 {Add-Result "DMA" "VBS" "MAYBE"}
        2 {Add-Result "DMA" "VBS" "BAD"}
    }
    switch ($dma_heci){
        0 {Add-Result "DMA" "HECI" "OK"}
        1 {Add-Result "DMA" "HECI" "MAYBE"}
        2 {Add-Result "DMA" "HECI" "BAD"}
    }
    switch ($dma_heci_locked){
        0 {Add-Result "DMA" "HECI Lock" "OK"}
        1 {Add-Result "DMA" "HECI Lock" "MAYBE"}
        2 {Add-Result "DMA" "HECI Lock" "BAD"}
    }

    if ($bl_redCount -gt 0) {
        Add-Result "Bitlocker" "-" "BAD" -ForegroundColor Red
    }
    elseif ($bl_yellowCount -gt 0) {
        Add-Result "Bitlocker" "-" "Error"
    }
    elseif ($bl_magentaCount -gt 0) {
        Add-Result "Bitlocker" "-" "MAYBE"
    }
    elseif ($bl_greenCount -gt 0) {
        Add-Result "Bitlocker" "-" "OK"
    }

    switch ($secureboot){
        0 {Add-Result "Secure Boot" "-" "OK"}
        2 {Add-Result "Secure Boot" "-" "BAD"}
        3 {Add-Result "Secure Boot" "-" "Error"}
    }

    if ($spa_redCount -gt 0) {
        Add-result "System Path ACLs" "-" "BAD"
    }
    elseif ($spa_greenCount -gt 0) {
        Add-result "System Path ACLs" "-" "OK"
    }

    if ($uqsp_redcount -gt 0) {
        Add-Result "Unquoted Service Paths" "-" "BAD"
    }
    else {
        Add-Result "Unquoted Service Paths" "-" "OK"
    }

    switch ($wsus){
        0 {Add-Result "WSUS" "-" "OK"}
        2 {Add-Result "WSUS" "-" "RED"}
        3 {Add-Result "WSUS" "-" "Error"}
    }

    switch ($ps_v2){
        0 {Add-Result "PowerShell" "V2" "OK"}
        2 {Add-Result "PowerShell" "V2" "BAD"}
    }
    switch ($ps_ep){
        0 {Add-Result "PowerShell" "Executiuon Policy" "OK"}
        1 {Add-Result "PowerShell" "Executiuon Policy" "MAYBE"}
        2 {Add-Result "PowerShell" "Executiuon Policy" "BAD"}
    }
    switch ($ps_lm){
        0 {Add-Result "PowerShell" "Language Mode" "OK"}
        2 {Add-Result "PowerShell" "Language Mode" "BAD"}
    }

    switch ($ipv6){
        0 {Add-Result "IPv6" "-" "OK"}
        2 {Add-Result "IPv6" "-" "BAD"}
    }

    switch ($llmnr){
        0 {Add-Result "LLMNR" "-" "OK"}
        2 {Add-Result "LLMNR" "-" "BAD"}
    }
    switch ($netbios){
        0 {Add-Result "NetBIOS" "-" "OK"}
        2 {Add-Result "NetBIOS" "-" "BAD"}
    }

    switch ($smb_v1){
        0 {Add-Result "SMB" "V1" "OK"}
        2 {Add-Result "SMB" "V1" "BAD"}
    }
    switch ($smb_sig){
        0 {Add-Result "SMB" "Signing" "OK"}
        2 {Add-Result "SMB" "Signing" "BAD"}
    }

    switch ($secureboot){
        0 {Add-Result "Secure Boot" "-" "OK"}
        1 {Add-Result "Secure Boot" "-" "MAYBE"}
        2 {Add-Result "Secure Boot" "-" "BAD"}
        3 {Add-Result "Secure Boot" "-" "Error"}
    }

    switch ($av_on){
        0 {Add-Result "AV" "Status" "OK"}
        1 {Add-Result "AV" "Status" "MAYBE"}
        2 {Add-Result "AV" "Status" "BAD"}
    }
    switch ($av_utd){
        0 {Add-Result "AV" "Pattern" "OK"}
        2 {Add-Result "AV" "Pattern" "BAD"}
    }

    switch ($proxy_enabled){
        1 {Add-Result "Proxy" "Status" "MAYBE"}
        2 {Add-Result "Proxy" "Status" "BAD"}
    }
    switch ($proxy_autoconfig){
        1 {Add-Result "Proxy" "Autoconfig" "MAYBE"}
        2 {Add-Result "Proxy" "Autoconfig" "BAD"}
    }

    switch ($winupdate){
        0 {Add-Result "Windows Updates" "-" "OK"}
        1 {Add-Result "Windows Updates" "-" "MAYBE"}
        2 {Add-Result "Windows Updates" "-" "BAD"}
    }

    switch ($rdp_enabled){
        0 {Add-Result "RDP" "Status" "OK"}
        1 {Add-Result "RDP" "Status" "MAYBE"}
    }
    switch ($rdp_sec){
        0 {Add-Result "RDP" "Security Layer" "OK"}
        1 {Add-Result "RDP" "Security Layer" "MAYBE"}
        2 {Add-Result "RDP" "Security Layer" "BAD"}
        3 {Add-Result "RDP" "Security Layer" "Error"}
    }
    switch ($rdp_nla){
        0 {Add-Result "RDP" "NLA" "OK"}
        2 {Add-Result "RDP" "NLA" "BAD"}
    }

    switch ($winrm){
        0 {Add-Result "WinRM" "Status" "OK"}
        1 {Add-Result "WinRM" "Status" "MAYBE"}
    }

    switch ($printnightmare_pa){
        0 {Add-Result "PrintNightmare" "Package Aware" "OK"}
        2 {Add-Result "PrintNightmare" "Package Aware" "BAD"}
    }

    switch ($printnightmare_npa_new){
        0 {Add-Result "PrintNightmare" "Non Package Aware New" "OK"}
        2 {Add-Result "PrintNightmare" "Non Package Aware New" "BAD"}
    }

    switch ($printnightmare_npa_upd){
        0 {Add-Result "PrintNightmare" "Non Package Aware Update" "OK"}
        2 {Add-Result "PrintNightmare" "Non Package Aware Update" "BAD"}
    }

    $results | Format-Table -AutoSize

    Write-host ""
    Write-host "########################################################" -ForegroundColor DarkCyan
    Write-host "# Thats it, all checks done. Off to the report baby ^^ #" -ForegroundColor DarkCyan
    Write-host "########################################################" -ForegroundColor DarkCyan
    Write-host ""
}

# Function to add results to the custom object
function Add-Result($category, $subcategory, $result) {
    $resultObject = [PSCustomObject]@{
        Category    = $category
        Subcategory = $subcategory
        Result      = $result
    }
    $global:results += $resultObject
}
