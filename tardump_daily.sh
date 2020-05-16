#!/bin/sh
#
# Daily tar(1) archive of user files
#

DUMPDEV="/dev/da0s1a"
MOUNTPOINT="/media/backup"
FSLIST="/usr/home /var/spool/ftp /var/spool/nas /var/spool/nas/critical /var/mail"
TAR="/usr/bin/tar"
TARARGS="--nodump --one-file-system --totals"
DAY=`date '+%A'`

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

for fs in $FSLIST
do
	ARCHIVE="$(echo ${fs} | sed 's:/::' | sed 's:/:_:g')"
	WEEKLY_TAR="${MOUNTPOINT}/${ARCHIVE}.weekly.tar.xz"
	TARCMD="$TAR cvJf ${MOUNTPOINT}/${ARCHIVE}.${DAY}.tar.xz --newer-than $WEEKLY_TAR $TARARGS $fs"
	echo $TARCMD
	$TARCMD
done

UMOUNT_CMD="umount ${DUMPDEV}"
echo $UMOUNT_CMD
$UMOUNT_CMD
