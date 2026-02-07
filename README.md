# 🛠️ WindowsAutoMantenimiento - Automated Windows Maintenance

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://docs.microsoft.com/powershell/)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6.svg)](https://www.microsoft.com/windows)

> Powerful PowerShell script for automated Windows system maintenance. Keeps your Windows PC running at peak performance with one-click optimization.

## ✨ Features

- 🧹 **Disk Cleanup**: Remove temporary files, cache, and unnecessary data
- 💾 **Defragmentation**: Optimize disk performance (HDD only)
- 🔄 **Windows Updates**: Check and install system updates
- 🔒 **Security Scans**: Run Windows Defender full scan
- 📦 **System Repair**: Check and repair system files (SFC, DISM)
- 📋 **Event Log Cleanup**: Clear old event logs
- 🔌 **Network Reset**: Fix network connectivity issues
- 📈 **Performance Report**: Generate system health report

## 🚀 Quick Start

### Option 1: Run as Administrator (Recommended)

1. Right-click on **PowerShell** and select **Run as Administrator**
2. Navigate to script directory:
   ```powershell
   cd C:\Path\To\WindowsAutoMantenimiento
   ```
3. Execute script:
   ```powershell
   .\WindowsAutoMantenimiento.ps1
   ```

### Option 2: Direct Execution

Double-click `Run_As_Admin.bat` (if provided)

## 📋 Requirements

- **OS**: Windows 10/11 (Windows Server compatible)
- **PowerShell**: Version 5.1 or higher
- **Permissions**: Administrator rights required
- **Disk Space**: At least 2GB free space recommended

### Check PowerShell Version

```powershell
$PSVersionTable.PSVersion
```

## ⚙️ Configuration

### Execution Policy

If you encounter execution policy errors:

```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy for current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Or for current user (permanent)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Customize Script

Edit the script to enable/disable specific tasks:

```powershell
# Configuration variables
$EnableDiskCleanup = $true
$EnableDefragmentation = $false  # Set false for SSD
$EnableWindowsUpdate = $true
$EnableSecurityScan = $true
$EnableSystemRepair = $true
$VerboseOutput = $true
```

## 💻 Usage

### Basic Execution

```powershell
# Full maintenance (all tasks)
.\WindowsAutoMantenimiento.ps1

# With verbose output
.\WindowsAutoMantenimiento.ps1 -Verbose

# Specific tasks only
.\WindowsAutoMantenimiento.ps1 -Tasks "DiskCleanup","Updates"
```

### Advanced Options

```powershell
# Quick mode (skip time-consuming tasks)
.\WindowsAutoMantenimiento.ps1 -Quick

# Generate report only
.\WindowsAutoMantenimiento.ps1 -ReportOnly

# Schedule for later
.\WindowsAutoMantenimiento.ps1 -Schedule "22:00"
```

## 🛠️ Maintenance Tasks

### 1. Disk Cleanup
- Clears Windows temp files
- Removes system cache
- Empties Recycle Bin
- Cleans browser cache
- Removes Windows Update cache

### 2. System Files Check
```powershell
# System File Checker
sfc /scannow

# DISM Repair
DISM /Online /Cleanup-Image /RestoreHealth
```

### 3. Defragmentation
```powershell
# HDD only - automatically skips SSDs
Defrag C: /O /H /U
```

### 4. Windows Updates
- Checks for available updates
- Downloads and installs updates
- Schedules restart if needed

### 5. Security Scan
```powershell
# Windows Defender full scan
Start-MpScan -ScanType FullScan
```

### 6. Network Reset
```powershell
# Flush DNS
ipconfig /flushdns

# Reset network stack
netsh winsock reset
netsh int ip reset
```

## 📈 Performance Report

The script generates a comprehensive report:

```
====================================
Windows Maintenance Report
====================================
Date: 2026-02-07 15:30:00
System: Windows 11 Pro
Hostname: DESKTOP-PC

=== Disk Space ===
C: Drive
  Total: 500 GB
  Free: 150 GB (30%)
  Cleaned: 5.2 GB

=== System Health ===
System Files: OK
Windows Updates: 3 installed
Defender: Up to date
Last Scan: 2026-02-07

=== Performance ===
Boot Time: 25 seconds
Memory Usage: 45%
CPU Usage: 12%

=== Actions Taken ===
✓ Disk Cleanup completed
✓ System files verified
✓ Windows Updates installed
✓ Security scan completed
✓ Network cache cleared

Maintenance completed successfully!
====================================
```

## 📅 Scheduled Maintenance

### Create Scheduled Task

```powershell
# Run script weekly on Sunday at 2 AM
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File C:\Path\To\WindowsAutoMantenimiento.ps1"

$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am

$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" `
    -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -Action $Action -Trigger $Trigger `
    -Principal $Principal -TaskName "WindowsMaintenance" `
    -Description "Automated Windows maintenance"
```

### Using Task Scheduler GUI

1. Open Task Scheduler
2. Create Basic Task
3. Name: "Windows Auto Maintenance"
4. Trigger: Weekly / Daily
5. Action: Start a program
6. Program: `PowerShell.exe`
7. Arguments: `-File "C:\Path\To\WindowsAutoMantenimiento.ps1"`
8. Check "Run with highest privileges"

## ⚠️ Important Notes

### Before Running

⚠️ **IMPORTANT:**
- 💾 Save all work before running
- 🔌 Close important applications
- 🔋 Ensure power is connected (laptops)
- 💾 Have at least 2GB free disk space
- ⏱️ Full maintenance can take 30-60 minutes

### SSD vs HDD

- **SSD**: Defragmentation is automatically skipped
- **HDD**: Full defragmentation is performed
- Script auto-detects drive type

### Safety Features

✅ **Built-in Safeguards:**
- Administrator rights verification
- Drive type detection
- Free space check before cleanup
- System restore point creation
- Automatic error logging
- Safe mode detection

## 🔒 Security

### Script Signing

For added security, sign the script:

```powershell
# Get code signing certificate
$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert

# Sign script
Set-AuthenticodeSignature -FilePath .\WindowsAutoMantenimiento.ps1 `
    -Certificate $cert
```

### Verify Script Integrity

```powershell
# Check script signature
Get-AuthenticodeSignature .\WindowsAutoMantenimiento.ps1

# View script content before running
Get-Content .\WindowsAutoMantenimiento.ps1
```

## 📊 Logs

Logs are stored in:
```
C:\Windows\Logs\WindowsMaintenance\
  ├── Maintenance_2026-02-07.log
  ├── Errors_2026-02-07.log
  └── Report_2026-02-07.txt
```

## 🛠️ Troubleshooting

### Common Issues

**Issue**: "Script cannot be loaded"
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

**Issue**: "Access Denied"
- Run PowerShell as Administrator

**Issue**: "Insufficient disk space"
- Free up at least 2GB manually first

**Issue**: "Windows Update fails"
```powershell
# Reset Windows Update components
net stop wuauserv
net stop bits
rd /s /q C:\Windows\SoftwareDistribution
net start wuauserv
net start bits
```

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create feature branch
3. Test thoroughly on multiple Windows versions
4. Submit pull request

## 📝 License

MIT License - see [LICENSE](LICENSE) file

## 👤 Author

**murdok1982**

- GitHub: [@murdok1982](https://github.com/murdok1982)
- LinkedIn: [Gustavo Lobato Clara](https://www.linkedin.com/in/gustavo-lobato-clara-2b446b102/)

## 🙏 Acknowledgments

- Microsoft PowerShell Team
- Windows Admin community
- Contributors and testers

## 📈 Roadmap

- [ ] GUI interface
- [ ] Multi-language support
- [ ] Cloud backup integration
- [ ] Driver update checking
- [ ] Startup optimization
- [ ] Registry cleanup
- [ ] Portable version

---

⭐ **Star this repo if it helps keep your PC running smoothly!**
🐛 **[Report issues](https://github.com/murdok1982/WindowsAutoMantenimiento/issues)**

**Keep Your System Optimized! 🚀**