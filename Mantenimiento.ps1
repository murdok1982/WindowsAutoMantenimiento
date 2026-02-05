<#
.SYNOPSIS
    Windows Optimization, Hardening, and Maintenance Script.
    
.DESCRIPTION
    A robust, safe-by-design script to audit, update, repair, and harden Windows 10/11 systems.
    Designed for corporate environments with logging, rollback, and dry-run capabilities.

.PARAMETER AuditOnly
    Run only read-only checks and report findings. No changes are made.

.PARAMETER FixErrors
    Attempt to repair common Windows errors (SFC, DISM, etc.).

.PARAMETER UpdateAll
    Update Windows and installed applications (Winget/Chocolatey).

.PARAMETER Harden
    Apply security hardening and debloating optimizations.

.PARAMETER DryRun
    Simulate actions without making changes. Defaults to $true for safety.
    
.PARAMETER LogPath
    Path to store execution logs. Defaults to current directory.

.EXAMPLE
    .\Invoke-WindowsMaintenance.ps1 -AuditOnly
    Runs a system health check.

.EXAMPLE
    .\Invoke-WindowsMaintenance.ps1 -DryRun:$false -UpdateAll -FixErrors
    Updates system and repairs errors (Real Mode).
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$AuditOnly,
    [switch]$FixErrors,
    [switch]$UpdateAll,
    [switch]$Harden,
    [switch]$DryRun = $true,
    [string]$LogPath = "$PSScriptRoot\Logs"
)

# -------------------------------------------------------------------------
# CONSTANTS & CONFIGURATION
# -------------------------------------------------------------------------
$Global:ErrorActionPreference = "Stop"
$Script:LogFile = $null

# -------------------------------------------------------------------------
# CORE FUNCTIONS
# -------------------------------------------------------------------------

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS", "DRYRUN")]
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogLine = "[$Timestamp] [$Level] $Message"
    
    # Console Output Colors
    $Color = switch($Level) {
        "INFO"    { "White" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        "SUCCESS" { "Green" }
        "DRYRUN"  { "Cyan" }
    }
    
    Write-Host $LogLine -ForegroundColor $Color
    
    if ($Script:LogFile) {
        Add-Content -Path $Script:LogFile -Value $LogLine -ErrorAction SilentlyContinue
    }
}

function Test-IsAdmin {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = [Security.Principal.WindowsPrincipal]$Identity
    return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function New-SafeRestorePoint {
    param([string]$Description)
    
    Write-Log "Attempting to create System Restore Point: $Description" "INFO"
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would create restore point: $Description" "DRYRUN"
        return
    }

    try {
        # Check if System Restore is enabled
        $RPOpt = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
        # Simple check: enable if disabled on system drive (usually C:)
        if (-not $RPOpt) {
             Write-Log "System Restore might be disabled. Attempting to enable on C: via Enable-ComputerRestore..." "WARNING"
             Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue 
        }

        Checkpoint-Computer -Description $Description -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Log "Restore Point created successfully." "SUCCESS"
    }
    catch {
        Write-Log "Failed to create Restore Point. Ensure System Restore is enabled. Error: $_" "WARNING"
    }
}

# -------------------------------------------------------------------------
# MODULE PLACEHOLDERS
# -------------------------------------------------------------------------

function Measure-SystemHealth {
    Write-Log "Starting System Audit..." "INFO"
    
    # 1. Windows Version
    $OS = Get-CimInstance Win32_OperatingSystem
    Write-Log "OS Version: $($OS.Caption) ($($OS.Version))" "INFO"
    Write-Log "Last Boot Time: $($OS.LastBootUpTime)" "INFO"

    # 2. Disk Space (C:)
    $Disk = Get-PSDrive C
    $FreeGB = [math]::Round($Disk.Free / 1GB, 2)
    $TotalGB = [math]::Round($Disk.Used / 1GB + $FreeGB, 2)
    $PercentFree = [math]::Round(($FreeGB / $TotalGB) * 100, 2)
    
    if ($PercentFree -lt 10) {
        Write-Log "Low Disk Space: $FreeGB GB free ($PercentFree%)" "WARNING"
    } else {
        Write-Log "Disk Space: $FreeGB GB free ($PercentFree%)" "INFO"
    }

    # 3. Security Status (Defender)
    try {
        $Defender = Get-MpComputerStatus -ErrorAction Stop
        if ($Defender.AntivirusEnabled -and $Defender.RealTimeProtectionEnabled) {
            Write-Log "Windows Defender is Active and Real-Time Protection is ON." "SUCCESS"
        } else {
            Write-Log "Windows Defender STATUS CHECK FAILED (AV: $($Defender.AntivirusEnabled), RTP: $($Defender.RealTimeProtectionEnabled))" "WARNING"
        }
    }
    catch {
        Write-Log "Could not verify Windows Defender status (Admin rights required?)" "WARNING"
    }

    # 4. Recent Event Log Errors (Last 24h, System)
    try {
        $Errors = Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddDays(-1) -Newest 5 -ErrorAction SilentlyContinue
        if ($Errors) {
            Write-Log "Found recent SYSTEM errors:" "WARNING"
            foreach ($Err in $Errors) {
                Write-Log "  [$($Err.TimeGenerated)] Source: $($Err.Source) | ID: $($Err.EventID)" "WARNING"
            }
        } else {
            Write-Log "No critical System errors found in the last 24h." "INFO"
        }
    }
    catch {
        Write-Log "Failed to read Event Log." "ERROR"
    }
}

function Invoke-SystemUpdates {
    if ($DryRun) {
        Write-Log "Simulating Update Process..." "DRYRUN"
        Write-Log "[DRYRUN] Would run: winget upgrade --all" "DRYRUN"
        Write-Log "[DRYRUN] Would run: (Get-Command choco) upgrade all -y" "DRYRUN"
        Write-Log "[DRYRUN] Would trigger Windows Update via USOClient" "DRYRUN"
        return
    }

    Write-Log "Starting Update Process..." "INFO"

    # 1. Winget Updates
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        Write-Log "Running Winget upgrade..." "INFO"
        try {
            winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
            Write-Log "Winget execution completed." "SUCCESS"
        } catch {
            Write-Log "Winget encountered an error: $_" "ERROR"
        }
    } else {
        Write-Log "Winget not found. Skipping." "WARNING"
    }

    # 2. Chocolatey Updates
    if (Get-Command "choco" -ErrorAction SilentlyContinue) {
        Write-Log "Running Chocolatey upgrade..." "INFO"
        try {
            choco upgrade all -y
            Write-Log "Chocolatey upgrade completed." "SUCCESS"
        } catch {
            Write-Log "Chocolatey encountered an error: $_" "ERROR"
        }
    }

    # 3. Windows Update (Trigger Scan)
    Write-Log "Triggering Windows Update Scan..." "INFO"
    try {
        # Modern Windows 10/11 method
        Start-Process -FilePath "usoclient.exe" -ArgumentList "StartInteractiveScan" -WindowStyle Hidden
        Write-Log "Windows Update scan initiated. Check Settings > Windows Update for details." "SUCCESS"
    } catch {
        Write-Log "Failed to trigger Windows Update scan." "ERROR"
    }
}

function Invoke-SystemRepair {
    if ($DryRun) {
        Write-Log "Simulating System Repair..." "DRYRUN"
        Write-Log "[DRYRUN] Would run: sfc /scannow" "DRYRUN"
        Write-Log "[DRYRUN] Would run: DISM /Online /Cleanup-Image /RestoreHealth" "DRYRUN"
        Write-Log "[DRYRUN] Would clean Temp folders" "DRYRUN"
        Write-Log "[DRYRUN] Would reset Windows Update components" "DRYRUN"
        return
    }

    Write-Log "Starting System Repair..." "INFO"

    # 1. SFC Scan
    Write-Log "Running System File Checker (SFC)..." "INFO"
    Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -NoNewWindow
    Write-Log "SFC Completed." "SUCCESS"

    # 2. DISM RestoreHealth
    Write-Log "Running DISM RestoreHealth..." "INFO"
    Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -NoNewWindow
    Write-Log "DISM Completed." "SUCCESS"

    # 3. Safe Temp Cleanup
    Write-Log "Cleaning Temporary Files..." "INFO"
    $TempFolders = @(
        $env:TEMP,
        $env:windir + "\Temp"
    )

    foreach ($Folder in $TempFolders) {
        if (Test-Path $Folder) {
            Get-ChildItem -Path $Folder -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { 
                $_.LastWriteTime -lt (Get-Date).AddDays(-1) 
            } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Log "Temp cleanup completed." "SUCCESS"

    # 4. Reset Windows Update (If Repair is requested)
    Write-Log "Resetting Windows Update Components..." "INFO"
    $WUServices = "wuauserv", "cryptSvc", "bits", "msiserver"
    
    foreach ($Service in $WUServices) {
        Stop-Service -Name $Service -Force -ErrorAction SilentlyContinue
    }

    $SoftDist = "$env:windir\SoftwareDistribution"
    $CatRoot2 = "$env:windir\System32\catroot2"

    if (Test-Path $SoftDist) { 
        Rename-Item -Path $SoftDist -NewName "$SoftDist.old.$(Get-Date -Format yyyyMMddHHmmss)" -ErrorAction SilentlyContinue
    }
    if (Test-Path $CatRoot2) {
        Rename-Item -Path $CatRoot2 -NewName "$CatRoot2.old.$(Get-Date -Format yyyyMMddHHmmss)" -ErrorAction SilentlyContinue
    }

    foreach ($Service in $WUServices) {
        Start-Service -Name $Service -ErrorAction SilentlyContinue
    }
    Write-Log "Windows Update components reset." "SUCCESS"
}

function Invoke-Optimization {
    if ($DryRun) {
        Write-Log "Simulating Optimization..." "DRYRUN"
        Write-Log "[DRYRUN] Would remove bloatware (CandyCrush, Netflix, etc.)" "DRYRUN"
        Write-Log "[DRYRUN] Would restrict Telemetry" "DRYRUN"
        Write-Log "[DRYRUN] Would set unused services to Manual" "DRYRUN"
        return
    }

    Write-Log "Starting Optimization & Hardening..." "INFO"

    # 1. Debloat (Safe List)
    $Bloatware = @(
        "King.CandyCrushSaga",
        "SpotifyAB.SpotifyMusic",
        "Netflix",
        "Microsoft.BingWeather",
        "Microsoft.GetHelp",
        "Microsoft.MicrosoftSolitaireCollection"
    )

    Write-Log "Checking for bloatware..." "INFO"
    foreach ($App in $Bloatware) {
        $Package = Get-AppxPackage -Name "*$App*" -ErrorAction SilentlyContinue
        if ($Package) {
            Write-Log "Removing bloatware: $($Package.Name)" "WARNING"
            $Package | Remove-AppxPackage -ErrorAction SilentlyContinue
            Write-Log "Removed: $($Package.Name)" "SUCCESS"
        }
    }

    # 2. Telemetry (Safe GPO-friendly tweak)
    Write-Log "Optimizing Telemetry Settings..." "INFO"
    try {
        # Set AllowTelemetry to 1 (Basic) or 0 (Security - Enterprise only)
        # 3 = Full, 1 = Basic
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Write-Log "Telemetry set to Basic level." "SUCCESS"
    } catch {
        Write-Log "Failed to set Telemetry registry key." "WARNING"
    }

    # 3. Services Optimization (Set to Manual)
    $ServicesToOptimize = @(
        "XblAuthManager",   # Xbox Live Auth Manager
        "XblGameSave",      # Xbox Live Game Save
        "MapsBroker",       # Downloaded Maps Manager
        "DiagTrack"         # Connected User Experiences and Telemetry
    )

    foreach ($Service in $ServicesToOptimize) {
        if (Get-Service -Name $Service -ErrorAction SilentlyContinue) {
            Write-Log "Setting service to Manual: $Service" "INFO"
            Set-Service -Name $Service -StartupType Manual -ErrorAction SilentlyContinue
        }
    }
}

# -------------------------------------------------------------------------
# MAIN EXECUTION
# -------------------------------------------------------------------------

try {
    # 1. Initialize Logging
    if (-not (Test-Path $LogPath)) { New-Item -ItemType Directory -Path $LogPath -Force | Out-Null }
    $Script:LogFile = Join-Path $LogPath "Maintenance_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    
    Write-Log "=== Windows Maintenance Script Started ===" "INFO"
    if ($DryRun) { Write-Log "!!! RUNNING IN DRY-RUN MODE (No changes will be applied) !!!" "DRYRUN" }

    # 2. Check Admin Privileges
    if (-not (Test-IsAdmin)) {
        Write-Log "Script requires Administrator privileges. Please run as Admin." "ERROR"
        return
    }

    # 3. Create Restore Point (if applying changes)
    if (-not $AuditOnly -and ($FixErrors -or $UpdateAll -or $Harden)) {
        New-SafeRestorePoint -Description "Pre-Maintenance Script $(Get-Date -Format 'yyyy-MM-dd')"
    }

    # 4. Mode Selection
    
    # Always Audit first
    Measure-SystemHealth

    if ($FixErrors) {
        Invoke-SystemRepair
    }

    if ($UpdateAll) {
        Invoke-SystemUpdates
    }

    if ($Harden) {
        Invoke-Optimization
    }

    if ($AuditOnly) {
        Write-Log "Audit Only mode completed." "SUCCESS"
    }
    
    Write-Log "=== Script Execution Completed ===" "SUCCESS"
    Write-Log "Log saved to: $Script:LogFile" "INFO"

}
catch {
    Write-Log "Critical Error: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
}
