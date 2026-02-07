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

## 💰 Support This Project

<div align="center">

### ₿ Bitcoin Donations Welcome!

<img src="https://img.shields.io/badge/Bitcoin-000000?style=for-the-badge&logo=bitcoin&logoColor=white" alt="Bitcoin"/>

```
┌─────────────────────────────────────┐
│    ₿  BTC Donation Address  ₿      │
├─────────────────────────────────────┤
│                                     │
│  bc1qqphwht25vjzlptwzjyjt3sex     │
│  7e3p8twn390fkw                    │
│                                     │
│  Network: Bitcoin (BTC)             │
│  Scan QR ↓                          │
└─────────────────────────────────────┘
```

<img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=bitcoin:bc1qqphwht25vjzlptwzjyjt3sex7e3p8twn390fkw" alt="Bitcoin QR Code" width="200"/>

**Address:** `bc1qqphwht25vjzlptwzjyjt3sex7e3p8twn390fkw`

*Support Windows optimization tools!* 🙏

</div>

---

## 🚀 Quick Start

### Run as Administrator

```powershell
cd C:\Path\To\WindowsAutoMantenimiento
.\WindowsAutoMantenimiento.ps1
```

## 💻 Usage

```powershell
# Full maintenance
.\WindowsAutoMantenimiento.ps1

# Quick mode
.\WindowsAutoMantenimiento.ps1 -Quick

# Report only
.\WindowsAutoMantenimiento.ps1 -ReportOnly
```

## 🛠️ Maintenance Tasks

### 1. Disk Cleanup
- Temp files, cache, Recycle Bin
- Browser cache, Windows Update cache

### 2. System Files Check
```powershell
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
```

### 3. Windows Updates
- Auto-download and install updates

### 4. Security Scan
```powershell
Start-MpScan -ScanType FullScan
```

## 📅 Scheduled Maintenance

```powershell
# Weekly on Sunday at 2 AM
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File C:\Path\To\WindowsAutoMantenimiento.ps1"
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
Register-ScheduledTask -Action $Action -Trigger $Trigger `
    -TaskName "WindowsMaintenance" -RunLevel Highest
```

## ⚠️ Important Notes

- 💾 Save all work before running
- 🔌 Close important applications
- 🔋 Ensure power is connected
- ⏱️ Full maintenance: 30-60 minutes
- 💿 SSD: Defrag automatically skipped

## 🔒 Security

```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

## 📄 Logs

```
C:\Windows\Logs\WindowsMaintenance\
  ├── Maintenance_2026-02-07.log
  ├── Errors_2026-02-07.log
  └── Report_2026-02-07.txt
```

## 👤 Author

**murdok1982**
- GitHub: [@murdok1982](https://github.com/murdok1982)
- LinkedIn: [Gustavo Lobato Clara](https://www.linkedin.com/in/gustavo-lobato-clara-2b446b102/)
- Email: gustavolobatoclara@gmail.com

## 📝 License

MIT License

## 📈 Roadmap

- [ ] GUI interface
- [ ] Multi-language support
- [ ] Cloud backup integration
- [ ] Driver update checking
- [ ] Registry cleanup

---

⭐ **Star this repo!**
🐛 **[Report issues](https://github.com/murdok1982/WindowsAutoMantenimiento/issues)**

**Keep Your System Optimized! 🚀**