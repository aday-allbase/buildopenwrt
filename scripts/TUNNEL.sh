#!/bin/bash

. ./scripts/INCLUDE.sh

# openclash_core URL generation
if [[ "$ARCH_3" == "x86_64" ]]; then
    meta_file="mihomo-linux-${ARCH_1}-compatible"
else
    meta_file="mihomo-linux-${ARCH_1}"
fi
openclash_core=$(curl -s "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)

# Nikki URL generation
nikki_file_ipk="nikki_${ARCH_3}-openwrt-${CURVER}"
nikki_file_ipk_down=$(curl -s "https://api.github.com/repos/rizkikotet-dev/OpenWrt-nikki-Mod/releases" | grep "browser_download_url" | grep -oE "https.*${nikki_file_ipk}.*.tar.gz" | head -n 1)

# Package repositories
declare -a openclash_ipk=("luci-app-openclash|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci")

# Function to download and setup OpenClash
setup_openclash() {
    echo "Downloading OpenClash packages"
    download_packages "custom" openclash_ipk[@]
    ariadl "${openclash_core}" "files/etc/openclash/core/clash_meta.gz"
    gzip -d "files/etc/openclash/core/clash_meta.gz" || error_msg "Error: Failed to extract OpenClash package."
}

# Function to download and setup Nikki
setup_nikki() {
    echo "Downloading Nikki packages"
    ariadl "${nikki_file_ipk_down}" "packages/nikki.tar.gz"
    tar -xzvf "packages/nikki.tar.gz" -C packages > /dev/null 2>&1 && rm "packages/nikki.tar.gz" || error_msg "Error: Failed to extract Nikki package."
}

# Main installation logic
case "$1" in
    openclash)
        setup_openclash
        ;;
    nikki)
        setup_nikki
        ;;
    nikki-openclash)
        setup_nikki
        setup_openclash
        ;;
    *)
        echo "Invalid option. Usage: $0 {openclash|passwall|nikki|openclash-passwall|nikki-passwall|nikki-openclash|openclash-passwall-nikki}"
        exit 1
        ;;
esac

# Check final status
if [ "$?" -ne 0 ]; then
    echo "Error: Download or extraction failed."
    exit 1
else
    echo "Download and installation completed successfully."
fi
