#/bin/bash

get_possible_fs () 
{
	possible_fs=
	local fs
	for fs in "${!filesystem_programs[@]}"
	do
		which ${filesystem_programs[$fs]} &>/dev/null && possible_fs=("${possible_fs[@]}" $fs)
	done
	true
}

interactive_prepare_disks ()
{
	DONE=0
	local ret=1 # 1 means unsuccessful. 0 for ok
	DISK_CONFIG_TYPE=
	[ "$BLOCK_ROLLBACK_USELESS" = "0" ] && show_warning "Rollback may be needed" "It seems you already went here.  You should probably rollback previous changes before reformatting, otherwise stuff will probably fail"
	local default=no
	while [ "$DONE" = "0" ]
	do
		rollbackstr=" (you don't need to do this)"
		[ "$BLOCK_ROLLBACK_USELESS" = "0" ] && rollbackstr=" (this will revert your last changes)"

		_dia_ask_option $default "Prepare Hard Drive" '' required \
			"1" "Auto-Prepare (erases an ENTIRE hard drive and sets up partitions, filesystems and mountpoints)" \
			"2" "Manually Partition Hard Drives" \
			"3" "Return to Main Menu" || return 1

		case $ANSWER_OPTION in
			"1")
				[ "$BLOCK_ROLLBACK_USELESS" = "0" ] && _dia_ask_yesno "You should probably rollback your last changes first, otherwise this will probably fail.  Go back to menu to do rollback?" && default=4 && continue
				interactive_autoprepare && default=5 && ret=0 && DISK_CONFIG_TYPE=auto;;
			"2")
				[ "$BLOCK_ROLLBACK_USELESS" = "0" ] && __dia_ask_yesno "You should probably rollback your last changes first, otherwise this will probably fail.  Go back to menu to do rollback?" && default=4 && continue
				interactive_partition && ret=1 && default=3 && DISK_CONFIG_TYPE=manual;;
			"3")
				DONE=1 ;;
		esac
	done
	return $ret
}

interactive_autoprepare()
{
	listblockfriendly
	if [ ${#BLOCKFRIENDLY[@]} -gt 2 ]
	then
		_dia_ask_option no 'Harddrive selection' "Select the hard drive to use" required "${BLOCKFRIENDLY[@]}" || return 1
		DISC=$ANSWER_OPTION
	elif [ ${#BLOCKFRIENDLY[@]} -eq 0 ]; then
		_dia_ask_string "Could not find disk. Please enter path of devicefile manually" "" || return 1
		DISC=${ANSWER_STRING// /} # TODO : some checks if $DISC is really a blockdevice is probably a good idea
	else
		DISC=${BLOCKFRIENDLY[0]}
	fi

	local FSOPTS=()
	local fs
	for fs in ext2 ext3 ext4 reiserfs xfs jfs vfat nilfs2 btrfs
	do
		check_is_in $fs "${possible_fs[@]}" && FSOPTS+=($fs "${filesystem_names[$fs]}")
	done
	get_blockdevice_size $DISC MiB
	local size_left=$BLOCKDEVICE_SIZE

	_dia_ask_number "Enter the size (MiB) of your /boot partition.  Recommended size: 100MiB\n\nDisk space left: $size_left MiB" 16 $size_left 100 || return 1
	BOOT_PART_SIZE=$ANSWER_NUMBER
	size_left=$(($size_left-$BOOT_PART_SIZE))

	_dia_ask_number "Enter the size (MiB) of your swap partition.  Recommended size: 256MiB\n\nDisk space left: $size_left MiB" 1 $size_left 256 || return 1
	SWAP_PART_SIZE=$ANSWER_NUMBER
	size_left=$(($size_left-$SWAP_PART_SIZE))

	local suggest_root=7500
	# if the disk is too small to hold a 7.5GB root and 5GB home (these are arbitrary numbers), just give root 3/4 of the size, if that's too small leave it up to the user
	[ $(($suggest_root+5000)) -gt $size_left ] && suggest_root=$(($size_left*3/4))
	_dia_ask_number "Enter the size (MiB) of your / partition.  Recommended size:7500.  The /home partition will use the remaining space.\n\nDisk space left:  $size_left MiB" 1 $size_left $suggest_root || return 1
	ROOT_PART_SIZE=$ANSWER_NUMBER
	HOME_PART_SIZE=$(($size_left-$ROOT_PART_SIZE))

	_dia_ask_option no 'Filesystem selection' "Select a filesystem for / and /home:" required "${FSOPTS[@]}" || return 1
	FSTYPE=$ANSWER_OPTION

	echo "$DISC $BOOT_PART_SIZE:ext2:+ $SWAP_PART_SIZE:swap $ROOT_PART_SIZE:$FSTYPE *:$FSTYPE" > $TMP_PARTITIONS

	echo "${DISC}1 raw no_label ext2;yes;/boot;target;no_opts;no_label;no_params"         >  $TMP_BLOCKDEVICES
	echo "${DISC}2 raw no_label swap;yes;no_mountpoint;target;no_opts;no_label;no_params" >> $TMP_BLOCKDEVICES
	echo "${DISC}3 raw no_label $FSTYPE;yes;/;target;no_opts;no_label;no_params"          >> $TMP_BLOCKDEVICES
	echo "${DISC}4 raw no_label $FSTYPE;yes;/home;target;no_opts;no_label;no_params"      >> $TMP_BLOCKDEVICES

msg="/boot $BOOT_PART_SIZE MiB
swap  $SWAP_PART_SIZE MiB
/     $ROOT_PART_SIZE MiB ($FSTYPE)
/home $HOME_PART_SIZE MiB ($FSTYPE)

$DISC will be COMPLETELY ERASED!  Are you absolutely sure?"
	_dia_ask_yesno "$msg" || return 1

	PART_ACCESS=uuid

	process_disks       || die_error "Something went wrong while partitioning"
	if ! process_filesystems
	then
		show_warning "Filesystem processing" "Something went wrong while processing the filesystems.  Attempting rollback."
		if rollback_filesystems
		then
			show_warning "Filesystem rollback" "Rollback succeeded.  Please try to figure out what went wrong and try me again.  If you found a bug in the installer, please report it."
			return 1
		else
			die_error "Filesystem processing and rollback failed.  Please try the installer again.  If you found a bug in the installer, please report it."
		fi
	else
		notify "Auto-prepare was successful"
		return 0
	fi
}

listblockfriendly()
{
	BLOCKFRIENDLY=()
	for i in $(finddisks)
	do
		get_blockdevice_size $i MiB
		size_GiB=$(($BLOCKDEVICE_SIZE/2**10))
		BLOCKFRIENDLY+=($i "$i ${BLOCKDEVICE_SIZE} MiB ($size_GiB GiB)")
	done
}

finddisks() 
{
	shopt -s nullglob

	# Block Devices
	for dev in /sys/block/*; do
		# devices without a size are no good
		[[ -e $dev/size ]] || continue

		# size <= 0 is stuff like empty card reader
		read -r size < "$dev/size"
		(( size )) || continue

		# type 5 is a CDROM
		if [[ -e $dev/device/type ]]; then
			read -r type < "$dev/device/type"
			(( type == 5 )) && continue
		fi


		unset DEVTYPE
		. "$dev/uevent"
		dev_used_by_environment /dev/$DEVNAME && continue
		[[ $DEVTYPE = disk || $DEVTYPE = vbd ]] && echo -ne "/dev/$DEVNAME $1"
	done

	# cciss controllers
	for dev in /dev/cciss/*; do
		if [[ $dev != *[[:digit:]]p[[:digit:]]* ]]; then
			dev_used_by_environment $dev && continue
			echo "$dev $1"
		fi
	done

	# Smart 2 Controller
	for dev in /dev/ida/*; do
		if [[ $dev != *[[:digit:]]p[[:digit:]]* ]]; then
			dev_used_by_environment $dev && continue
			echo "$dev $1"
		fi
	done

	shopt -u nullglob
}

dev_used_by_environment () 
{
	local dev=$1
	grep -q "^$dev$" /run/aif/ignore_block_devices 2>/dev/null
}

get_blockdevice_size ()
{
	[ -b "$1" ] || die_error "get_blockdevice_size needs a blockdevice as \$1 ($1 given)"
	unit=${2:-B}
	allowed_units=(B KiB kB MiB MB GiB GB)
	if ! check_is_in $unit "${allowed_units[@]}"
	then
		die_error "Unrecognized unit $unit!"
	fi

	# NOTES about older, deprecated methods:
	# - BLOCKDEVICE_SIZE=$(hdparm -I $1 | grep -F '1000*1000' | sed "s/^.*:[ \t]*\([0-9]*\) MBytes.*$/\1/") # if you do this on a partition, you get the size of the entire disk ! + hdparm only supports sata and ide. not scsi.
	# - unreliable method: on some interwebs they say 1 block = 512B, on other internets they say 1 block = 1kiB.  1kiB seemed to work for me.
	# blocks=`fdisk -s $1` || show_warning "Fdisk problem" "Something failed when trying to do fdisk -s $1"
	# BLOCKDEVICE_SIZE=$(($blocks/1024))

	bytes=$((`fdisk -l $1 2>/dev/null | sed -n '2p' | cut -d' ' -f5`))
	[[ $bytes = *[^0-9]* ]] && die_error "Could not parse fdisk -l output for $1"
	[ $unit = B   ] && BLOCKDEVICE_SIZE=$bytes
	[ $unit = KiB ] && BLOCKDEVICE_SIZE=$((bytes/2**10)) # /1024
	[ $unit = kB  ] && BLOCKDEVICE_SIZE=$((bytes/10**3)) # /1000
	[ $unit = MiB ] && BLOCKDEVICE_SIZE=$((bytes/2**20)) # ...
	[ $unit = MB  ] && BLOCKDEVICE_SIZE=$((bytes/10**6))
	[ $unit = GiB ] && BLOCKDEVICE_SIZE=$((bytes/2**30))
	[ $unit = GB  ] && BLOCKDEVICE_SIZE=$((bytes/10**9))
	true
}

interactive_partition() {
	target_umountall

	question_text="Select the disk you want to partition"
	if [ -f "$TMP_PARTITIONS" ]
	then
		if _dia_ask_yesno "I've detected you already have partition definitions in place:\n`cat $TMP_PARTITIONS`\nDo you want apply these now?  Pick 'no' when in doubt to start from scratch" no
		then
			process_disks || die_error "Something went wrong while partitioning"
			question_text="If you want to do further changes, you can (re)partition disks here"
		fi
	fi

	# Select disk to partition
	listblockfriendly
	DISCS=("${BLOCKFRIENDLY[@]}" OTHER OTHER DONE DONE)
	DISC=
	while true; do
		# Prompt the user with a list of known disks
		_dia_ask_option no 'Disc selection' "$question_text (select DONE when finished)" required "${DISCS[@]}" || return 1
		DISC=$ANSWER_OPTION
		if [ "$DISC" = "OTHER" ]; then
			_dia_ask_string "Enter the full path to the device you wish to partition" "/dev/sda" || return 1
			DISC=$ANSWER_STRING
		fi
		# Leave our loop if the user is done partitioning
		[ "$DISC" = "DONE" ] && break
		# Partition disc
		_dia_notify "Now you'll be put into the cfdisk program where you can partition your hard drive. You should make a swap partition and as many data partitions as you will need.\
		NOTE: cfdisk may tell you to reboot after creating partitions.  If you need to reboot, just re-enter this install program, skip this step and go on to the mountpoints selection step."
		cfdisk $DISC
	done
	return 0
}
