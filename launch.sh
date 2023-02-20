#!/bin/bash
#    Minecraft: Pi Edition: Reborn Bash Launcher
#    Copyright (C) 2022 bsX
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
launcherversion="1.01"
launcherPformat="1"

bld=$(tput bold)       # Bold
red=$(tput setaf 1)    # Red
grn=$(tput setaf 2)    # Green
ylw=$(tput setaf 3)    # Yellow
blu=$(tput setaf 4)    # Blue
pur=$(tput setaf 5)    # Purple
cyn=$(tput setaf 6)    # Cyan
wht=$(tput setaf 7)    # White
rst=$(tput sgr0)       # Text reset

function updater() {
# Download the ZSYNC file from TheBrokenRail's servers
if [ "$updateserver" = "mcpipp" ]; then
wget -q -O mcpi.zsync "https://github.com/NoozSBC/mcpi-reborn-extended/releases/latest/download/minecraft-pi-reborn-client-$cpuarch.AppImage.zsync"
else
wget -q -O mcpi.zsync "https://jenkins.thebrokenrail.com/job/minecraft-pi-reborn/job/master/lastSuccessfulBuild/artifact/out/minecraft-pi-reborn-client-latest-$cpuarch.AppImage.zsync" 
fi

# Retrieve the first 2 lines of data from the zsync file.
zsync_out=`grep -a -A1 zsync mcpi.zsync`
# For reference: -a tells it to output binary data like it's a text file, since only part of a zsync file contains actual text information (and that's all we need)
# -A1 zsync tells it to find the line with "zsync" in it, and output that line and the next line of data
# We're excluding the rest of the lines since this is only needed to get the current release of mcpi-r

# Remove our ZSYNC file
rm -rf mcpi.zsync

# Cut the first line out of the string, we don't need it
zsync_out=$(echo "$zsync_out" | sed 1d)

# Strip the Zsync variable identifier
zsync_out=${zsync_out//Filename: /}

# Check if we already have this game version
ver_check=`ls $zsync_out`
if [ "$ver_check" != "$zsync_out" ]
then
# Tell the user what we're doing
echo ""
echo "Your MCPI-Reborn version is outdated. Updating..."
echo ""
# Move any existing mcpi AppImages to a temporary folder
mkdir -p "old"
mv -i minecraft-pi-reborn-client-*.AppImage "old"

# Download the game AppImage
if [ "$updateserver" = "mcpipp" ]; then
wget -q "https://github.com/NoozSBC/mcpi-reborn-extended/releases/latest/download/$zsync_out"
else
wget -q "https://jenkins.thebrokenrail.com/job/minecraft-pi-reborn/job/master/lastSuccessfulBuild/artifact/out/$zsync_out"
fi

# Set the game AppImage executable
chmod +x $zsync_out
fi
}
echo ""
echo "Minecraft: Pi Edition: Reborn Bash Launcher
Copyright (C) 2022 bsX

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>."
echo ""
# Open the configuration script if the user hasn't configured their game yet
cfg_check=`ls config.bcfg`
if [ "$cfg_check" != "config.bcfg" ]
then
# Set a variable so that the configuration script doesn't bark at the user for resetting their configuration (which is nonexistant)
cfg_new="1"
. configure.sh
fi
. config.bcfg

# Check for command-line arguments
if [[ "$1" == "--help" || "$1" == "-h" ]];
then
echo "bMCPIL Help:"
echo ""
echo "Arguments: ./launch.sh [preset]"
echo ""
exit
elif [ ! -z "$1" ]; # If a non-null, none flag argument was passed, treat it as a preset
then
preset_check=`ls ./presets/$1`
	if [ "$preset_check" != "./presets/$1" ] # Make sure the preset specified actually exists
	then
	echo "${red}[Error] Unknown preset specified from the command line [$1]. Loading from default.${rst}"
	. ./presets/default
	else
	presetsel="$1" # Overwrite the preset set in the config
	fi
fi

# Check if the user's selected preset actually exists. If not, load the default
preset_check=`ls ./presets/$presetsel`
if [ "$preset_check" != "./presets/$presetsel" ]
then
echo "${red}[Error] Unknown preset [$presetsel], please reconfigure your game. Loading from normal.${rst}"
. ./presets/normal
else
. ./presets/$presetsel
fi

if [[ "$enableupdater" == "false" ]];
then
game_check=`ls minecraft-pi-reborn-client-*.AppImage`
	if [ "$game_check" == "" ]
	then
	echo "${red}[Error] Can't find MCPI AppImage. Try enabling the updater in your config.${rst}"
	fi
else
updater
fi

if [[ "$enableskins" != "false" ]];
then
if [ -d ~/.minecraft-pi/overrides/images/skins/.git/ ]; then
git -C ~/.minecraft-pi/overrides/images/skins/ pull https://github.com/bsx-gh/bMCPIL-skins.git
elif [ -d ~/.minecraft-pi/overrides/images/skins/ ]; then
mv ~/.minecraft-pi/overrides/images/skins/ ~/.minecraft-pi/overrides/images/skins-old/
git clone --quiet https://github.com/bsx-gh/bMCPIL-skins.git ~/.minecraft-pi/overrides/images/skins/
else
git clone --quiet https://github.com/bsx-gh/bMCPIL-skins.git ~/.minecraft-pi/overrides/images/skins/
fi
fi

if [[ "$usedefaultflags" == "true" ]]; then
MCPI_RENDER_DISTANCE="$renderdistance" MCPI_USERNAME="$username" ./minecraft-pi-reborn-client-*.AppImage --default --no-cache
elif [[ "$askonlaunch" == "true" ]]; then
MCPI_RENDER_DISTANCE="$renderdistance" MCPI_USERNAME="$username" ./minecraft-pi-reborn-client-*.AppImage --no-cache
elif [[ "$normallaunch" == "true" ]]; then
MCPI_RENDER_DISTANCE="$renderdistance" MCPI_USERNAME="$username" ./minecraft-pi-reborn-client-*.AppImage
else
MCPI_FEATURE_FLAGS="$preset" MCPI_RENDER_DISTANCE="$renderdistance" MCPI_USERNAME="$username" ./minecraft-pi-reborn-client-*.AppImage --no-cache
fi


echo ""
if [[ "$asktoexit" == "true" ]];
then
    read -p "Press [Enter] to close the program."
fi
