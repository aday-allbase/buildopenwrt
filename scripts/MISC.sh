#!/bin/bash

. ./scripts/INCLUDE.sh

# Logging functions
log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1"
    exit 1
}

# Initialize environment
init_environment() {
    log "Start Downloading Misc files and setup configuration!"
    log "Current Path: $PWD"
}

# Setup base-specific configurations
setup_base_config() {
    # Update date in init settings
    sed -i "s/Ouc3kNF6/$DATE/g" files/etc/uci-defaults/99-init-settings.sh
    
    case "$BASE" in
        "openwrt")
            log "Configuring OpenWrt specific settings"
            sed -i '/# setup misc settings/ a\mv \/www\/luci-static\/resources\/view\/status\/include\/29_temp.js \/www\/luci-static\/resources\/view\/status\/include\/17_temp.js' files/etc/uci-defaults/99-init-settings.sh
            ;;
        "immortalwrt")
            log "Configuring ImmortalWrt specific settings"
            ;;
        *)
            log "Unknown base system: $BASE"
            ;;
    esac
}

# Handle Amlogic-specific files
handle_amlogic_files() {
    if [ "$TYPE" == "AMLOGIC" ]; then
        log "Removing Amlogic-specific files"
        rm -f files/etc/uci-defaults/70-rootpt-resize
        rm -f files/etc/uci-defaults/80-rootfs-resize
        rm -f files/etc/sysupgrade.conf
    fi
}

# Setup branch-specific configurations
setup_branch_config() {
    local branch_major=$(echo "$BRANCH" | cut -d'.' -f1)
    case "$branch_major" in
        "24")
            log "Configuring for branch 24.x"
            ;;
        "23")
            log "Configuring for branch 23.x"
            ;;
        *)
            log "Unknown branch version: $BRANCH"
            ;;
    esac
}

# Configure file permissions for Amlogic
configure_amlogic_permissions() {
    if [ "$TYPE" == "AMLOGIC" ]; then
        log "Setting up Amlogic file permissions"
            sed -i "/# setup misc settings/ a\chmod +x $file" files/etc/uci-defaults/99-init-settings.sh
    else
        log "Removing lib directory for non-Amlogic build"
    fi
}

# Main execution
main() {
    init_environment
    setup_base_config
    handle_amlogic_files
    setup_branch_config
    configure_amlogic_permissions
    log "All custom configuration setup completed!"
}

# Execute main function
main
