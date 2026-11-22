#!/bin/bash
# fresh install with LaunchCount preset so every ad gate stays closed
U=${SIM_UDID:-39D7367E-86EA-41EA-8AC9-48F907B48F02}
xcrun simctl terminate $U com.credif.letscheers 2>/dev/null
xcrun simctl uninstall $U com.credif.letscheers
xcrun simctl install $U "${1:?usage: fresh.sh path/to/App.app (Debug simulator build)}"
D=$(xcrun simctl get_app_container $U com.credif.letscheers data)
mkdir -p $D/Library/Preferences; P=$D/Library/Preferences/com.credif.letscheers.plist
echo '<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict><key>LaunchCount</key><integer>-5</integer></dict></plist>' > $P
xcrun simctl status_bar $U override --time 9:41 --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3
