#!/bin/sh

DESIRED_IDENT="CHESTNUT_HANDY"
CURRENT_IDENT=`uname -i`

if [ "$CURRENT_IDENT" != "$DESIRED_IDENT" ]
then
	mail -s "Kernel IDENT mismatch" root <<EOF
The current kernel is a $CURRENT_IDENT kernel instead of the desired $DESIRED_IDENT kernel. Please recompile the kernel.
EOF
fi

if [ ! -d /boot/GENERIC ]
then
	mail -s "GENERIC kernel image missing" root <<EOF
The GENERIC kernel image is missing from /boot. Please compile and install a GENERIC kernel to /boot/GENERIC.
EOF
fi


