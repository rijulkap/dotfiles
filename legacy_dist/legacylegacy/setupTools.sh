#!/bin/bash

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Attempting to install jq..."
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y jq
    fi
fi

# Define the path to the JSON file
json_path="tools.json"

# Read the JSON file
if [ ! -f "$json_path" ]; then
    echo "JSON file not found."
    exit 1
fi

# Function to install a tool
install_tool() {
    local tool=$1
    shift
    local install_cmds=("$@")

    if [ ${#install_cmds[@]} -gt 0 ]; then
        for cmd in "${install_cmds[@]}"; do
            eval "$cmd"
        done
    else
        echo "No installation instructions found for $tool on this OS."
    fi
}

# Parse command line argument for a specific tool
single_tool=""
if [ $# -gt 0 ]; then
    single_tool=$1
fi

# Install specific tool or all tools
if [ -n "$single_tool" ]; then
    # Install a specific tool
    mapfile -t install_cmds < <(jq -r --arg tool "$single_tool" '.[$tool].Linux[]?' "$json_path")
    if [ ${#install_cmds[@]} -eq 0 ]; then
        echo "Tool '$single_tool' not found or no installation instructions for this OS."
        exit 1
    else
        install_tool "$single_tool" "${install_cmds[@]}"
    fi
else
    # Install all tools
    tools=$(jq -r 'keys[]' "$json_path")
    for tool in $tools; do
        mapfile -t install_cmds < <(jq -r --arg tool "$tool" '.[$tool].Linux[]?' "$json_path")
        install_tool "$tool" "${install_cmds[@]}"
        echo "---------------------------------------------------------------------------------------"
    done
fi

# Keep the terminal open if no specific tool was installed
if [ -z "$single_tool" ]; then
    read -p "Press Enter to exit"
fi
