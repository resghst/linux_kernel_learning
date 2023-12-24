
export STAGE="$PWD"
export OUT_DIR="$STAGE/out"
export KERNELDIR="$OUT_DIR/obj/linux-x86-test"

echo "rootpath: $STAGE"
echo "kernal: $KERNELDIR"

cd ldd3
make