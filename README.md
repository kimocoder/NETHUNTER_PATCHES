# Updates CAF to Android source (merge upstream)

An example, for me with OnePlus 6 with msm-4.4* kernel.
```
Find your device id/tag at https://wiki.codeaurora.org/xwiki/bin/QAEP/release
https://source.codeaurora.org/quic/la/kernel/msm-4.4/

# For me the download will be..
git fetch https://source.codeaurora.org/quic/la/kernel/msm-4.4/ LA.UM.7.3.r1-07400-sdm845.0
```
# opo_dwc3_otg - also known as the OTG-Y or Y-cable patch before. ACA mode hack information is below.
# remember: patches will not fit, since your code most likely not like the patchers. manual editing/exploring

ACA mode hack for Oneplus One's DWC3 usb driver

A mod for the Oneplus One DWC3 otg module. This allows for charging and host mode simultaneously, inspired by Ziddey's msm_otg mod for the Nexus 4/7 (2013) (https://github.com/ziddey/mako/commits/nightlies-4.3-JSS). Functionality was ported over from his kernel hack to the DWC3 USB driver which now handles the MSM8974 USB controller. 

The hack works through setting a custom module parameter I've added to allow 'ACA' host mode. This flag effectively turns on ID_A host mode while disabling VBUS power going to the hosted device. I've uploaded the modded dwc3_otg.c file that you can replace in your Oneplus One(bacon) kernel source of choice. It'll be located in the drivers/usb/dwc3/ directory. I've also uploaded my personal kernel image with this hack built on top of Franco's kernel (https://github.com/franciscofranco/one_plus_one). It also has other modules built into it, mainly DRM/Devtmpfs/Cifs/NFS/NTFS/Alsa Sequencer/Usbip/Binfmt/loadable modules/etc... It was compiled with GCC 4.9 NDK version.

Usage:
First you'll need either a generic Y split USB OTG cable or a powered USB hub connected to regular OTG(I've only tested the Y cable).

With the modified kernel flashed, open a terminal shell and as root, enter the following command:
"echo Y > /sys/module/dwc3/parameters/aca_enable"

This activates the 'ACA' host mode hack.

Plug the phone's charger and USB device(s) into the Y-adapter before attaching it to the phone. Once everything is connected, the phone should start to charge and enter host mode. You can test by running the lsusb command in the shell using either BusyBox or Linux chroot.

Please, if you can test the powered hub method or have improvements to this hack, feel free to share! Also, the standard legal disclaimer applies here that by using this mod/code/kernel in anyway is completely your responsibility. I'm not liable for any possible damages to your devices.

## More information

https://forum.xda-developers.com/z5-compact/development/kernel-patch-usb-otg-host-mode-t3668119

https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842069/USB

https://www.kernel.org/doc/html/v4.18/driver-api/usb/dwc3.html

https://github.com/rajeshdubey293/al-ice_cedric/commit/25fccb73a8a1c85ba109da4cffb4a2b0c91d4b80
