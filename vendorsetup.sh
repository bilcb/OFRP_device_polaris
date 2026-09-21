#
#   This file is part of the OrangeFox Recovery Project
#   Copyright (C) 2018-2024 The OrangeFox Recovery Project
#

FDEVICE="polaris"

fox_get_target_device() {
    local chkdev=$(echo "$BASH_SOURCE" | grep -w "$FDEVICE")
    if [ -n "$chkdev" ]; then
        FOX_BUILD_DEVICE="$FDEVICE"
    else
        chkdev=$(set | grep BASH_ARGV | grep -w "$FDEVICE")
        [ -n "$chkdev" ] && FOX_BUILD_DEVICE="$FDEVICE"
    fi
}

if [ -z "$1" ] && [ -z "$FOX_BUILD_DEVICE" ]; then
    fox_get_target_device
fi

if [ "$1" = "$FDEVICE" ] || [ "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
    export LC_ALL="C"
    export ALLOW_MISSING_DEPENDENCIES=true

    # Environment & Core Shell
    export FOX_ASH_IS_BASH=1                        # Map ash to bash
    export FOX_USE_BASH_SHELL=1                     # Force bash shell
    export FOX_REPLACE_TOOLBOX_GETPROP=1            # Use full version of getprop

    # Binary Tools (Compression & Utils)
    export FOX_USE_TAR_BINARY=1                     # Enable tar binary
    export FOX_USE_LZ4_BINARY=1                     # Enable lz4 binary
    export FOX_USE_ZSTD_BINARY=1                    # Enable zstd binary
    export FOX_USE_XZ_UTILS=1                       # Enable xz utils
    export FOX_USE_SED_BINARY=1                     # Enable sed binary
    export FOX_USE_DATE_BINARY=1                    # Enable date binary
    export FOX_USE_GREP_BINARY=1                    # Enable grep binary
    export FOX_USE_BUSYBOX_BINARY=1                 # Enable busybox tools
    export FOX_USE_PATCHELF_BINARY=1                # Enable patchelf binary (fix dependencies)

    # Security & AVB
    export OF_PATCH_AVB20=1                         # Patch AVB 2.0 verification

    # User Interface (Display & Touch)
    export OF_SCREEN_H=2160                         # Screen height resolution
    export OF_HIDE_NOTCH=1                          # Hide notch area
    export OF_CLOCK_POS=1                           # Clock position on screen

    # Status Bar Settings
    export OF_STATUS_H=80                           # Status bar height
    export OF_STATUS_INDENT_LEFT=48                 # Left padding/indent
    export OF_STATUS_INDENT_RIGHT=48                # Right padding/indent

    # UI Components & LED
    export FOX_DELETE_AROMAFM=1                     # Remove AROMA File Manager
    export FOX_ENABLE_APP_MANAGER=1                 # Enable App Manager
    export OF_OPTIONS_LIST_NUM=6                    # Number of options in lists
    export OF_CLASSIC_LEDS_FUNCTION=1               # Use classic LED function
    export OF_USE_GREEN_LED=0                       # Disable green LED

    # Filesystem & Maintenance Tools
    export OF_ENABLE_LPTOOLS=1                      # Enable logical partition tools
    export OF_BIND_MOUNT_SDCARD_ON_FORMAT=1         # Bind mount SD card when formatting
    export OF_UNBIND_SDCARD_F2FS=1                  # Unbind SD card for F2FS operations
    export OF_DONT_KEEP_LOG_HISTORY=1               # Do not keep recovery log history

    # OTA Updates Settings
    export OF_DISABLE_MIUI_OTA_BY_DEFAULT=1         # Disable MIUI OTA updates by default
    export OF_SUPPORT_ALL_BLOCK_OTA_UPDATES=1       # Support all block-based OTA updates
    export OF_FIX_OTA_UPDATE_MANUAL_FLASH_ERROR=1   # Fix manual flash errors in OTA

    # Dynamic partitions
    export FOX_USE_DYNAMIC_PARTITIONS=0             # Enable dynamic partitions support (Set to 0 to disable)

    # Keymaster4
    export FOX_USE_KEYMASTER_4=0                    # (Optional) Enable Keymaster 4

    # FRP
    export OF_ENABLE_FRP_ADDON=1

    # Kernel version: default 4.9; use 4.19 only when KERNEL_VERSION=4.19 is set
    if [ "$KERNEL_VERSION" != "4.19" ]; then
        export KERNEL_VERSION="4.9"
    fi

    # Apply settings based on partition type and Keymaster version
    if [ "$FOX_USE_DYNAMIC_PARTITIONS" = "1" ]; then
        # Device variant
        export FOX_VARIANT="unified"

        # Vanilla build flag
        export FOX_VANILLA_BUILD=1

        # Build all partition tools
        export OF_ENABLE_ALL_PARTITION_TOOLS=1

        # Settings for Dynamic Partitions
        export OF_QUICK_BACKUP_LIST="/boot;/data;"
        export FOX_RECOVERY_SYSTEM_PARTITION="/dev/block/mapper/system"
        export FOX_RECOVERY_VENDOR_PARTITION="/dev/block/mapper/vendor"

        # Disable OTA menu and checks for dynamic partitions
        export OF_DISABLE_OTA_MENU=1
        export OF_NO_ADDITIONAL_MIUI_PROPS_CHECK=1

        # Unset OTA support variables (equivalent to setting := empty)
        export OF_SUPPORT_ALL_BLOCK_OTA_UPDATES=""
        export OF_FIX_OTA_UPDATE_MANUAL_FLASH_ERROR=""
    else
        # Settings for Legacy Partitions (A-only or non-dynamic)
        export OF_QUICK_BACKUP_LIST="/boot;/data;/system_image;/vendor_image;"
    fi

    if [ "$FOX_USE_KEYMASTER_4" = "1" ]; then
        # Overrides if Keymaster 4 is enabled
        export FOX_VANILLA_BUILD=1
        export FOX_VARIANT="keymaster4"

        export OF_DISABLE_OTA_MENU=1
        export OF_NO_ADDITIONAL_MIUI_PROPS_CHECK=1

        # Unset OTA support variables
        export OF_SUPPORT_ALL_BLOCK_OTA_UPDATES=""
        export OF_FIX_OTA_UPDATE_MANUAL_FLASH_ERROR=""
    fi
else
    if [ -z "$FOX_BUILD_DEVICE" ] && [ -z "$BASH_SOURCE" ]; then
        echo "I: This script requires bash. Not processing the $FDEVICE $(basename $0)"
    fi
fi
