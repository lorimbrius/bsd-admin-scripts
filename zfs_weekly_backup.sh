#!/bin/sh
#
# $chestnut_handy$
#
# Daily ZFS backup script

FS_LIST=$(zfs list -o name | tail +2)
DUMPDEV="/dev/da0s1a"
MOUNTPOINT="/media/backup"

mounted=$(df | grep ${DUMPDEV} | wc -l)

if [ $mounted -ne 0 ]
then
	UMOUNT_CMD="umount ${DUMPDEV}"
	echo $UMOUNT_CMD
	$UMOUNT_CMD
	rc=$?

	if [ $rc -ne 0 ]
	then
		exit $rc
	fi
fi

FSCK_CMD="fsck -n ${DUMPDEV}"
echo $FSCK_CMD
$FSCK_CMD
rc=$?

if [ $rc -ne 0 ]
then
	exit $rc
fi

MOUNT_CMD="mount ${DUMPDEV} ${MOUNTPOINT}"
echo $MOUNT_CMD
$MOUNT_CMD
rc=$?

if [ $rc -ne 0 ]
then
	exit $rc
fi

for fs in $FS_LIST
do
	DELETE_PATTERN=$(echo ${fs} | sed 's:/:_:g')
	DELETE_CMD="rm -f ${MOUNTPOINT}/${DELETE_PATTERN}*.zfsnap.xz"
	echo $DELETE_CMD
	$DELETE_CMD

	LATEST_SNAPSHOT=$(zfs list -t snapshot -o name -d 1 -s creation -r ${fs} | tail -1)
	DUMPFILE=$(echo ${LATEST_SNAPSHOT} | sed 's:/:_:g')
	ZFS_SEND_CMD="zfs send ${LATEST_SNAPSHOT}"
	echo $ZFS_SEND_CMD
	$ZFS_SEND_CMD | xz > ${MOUNTPOINT}/${DUMPFILE}.0.zfsnap.xz
	echo ${LATEST_SNAPSHOT} > /usr/local/etc/lastfull.${DELETE_PATTERN}
done

UMOUNT_CMD="umount ${DUMPDEV}"
echo $UMOUNT_CMD
$UMOUNT_CMD
