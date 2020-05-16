#!/bin/sh
#
# $chestnut_handy$
#
# Daily ZFS backup script

FS_LIST=$(zfs list -o name | tail +2)
DUMPDEV="/dev/da0s1a"
MOUNTPOINT="/media/backup"
DAY=$1

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
	LATEST_SNAPSHOT=$(zfs list -t snapshot -o name -d 1 -s creation ${fs} | tail -1)
	DUMPFILE=$(echo ${fs} | sed 's:/:_:g')
	LAST_FULL=`cat /usr/local/etc/lastfull.${DUMPFILE}`
	ZFS_SEND_CMD="zfs send -i ${LAST_FULL} ${LATEST_SNAPSHOT}"
	echo $ZFS_SEND_CMD
	$ZFS_SEND_CMD | xz > ${MOUNTPOINT}/${DUMPFILE}.${DAY}.zfsnap.xz
done

UMOUNT_CMD="umount ${DUMPDEV}"
echo $UMOUNT_CMD
$UMOUNT_CMD
