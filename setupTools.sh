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

# Install tools
tools=$(jq -r 'keys[]' "$json_path")
for tool in $tools; do
    mapfile -t install_cmds < <(jq -r --arg tool "$tool" '.[$tool].Linux[]?' "$json_path")
    install_tool "$tool" "${install_cmds[@]}"
    echo "---------------------------------------------------------------------------------------"
done

# Keep the terminal open
read -p "Press Enter to exit"
