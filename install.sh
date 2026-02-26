#!/usr/bin/env bash
#"""
SCRIPT_NAME=$(basename "$0")
ABS_PATH=$(dirname -- "$( readlink -f -- "$0"; )"; )
PNAME=$(echo $ABS_PATH | awk -F '/' '{print $(NF-1)}')
SNAME=$(echo $ABS_PATH | awk -F '/' '{print $(NF)}')
if [ ! -f "$ABS_PATH"/.env ]; then
    source "$ABS_PATH"/.env
fi
#"""

logger -s "SCRIPT_NAME="$SCRIPT_NAME""
logger -s "ABS_PATH="$ABS_PATH""
logger -s "PNAME="$PNAME""
logger -s "SNAME="$SNAME""

INSTALL_DIR="/opt/$SNAME/"

# Get the options
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--directory)
      INSTALL_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    -i|--iso)
      ISO="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

logger -s "install directory = ${INSTALL_DIR}"
logger -s "iso = ${ISO}"

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

mkdir -p $INSTALL_DIR/mount
mkdir -p $INSTALL_DIR/unpack_iso
mkdir -p $INSTALL_DIR/unpack_squashfs
mkdir -p $INSTALL_DIR/export
rm -rf $INSTALL_DIR/export/*

mount -o loop,ro $ISO $INSTALL_DIR/mount

logger -s "copying data from ISO mount to unpack dir, may take some time"
rsync -a $INSTALL_DIR/mount/ $INSTALL_DIR/unpack_iso

logger -s "unpacking squashfs, may take some time"
unsquashfs -f -d  $INSTALL_DIR/unpack_squashfs $INSTALL_DIR/unpack_iso/LiveOS/squashfs.img

cp $ABS_PATH/squashfs_inserts/losvie-pubkeys.sh $INSTALL_DIR/unpack_squashfs/opt/
chmod +x $INSTALL_DIR/unpack_squashfs/opt/losvie-pubkeys.sh
cp $ABS_PATH/squashfs_inserts/losvie-pubkeys.service $INSTALL_DIR/unpack_squashfs/etc/systemd/system/
ln -s /etc/systemd/system/losvie-pubkeys.service $INSTALL_DIR/unpack_squashfs/etc/systemd/system/multi-user.target.wants/losvie-pubkeys.service


cp $ABS_PATH/squashfs_inserts/losvie-firewall.sh $INSTALL_DIR/unpack_squashfs/opt/
chmod +x $INSTALL_DIR/unpack_squashfs/opt/losvie-firewall.sh
cp $ABS_PATH/squashfs_inserts/losvie-firewall.service $INSTALL_DIR/unpack_squashfs/etc/systemd/system/
ln -s /etc/systemd/system/losvie-firewall.service $INSTALL_DIR/unpack_squashfs/etc/systemd/system/multi-user.target.wants/losvie-firewall.service

cp $ABS_PATH/squashfs_inserts/losvie-restart-network.sh $INSTALL_DIR/unpack_squashfs/opt/
chmod +x $INSTALL_DIR/unpack_squashfs/opt/losvie-restart-network.sh
cp $ABS_PATH/squashfs_inserts/losvie-restart-network.service $INSTALL_DIR/unpack_squashfs/etc/systemd/system/
cp $ABS_PATH/squashfs_inserts/losvie-restart-network.timer $INSTALL_DIR/unpack_squashfs/etc/systemd/system/
ln -s /etc/systemd/system/losvie-restart-network.service $INSTALL_DIR/unpack_squashfs/etc/systemd/system/multi-user.target.wants/losvie-restart-network.service
ln -s /etc/systemd/system/losvie-restart-network.timer $INSTALL_DIR/unpack_squashfs/etc/systemd/system/multi-user.target.wants/losvie-restart-network.timer

umount $INSTALL_DIR/mount

logger -s "packing squashfs, may take some time"
mksquashfs $INSTALL_DIR/unpack_squashfs/ $INSTALL_DIR/export/losvie.squashfs

cp $INSTALL_DIR/unpack_iso/images/pxeboot/initrd.img $INSTALL_DIR/export/
cp $INSTALL_DIR/unpack_iso/images/pxeboot/vmlinuz $INSTALL_DIR/export/

#cp $ABS_PATH/glue/losvie.ipxe

# You can comment this out, but I've foudn squashfs doing weird stuff with overlap so I like to just clear it umount
rm -rf $INSTALL_DIR/mount
rm -rf $INSTALL_DIR/unpack_iso
rm -rf $INSTALL_DIR/unpack_squashfs
