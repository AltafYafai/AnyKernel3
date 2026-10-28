### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=⛈️ ThunderBlast⚡ android12-5.10.X-lts-SukiSU GKI kernel with susfs 1.5.8+kpm by @AltafYafai
do.devicecheck=0
do.modules=1
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
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
if [ -f "split_img/ramdisk.cpio" ]; then
    unpack_ramdisk
    write_boot
else
    flash_boot
    [ -f dtbo.img ] && flash_dtbo
fi
## end boot install

## vendor_dlkm install for .ko modules
if [ -d modules ] && [ "$(ls -A modules/*.ko 2>/dev/null)" ]; then
    ui_print " " "Installing kernel modules to vendor_dlkm..."
    block=vendor_dlkm
    is_slot_device=auto
    reset_ak
    split_boot
    if [ -f "split_img/ramdisk.cpio" ]; then
        unpack_ramdisk
        mkdir -p ramdisk/lib/modules
        cp -f modules/*.ko ramdisk/lib/modules/
        write_boot
    else
        ui_print " " "Extracting modules directly..."
        mount -o rw /vendor_dlkm 2>/dev/null || mount -o rw /dev/block/mapper/vendor_dlkm$SLOT /vendor_dlkm 2>/dev/null || true
        if [ -d /vendor_dlkm/lib/modules ]; then
            cp -f modules/*.ko /vendor_dlkm/lib/modules/
            umount /vendor_dlkm 2>/dev/null || true
        else
            ui_print " " "vendor_dlkm mounting not available, modules copied into boot image."
        fi
    fi
fi
## end vendor_dlkm install
