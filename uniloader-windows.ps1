#!/usr/bin/env bash
# ============================
# PowerShell helper functions
# ============================

function Check-Command {
    param (
        [string]$Command,
        [string]$Name
    )

    $cmdPath = Get-Command $Command -ErrorAction SilentlyContinue
    if ($cmdPath) {
        Write-Output "[$Name] Found: $cmdPath"
        return $true
    } else {
        Write-Output "[$Name] Not found"
        return $false
    }
}

function Get-Version {
    param (
        [string]$Command,
        [string]$Name,
        [string]$VersionCommand
    )

    if (Check-Command -Command $Command -Name $Name) {
        try {
            $version = Invoke-Expression $VersionCommand
            if ($version) {
                Write-Output "    Version: $version"
            } else {
                Write-Output "    Version check failed."
            }
        } catch {
            Write-Output "    Version check failed (exception)"
        }
    }
}
# ============================
# Windows interpreters check (PowerShell-native)
# ============================

Write-Output "`n--- Checking PowerShell ---"

$psAvailable = $false

# Check classic PowerShell
if (Get-Command powershell -ErrorAction SilentlyContinue) {
    try {
        $psVersion = powershell -Command '$PSVersionTable.PSVersion' 2>$null
        if ($psVersion) {
            Write-Output "    PowerShell found: $psVersion"
            $psAvailable = $true
        } else {
            Write-Output "    PowerShell found but version check failed"
        }
    } catch {
        Write-Output "    PowerShell version check exception"
    }
}

# Check PowerShell Core
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    try {
        $pwshVersion = pwsh -Command '$PSVersionTable.PSVersion' 2>$null
        if ($pwshVersion) {
            Write-Output "    PowerShell Core found: $pwshVersion"
            $psAvailable = $true
        } else {
            Write-Output "    PowerShell Core found but version check failed"
        }
    } catch {
        Write-Output "    PowerShell Core version check exception"
    }
}

if (-not $psAvailable) {
    Write-Output "    No PowerShell interpreter found"
}

Write-Output "`n--- Checking cmd.exe ---"

# Only run cmd.exe check on Windows
if ($IsWindows) {
    if (Get-Command cmd.exe -ErrorAction SilentlyContinue) {
        try {
            $cmdVersion = cmd /c ver 2>$null
            if ($cmdVersion) {
                Write-Output "    cmd.exe found: $cmdVersion"
            } else {
                Write-Output "    cmd.exe version check failed"
            }
        } catch {
            Write-Output "    cmd.exe version check exception"
        }
    } else {
        Write-Output "    cmd.exe not found"
    }
} else {
    Write-Output "[-] cmd.exe check skipped (not a Windows environment)"
}

