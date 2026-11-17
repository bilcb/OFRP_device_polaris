#!/system/bin/sh
#
#   This file is part of the OrangeFox Recovery Project
#   Copyright (C) 2023-2024 The OrangeFox Recovery Project
#
#   OrangeFox is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   any later version.
#
#   OrangeFox is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   This software is released under GPL version 3 or any later version.
#   See <http://www.gnu.org/licenses/>.
#
#   Please maintain this if you use this script or any part of it
#
#
# Deal with situations where recovery is built for dynamic ROMs, but the current ROM is non-dynamic
#

source /system/bin/sdm845tools.sh

# Change the dynamic build into non-dynamic, on the fly, as far as is possible
morph_into_non_dynamic() {
    local F

    # Ensure that we're running the dynamic variant of OrangeFox
    F=$(is_dynamic_build)
    [ "$F" != "1" ] && return

    # Confirm that the "Super" symlinks have been created
    F=$(getprop "twrp.super.symlinks_created")
    # The ROM is dynamic - no further processing is required
    [ "$F" = "true" ] && return

    # If we get here, we are running a standard ROM on a retrofitted-dynamic recovery
    # Try to convert this recovery to a standard (non-dynamic) version
    LOGMSG "Non-dynamic ROM"
    resetprop "ro.orangefox.standard_rom_on_dynamic_recovery" "true" # Flag this

    # Deal with the (now) obsolete props
    LOGMSG "Resetting some props relating to dynamic partitions ..."

    # Delete these general dynamic props
    resetprop --delete "ro.boot.dynamic_partitions"
    resetprop --delete "ro.boot.dynamic_partitions_retrofit"

    # Delete these fox dynamic props
    resetprop --delete "orangefox.super.block_device"
    resetprop --delete "orangefox.system.block_device"
    resetprop --delete "orangefox.vendor.block_device"
    resetprop --delete "orangefox.product.block_device"

    resetprop --delete "orangefox.super.mount_point"
    resetprop --delete "orangefox.system.mount_point"
    resetprop --delete "orangefox.vendor.mount_point"
    resetprop --delete "orangefox.product.mount_point"

    # Reset these ones
    resetprop "orangefox.super.partition" "false"
    resetprop "ro.orangefox.variant" "dynamic-with-static-rom"
}

TESTING_LOG "Running $0"
morph_into_non_dynamic
exit 0
