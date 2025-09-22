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

# --- Helper functions ---
check_command() {
    # $1 = command, $2 = human-readable name
    if command -v "$1" >/dev/null 2>&1; then
        echo "    [$2] Found: $1"
        return 0
    else
        echo "    [$2] Not found: $1"
        return 1
    fi
}

get_version() {
    # $1 = command, $2 = human-readable name, $3 = version command
    if check_command "$1" "$2"; then
        version=$($3 2>/dev/null)
        if [ -n "$version" ]; then
            echo "        Version: $version"
        else
            echo "        Version check failed."
        fi
    fi
}

# 2. Bash & Python
echo -e "\nChecking Bash..."
get_version "bash" "Bash" "bash --version | head -n 1"

echo -e "\nChecking Python..."
if check_command "python3" "Python 3"; then
    python_version=$(python3 --version 2>/dev/null)
    if [ -n "$python_version" ]; then
        echo "    Version: $python_version"
    else
        echo "    Version check failed."
    fi
elif check_command "python" "Python"; then
    python_version=$(python --version 2>/dev/null)
    if [ -n "$python_version" ]; then
        echo "    Version: $python_version"
    else
        echo "    Version check failed."
    fi
fi

# ============================
# 3. macOS: All relevant interpreters
# ============================

echo -e "\n--- Checking macOS interpreters ---"

# JXA / AppleScript
if check_command "osascript" "osascript (AppleScript / JXA)"; then
    osascript_version=$(osascript -e 'version of application "Script Editor"' 2>/dev/null)
    if [ -n "$osascript_version" ]; then
        echo "    AppleScript Version: $osascript_version"
    else
        echo "    osascript available but Script Editor not found or version unknown"
    fi
fi

# Swift
if check_command "swift" "Swift"; then
    swift_version=$(swift --version 2>/dev/null | head -n1)
    if [ -n "$swift_version" ]; then
        echo "    Swift Version: $swift_version"
    else
        echo "    Swift version check failed"
    fi
fi

# Shells: bash, zsh, sh, ksh, csh, tcsh
for shell in bash zsh sh ksh csh tcsh; do
    if check_command "$shell" "$shell"; then
        shell_version=$($shell --version 2>/dev/null | head -n1)
        if [ -n "$shell_version" ]; then
            echo "    $shell Version: $shell_version"
        else
            echo "    $shell available but version check failed"
        fi
    fi
done

# Interpreted languages: python3, python, ruby, perl, tcl
for lang in python3 python ruby perl tclsh; do
    if check_command "$lang" "$lang"; then
        lang_version=$($lang --version 2>&1 | head -n1)
        if [ -n "$lang_version" ]; then
            echo "    $lang Version: $lang_version"
        else
            echo "    $lang available but version check failed"
        fi
    fi
done

# Node.js (if installed via Homebrew / nvm)
if check_command "node" "Node.js"; then
    node_version=$(node --version 2>/dev/null)
    echo "    Node.js Version: $node_version"
fi

# ============================
# Preferred macOS interpreter (priority order)
# ============================

if check_command "python3" "Python 3"; then
    preferred="python3"
elif check_command "osascript" "AppleScript / JXA"; then
    preferred="osascript"
elif check_command "bash" "Bash"; then
    preferred="bash"
elif check_command "zsh" "Zsh"; then
    preferred="zsh"
elif check_command "ruby" "Ruby"; then
    preferred="ruby"
elif check_command "perl" "Perl"; then
    preferred="perl"
else
    preferred="none"
fi

echo -e "\nPreferred macOS interpreter for automation: $preferred"
