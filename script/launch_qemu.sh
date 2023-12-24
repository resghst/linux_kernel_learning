
export STAGE="$PWD"
export OUT_DIR="$STAGE/out"

export FS_BUSYBOX="$OUT_DIR/initramfs/x86-busybox"
export IMG_BUSYBOX="$OUT_DIR/obj/initramfs.igz"

cd $FS_BUSYBOX
find . | cpio -H newc -o > ../initramfs.cpio
cd ..
cat initramfs.cpio | gzip > $IMG_BUSYBOX

qemu-system-x86_64 \
    -kernel $OUT_DIR/obj/linux-x86-test/arch/x86/boot/bzImage \
    -initrd $IMG_BUSYBOX \
    -nographic -append "earlyprintk=serial,ttyS0 console=ttyS0"