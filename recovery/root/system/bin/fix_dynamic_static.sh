#!/system/bin/sh
#
#   This file is part of the OrangeFox Recovery Project
#   Copyright (C) 2019-2024 The OrangeFox Recovery Project
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
# Sort out dynamic/non-dynamic clashes
# Sort out keymaster version issues
#

source /system/bin/sdm845tools.sh

# Try to retrieve the ROM's keymaster services version information
get_ROM_keymaster_version() {
    local D="/tmp/newV"
    local F
    local V
    V=$(readlink "/dev/block/by-name/vendor")

    rm -rf "$D"
    mkdir -p "$D"

    mount -r "$V" "$D"
    if [ "$?" -ne 0 ]; then
        echo "0"
        rmdir "$D"
        TESTING_LOG "DEBUGGER: can't mount vendor"
        return
    fi

    # Using glob patterns here intentionally to match version numbers
    local three="$D/etc/init/android.hardware.keymaster@3.?-service-qti.rc"
    local four="$D/etc/init/android.hardware.keymaster@4.?-service-qti.rc"

    if [ -n "$three" ] && [ -e $three ]; then
        TESTING_LOG "DEBUGGER: 3.0 - Entering $three"
        F=$(cat "$three" | grep "android.hardware.keymaster@3.")
        if [ -n "$F" ]; then
            TESTING_LOG "DEBUGGER: It's $F"
            echo "3.0"
        fi
    elif [ -n "$four" ] && [ -e $four ]; then
        TESTING_LOG "DEBUGGER: 4.0 - Entering $four"
        F=$(cat "$four" | grep "android.hardware.keymaster@4.")
        if [ -n "$F" ]; then
            TESTING_LOG "DEBUGGER: It is $F"
            echo "4.x"
        fi
    else
        TESTING_LOG "DEBUGGER: No keymaster information"
        echo "0"
    fi

    umount "$D"
    rmdir "$D"
    TESTING_LOG "DEBUGGER: Unmounted /vendor ($D)"
    sleep 0.2
}

# Keymaster services version stuff is a complete mess - try and fix on the fly
correct_the_keymaster_version() {
    local M="/vendor/etc/vintf/manifest.xml"
    local km3
    local km4
    local rom_km_ver

    km3=$(grep "@3.0::IKeymasterDevice/default" "$M")
    km4=$(grep "@4.0::IKeymasterDevice/default" "$M")
    rom_km_ver=$(get_ROM_keymaster_version)

    TESTING_LOG "Rom keymaster=[$rom_km_ver]; keymaster3=[$km3]; keymaster4=[$km4]"

    if [ "$rom_km_ver" = "4.x" ]; then
        [ -n "$km4" ] && return
        TESTING_LOG "Convert km3 flag to km4, in manifest.xml"
        sed -i 's|@3.0::IKeymasterDevice/default|@4.0::IKeymasterDevice/default|g' "$M"
        setprop keymaster_ver 4.0
    elif [ "$rom_km_ver" = "3.0" ]; then
        [ -n "$km3" ] && return
        TESTING_LOG "Convert km4 flag to km3, in manifest.xml"
        sed -i 's|@4.0::IKeymasterDevice/default|@3.0::IKeymasterDevice/default|g' "$M"
        setprop keymaster_ver 3.0
    fi
}

# Do the work
process_fstab_files() {
    local M="/vendor/etc/vintf/manifest.xml"
    local F="/system/etc/recovery.fstab"
    local TF="/system/etc/twrp.flags"
    local src_fstab="/system/etc/recovery-non-dynamic.fstab"
    local src_flags="/system/etc/twrp-non-dynamic.flags"
    local dyn
    local D

    dyn=$(is_dynamic_build)
    D=$(rom_has_dynamic_partitions)

    if [ "$D" = "1" ]; then
        if [ "$dyn" = "1" ]; then
            TESTING_LOG "Dynamic ROM"
            resetprop "fox_dynamic_device" "1"
            return
        else
            # Dynamic ROM on non-dynamic recovery!
            LOGMSG "Dynamic ROM on non-dynamic build. You *WILL* definitely have issues!"

            # Convert km3 flag to km4, in manifest.xml
            sed -i 's|@3.0::IKeymasterDevice/default|@4.0::IKeymasterDevice/default|g' "$M"
            src_fstab="/system/etc/recovery-dynamic.fstab"
            src_flags="/system/etc/twrp-dynamic.flags"
        fi
    else
        correct_the_keymaster_version
        [ "$dyn" != "1" ] && return # Non-dynamic ROM + non-dynamic recovery

        # Non-dynamic ROM on dynamic recovery
        TESTING_LOG "Non-dynamic ROM"
        TESTING_LOG "Discarding the 'Unmap Super Devices' menu"
        resetprop "fox_dynamic_device" "0"
    fi

    # Copy over the non-dynamic fstabs/flags files
    TESTING_LOG "Copying $src_fstab to $F"
    cp -a "$src_fstab" "$F"

    TESTING_LOG "Copying $src_flags to $TF"
    cp -a "$src_flags" "$TF"
}

TESTING_LOG "Running $0"
process_fstab_files
exit 0
