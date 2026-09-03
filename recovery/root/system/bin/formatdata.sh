#!/system/bin/sh
#
#   Script to be executed  after formatting the data partition (dipper)
#   Format the metadata partition
#
#   Copyright (C) 2023-2024 OrangeFox Recovery Project
#   This file is part of the OrangeFox Recovery Project.
#
#   OrangeFox is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   OrangeFox is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   The GNU General Public License: see <http://www.gnu.org/licenses/>
#

source /system/bin/sdm845tools.sh

# Format the metadata partition using alternative methods
format_metadata() {
    local dyn
    dyn=$(rom_has_dynamic_partitions)

    [ "$dyn" != "1" ] && return

    local SUPPORTED_DEVICE="dipper,polaris"
    local META="/metadata"
    local block_base="/dev/block/bootdevice/by-name"
    local realmeta="${block_base}${META}"
    local cust="${block_base}/cust"
    local PART

    # Do we even have /metadata?
    [ ! -e "$META" ] && return

    # Ensure we have the right device, if specified
    if [ -n "$SUPPORTED_DEVICE" ]; then
        # Get the name of this device
        local currdev
        currdev=$(getprop "ro.product.device")

        # Can't get the current device
        [ -z "$currdev" ] && return

        # Are we on the right device?
        local ret
        ret=$(echo "$SUPPORTED_DEVICE" | grep -w "$currdev")

        [ -z "$ret" ] && return
    fi

    # Get the block device
    # Look first for a real metadata partition
    PART=$(readlink -e "$realmeta")

    # Then look for metadata mount on /cust
    [ -z "$PART" ] && PART=$(readlink -e "$cust")

    # No valid block - bale out
    [ -z "$PART" ] && return

    # Now proceed
    if ! umount "$META" 2>/dev/null; then
        LOGMSG "Error unmounting $META"
    fi

    LOGMSG "Formatting $META ..."
    if mke2fs -t ext4 -b 4096 "$PART"; then
        e2fsdroid -e -S /file_contexts -a "$META" "$PART"
    else
        LOGMSG "Formatting $META - error creating the filesystem ..."
    fi
}

TESTING_LOG "Running $0"
format_metadata
exit 0
