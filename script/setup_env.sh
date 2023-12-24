
sudo apt-get install curl libncurses5-dev qemu-system-x86 libelf-dev

export LINUX_VER="6.6.7"
export BUSY_VER="1.36.1"

export MAKEFLAGS=j2

export LINUX_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$LINUX_VER.tar.xz"
export BUSY_URL="https://busybox.net/downloads/busybox-$BUSY_VER.tar.bz2"

export STAGE="$PWD"
export SCRIPT="$PWD/script"
export OUT_DIR="$STAGE/out"

export DIR_BUSYBOX="$STAGE/busybox-$BUSY_VER"
export OBJ_BUSYBOX="$OUT_DIR/obj/busybox-x86"
export FS_BUSYBOX="$OUT_DIR/initramfs/x86-busybox"
export CONFIG_BUSYBOX="$SCRIPT/busybox.config"

export DIR_KERNEL="$STAGE/linux-$LINUX_VER"
export OBJ_KERNEL="$OUT_DIR/obj/linux-x86"
export CONFIG_KERNEL="$SCRIPT/kernel.config"


echo "LINUX_VER: $LINUX_VER"
echo "BUSY_VER:  $BUSY_VER"
echo "LINUX_URL: $LINUX_URL"
echo "BUSY_URL:  $BUSY_URL"
echo "==="
echo "STAGE:       $STAGE"
echo "OUT_DIR:     $OUT_DIR"
echo "==="
echo "DIR_BUSYBOX: $DIR_BUSYBOX"
echo "OBJ_BUSYBOX: $OBJ_BUSYBOX"
echo "FS_BUSYBOX:  $FS_BUSYBOX"

echo "DIR_KERNEL:  $DIR_KERNEL"
echo "OBJ_KERNEL:  $OBJ_KERNEL"


echo "==="
echo "==="
echo "==="
echo "Clone SOURCE"
cd $STAGE
curl $LINUX_URL | tar xJf -
curl $BUSY_URL | tar xjf -

echo "==="
echo "==="
echo "Build BusyBox"
cd $DIR_BUSYBOX
mkdir -pv $OBJ_BUSYBOX
cp $CONFIG_BUSYBOX $OBJ_BUSYBOX/.config
make O=$OBJ_BUSYBOX -$MAKEFLAGS
cd $OBJ_BUSYBOX
make install

echo "==="
echo "==="
echo "Setup BusyBox"
mkdir -pv $FS_BUSYBOX
cd $FS_BUSYBOX
mkdir -pv {bin,dev,sbin,etc,proc,sys/kernel/debug,usr/{bin,sbin},lib,lib64,mnt/root,root}
cp -av $OBJ_BUSYBOX/_install/* $FS_BUSYBOX
sudo cp -av /dev/{null,console,tty} $FS_BUSYBOX/dev/

echo "==="
echo "==="
echo "Gen BusyBox Image"
cp $SCRIPT/busybox_init $FS_BUSYBOX

cd $FS_BUSYBOX
find . | cpio -H newc -o > ../initramfs.cpio
cd ..
cat initramfs.cpio | gzip > $OUT_DIR/obj/initramfs.igz

echo "==="
echo "==="
echo "Build Kernel"
cd $DIR_KERNEL
mkdir -pv $OBJ_KERNEL
cp $CONFIG_KERNEL $OBJ_KERNEL/.config
make O=$OBJ_KERNEL -$MAKEFLAGS