#!/bin/sh
#
# Weekly tar(1) archive of user files
#
FSLIST="/usr/home /var/spool/ftp /var/spool/nas /var/spool/nas/critical /var/mail"
TAR="/usr/bin/tar"
TARARGS="--nodump --one-file-system --totals"

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
	TARCMD="$TAR cvJf ${MOUNTPOINT}/${ARCHIVE}.weekly.tar.xz $TARARGS $fs"
	echo $TARCMD
	$TARCMD
	rc=$?

	if [ $rc -ne 0 ]
	then
		exit $rc
	fi
done

UMOUNT_CMD="umount ${DUMPDEV}"
echo $UMOUNT_CMD
$UMOUNT_CMD
