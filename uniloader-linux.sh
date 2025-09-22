#!/usr/bin/bash
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
