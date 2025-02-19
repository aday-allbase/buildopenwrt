#!/bin/bash

# Source the include file containing common functions and variables
. ./scripts/INCLUDE.sh

# Initialize package arrays based on target type
declare -a github_packages
if [ "$TYPE" == "AMLOGIC" ]; then
    echo -e "${INFO} Adding Amlogic-specific packages..."
    github_packages+=(
        "luci-app-amlogic|https://api.github.com/repos/ophub/luci-app-amlogic/releases/latest"
    )
fi

# Download GitHub packages
echo -e "${INFO} Downloading GitHub packages..."
download_packages "github" github_packages[@]

# Define package repositories
KIDDIN9_REPO="https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
GSPOTX2F_REPO="https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"

# Define package categories
declare -A package_categories=(
    ["openwrt"]="
        modemmanager-rpcd|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        luci-proto-modemmanager|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/luci
        libqmi|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        libmbim|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        modemmanager|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
    "
    ["kiddin9"]="
        luci-app-diskman|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        xmm-modem|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
    "
    ["immortalwrt"]="
        luci-app-openclash|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
    "
    ["gSpotx2f"]="
        luci-app-internet-detector|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
        internet-detector|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
        internet-detector-mod-modem-restart|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
        luci-app-cpu-status-mini|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
        luci-app-temp-status|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
    "
    ["etc"]="
        luci-app-temp-status|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
    "
)

# Process and download packages by category
declare -a all_packages
for category in "${!package_categories[@]}"; do
    echo -e "${INFO} Processing $category packages..."
    while read -r package_line; do
        [[ -z "$package_line" ]] && continue
        all_packages+=("$package_line")
    done <<< "${package_categories[$category]}"
done

# Download all packages
echo -e "${INFO} Downloading custom packages..."
download_packages "custom" all_packages[@]

# Verify downloads
echo -e "${INFO} Verifying downloaded packages..."
verify_packages() {
    local pkg_dir="packages"
    local total_pkgs=$(find "$pkg_dir" -name "*.ipk" | wc -l)
    echo -e "${INFO} Total packages downloaded: $total_pkgs"
    
    # List any failed downloads
    local failed=0
    for pkg in "${all_packages[@]}"; do
        local pkg_name="${pkg%%|*}"
        if ! find "$pkg_dir" -name "${pkg_name}*.ipk" >/dev/null 2>&1; then
            echo -e "${WARNING} Package not found: $pkg_name"
            ((failed++))
        fi
    done
    
    if [ $failed -eq 0 ]; then
        echo -e "${SUCCESS} All packages downloaded successfully"
    else
        echo -e "${WARNING} $failed package(s) failed to download"
    fi
}

verify_packages
