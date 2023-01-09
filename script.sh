#!/bin/bash

function run {
    clean_bt_cache

    read -p "Still not working? Try full reset and restore? (y/N): " uin
    [[ "$uin" == "y" ]] && reset_and_restore_bt

    read -p "Still not working? Try just full reset? (y/N): " uin
    [[ "$uin" == "y" ]] && reset_bt

    read -p "Still not working? Try restart pipewire if you use headphones? (y/N): " uin
    [[ "$uin" == "y" ]] && restart_pipewire

    echo "OPERATION COMPLETE, PRESS ENTER TO CLOSE"
    read hold
}

function clean_bt_cache {
    echo "cleaning bluetooth cache"

    local btFolderContentsArr=($(sudo ls /var/lib/bluetooth))
    local adapterName
    for adapterName in "${btFolderContentsArr[@]}"; do
        sudo rm -r "/var/lib/bluetooth/$adapterName/cache"
    done

    sudo systemctl restart bluetooth
    wait_till "systemctl is-active bluetooth" "active"
}

function reset_and_restore_bt {
    echo "resetting and restoring bluetooth"

    sudo mv /var/lib/bluetooth /root

    sudo systemctl restart bluetooth
    wait_till "systemctl is-active bluetooth" "active"
    echo "wait 5s"
    sleep 5

    local btFolderContentsArr=($(sudo ls /root/bluetooth))
    local adapterName
    for adapterName in "${btFolderContentsArr[@]}"; do
        sudo rm -r "/root/bluetooth/$adapterName/cache" 2>/dev/null
    done

    sudo rm -r /var/lib/bluetooth
    sudo mv -f /root/bluetooth /var/lib

    sudo systemctl restart bluetooth
    wait_till "systemctl is-active bluetooth" "active"
}

function reset_bt {
    echo "resetting bluetooth"
    sudo rm -r /var/lib/bluetooth
    sudo systemctl restart bluetooth
    wait_till "systemctl is-active bluetooth" "active"
}

function restart_pipewire {
    echo "restarting pipewire"
    systemctl --user restart pipewire
    wait_till "systemctl --user is-active pipewire" "active"
}

# $1 = criteria // $2 = to compare to
function wait_till {
    while true; do
        [ $($1) == "$2" ] && break
        sleep 1
    done
}
 
run
