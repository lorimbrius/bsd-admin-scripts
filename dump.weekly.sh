#!/bin/sh
#
# $chestnut_handy$
#
# Weekly backup script

DUMPDEV="/dev/da0s1a"
MOUNTPOINT="/media/backup"
DUMPCMD="/sbin/dump"
DUMPOPTS="-C16 -b64 -1aLu -f -"
FS_LIST="/ /usr/local /var/spool/nas/critical /var/crash /var/backups /var/account /var/audit /var/log"
ABCD=$1
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
		DUMPFILE="rootfs.1${ABCD}.xz"
	else
		DUMPFILE="$(echo ${fs} | sed 's:/::' | sed 's:/:_:g' ).1${ABCD}.xz"
	fi

	CMDLINE="$DUMPCMD $DUMPOPTS ${fs}"

	echo $CMDLINE
	$CMDLINE | xz > ${MOUNTPOINT}/${DUMPFILE}
	rc=$?

	if [ $rc -ne 0 ]
	then
		exit $rc
	fi

	chown ${OWNER} ${MOUNTPOINT}/${DUMPFILE}
	chmod ${PERMISSIONS} ${MOUNTPOINT}/${DUMPFILE}

	xzcat < ${MOUNTPOINT}/${DUMPFILE} | restore -tf - > ${MOUNTPOINT}/${DUMPFILE}.toc
done

UMOUNT_CMD="umount ${DUMPDEV}"
echo $UMOUNT_CMD
$UMOUNT_CMD
