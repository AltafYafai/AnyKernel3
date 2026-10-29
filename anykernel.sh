### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Sky Linux 6.12 Kernel for Redmi 12 5G by @AltafYafai
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=sky
device.name2=redmi12_5g
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    6.12*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print " " "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# boot install
split_boot
if [ -f "$SPLITIMG/ramdisk.cpio" ] || [ -f "split_img/ramdisk.cpio" ]; then
    unpack_ramdisk
    write_boot
else
    flash_boot
fi
[ -f dtbo.img ] && flash_dtbo
## end boot install

## vendor_dlkm install for .ko modules
if [ -d modules ] && [ "$(ls -A modules/*.ko 2>/dev/null)" ]; then
    ui_print " " "Attempting to install kernel modules to vendor_dlkm..."
    mount -o rw /vendor_dlkm 2>/dev/null || mount -o rw /dev/block/mapper/vendor_dlkm$SLOT /vendor_dlkm 2>/dev/null || true
    if [ -d /vendor_dlkm/lib/modules ]; then
        cp -f modules/*.ko /vendor_dlkm/lib/modules/
        umount /vendor_dlkm 2>/dev/null || true
        ui_print "  -> Modules copied to /vendor_dlkm/lib/modules"
    else
        ui_print "  -> vendor_dlkm not directly mountable, skipping."
    fi
fi
## end vendor_dlkm install

