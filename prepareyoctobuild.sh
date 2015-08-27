#!/bin/sh

# Create the build folder
source poky/oe-init-build-env build_parallella

# Copy configuration
cp ../local_conf/*.conf ./conf

echo "==========================="
echo "environment prepared"
echo " "
echo "be prepared for a long wait"
echo "try the command:"
echo "   bitbake hdmi-image"
echo " "
echo "If you want to try out the hdmi & hdmi sound example"
echo "try the command:"
echo "   bitbake hdmi-image-example"
echo " "
