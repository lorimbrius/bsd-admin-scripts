#!/bin/sh
#
# $chestnut_handy$
#
# Daily backup script

DUMPDEV="/dev/da0s1a"
MOUNTPOINT="/media/backup"
DUMPCMD="/sbin/dump"
LEVEL=$1
DUMPOPTS="-C16 -b64 -${LEVEL}aLu -f -"
FS_LIST="/var/spool/nas/critical /var/backups /var/account /var/audit /var/log"
OWNER="root:operator"
PERMISSIONS="0660"

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
	if [ "$fs" = "/" ]
	then
		DUMPFILE="rootfs.${LEVEL}.xz"
	else
		DUMPFILE="$(echo ${fs} | sed 's:/::' | sed 's:/:_:g' ).${LEVEL}.xz"
	fi

	CMDLINE="$DUMPCMD $DUMPOPTS ${fs}"

	echo $CMDLINE
	$CMDLINE | xz > ${MOUNTPOINT}/${DUMPFILE}
	rc=$?

	if [ $rc -ne 0 ]
	then
		exit $rc
	fi

	xzcat < ${MOUNTPOINT}/${DUMPFILE} | restore -tf - > ${MOUNTPOINT}/${DUMPFILE}.toc

	chown ${OWNER} ${MOUNTPOINT}/${DUMPFILE}
	chmod ${PERMISSIONS} ${MOUNTPOINT}/${DUMPFILE}
done

UMOUNT_CMD="umount ${DUMPDEV}"
echo $UMOUNT_CMD
$UMOUNT_CMD
