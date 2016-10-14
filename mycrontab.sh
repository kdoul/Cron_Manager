#!/bin/bash
touch .tempCrontab
file="./.tempCrontab"
crontab -l | grep -v '^#' | grep -v '^$' > $file
echo "This is a crontab management script."
while true ; do
echo "Please select one of the available options:"
echo "1. Display crontab jobs"
echo "2. Insert a job"
echo "3. Remove a job"
echo "4. Remove all jobs"
echo "0. Exit"
read selection
	case $selection in 
	1)
	if grep ".*" $file >> /dev/null ; then
	index=0
	cat $file | while read -r line ; do
		read -ra linearray <<< "$line"
		if [ "${linearray[0]}" = "*" ]
		then
			minuteStatement="every minute"
		else
			minuteStatement="${linearray[0]} minute(s)"
		fi
		if [ "${linearray[1]}" = "*" ]
		then
			hourStatement="every hour"
		else
			hourStatement="${linearray[1]} hour(s)"
		fi
		if [ "${linearray[2]}" = "*" ]
		then
			dayStatement="every day"
		else
			dayStatement="day ${linearray[2]}"
		fi
		if [ "${linearray[3]}" = "*" ]
		then
			monthStatement="every month"
		else
			monthStatement="month ${linearray[3]}"
		fi
		if [ "${linearray[4]}" = "*" ]
		then
			weekStatement="any day of the week"
		else
			case ${linearray[4]} in
			"0"|"7")
			weekStatement="Sunday"
			;;
			"1")
			weekStatement="Monday"
			;;
			"2")
			weekStatement="Tuesday"
			;;
			"3")
			weekStatement="Wednesday"
			;;
			"4")
			weekStatement="Thursday"
			;;
			"5")
			weekStatement="Friday"
			;;
			"6")
			weekStatement="Saturday"
			;;
			esac
		fi
		index=$((index+1))
		echo -e "$index. The command: ${linearray[5]} will run on $hourStatement and $minuteStatement \nof $dayStatement and $monthStatement on $weekStatement."
	done
	else 
	echo "The crontab file is empty."
	fi
	echo "Press Enter to continue..."
	read
	;;
	2)
	echo "Enter the command:"
	read command
	while [ -z "$command" ] ; do
		echo "Did not recieve input. Please enter a command:"
		read command
		done
	if grep " $command"$ $file >> /dev/null
	then
	echo "The command $command already exists in the crontab file, delete it first."
	else
	echo "Enter the minute(s) of the time to run (0-59) or * for any minute (Enter for 0)"
	read minutes
	if [ -z "$minutes" ] ; then
		minutes=0
	elif [ "$minutes" != "*" ] ; then	
		while (( minutes > 59 || minutes < 0 )) ; do
			echo "Wrong input, please try again"
			echo "Enter the minute(s) of the time to run (0-59) or * for any minute (Enter for 0)"
			read minutes
			done
	fi
	echo "Enter the hour(s) of the time to run (0-23) or * for any hour (Enter for 0)"
	read hours
	if [ -z "$hours" ] ; then
		hours=0
	elif [ "$hours" != "*" ] ; then	
		while (( hours > 23 || hours < 0 )) ; do
			echo "Wrong input, please try again"	
			echo "Enter the hour(s) of the time to run (0-23) or * for any hour (Enter for 0)"
			read hours
			done
	fi
	echo "Enter the day of the month (1-31) or * for any day (Enter for 1)"
	read day
	if [ -z "$day" ] ; then
		day=1
	elif [ "$day" != "*" ] ; then	
		while (( day > 31 || day < 1 )) ; do
			echo "Wrong input, please try again"
			echo "Enter the day of the month (1-31) or * for any day (Enter for 1)"
			read day
			done
	fi
	echo "Enter the month (1-12) or * for any month (Enter for 1)"
	read month
	if [ -z "$month" ] ; then
		month=1
	elif [ "$month" != "*" ] ; then	
		while (( month > 12 || month < 1 )) ; do
			echo "Wrong input, please try again"
			echo "Enter the month (1-12) or * for any month (Enter for 1)"
			read month
			done
	fi
	while true ; do
		echo "Enter the day of the week (Monday, Tuesday, etc) or * for any day"
		read weekdayStr
		case $weekdayStr in
		"Monday"|"monday")
		weekday=1
		break
		;;
		"Tuesday"|"tuesday")
		weekday=2
		break
		;;
		"Wednesday"|"wednesday")
		weekday=3
		break
		;;
		"Thursday"|"Thursday")
		weekday=4
		break
		;;
		"Friday"|"friday")
		weekday=5
		break
		;;
		"Saturday"|"saturday")
		weekday=6
		break
		;;
		"Sunday"|"sunday")
		weekday=7
		break
		;;
		"Anyday"|"anyday"|"everyday"|"Everyday"|"*")
		weekday=*
		break
		;;
		*)
		echo "Wrong input, please try again."
		;;
		esac
	done
	echo "$minutes $hours $day $month $weekday $command" >> $file
	if crontab -i $file
	then
	echo "Installed new crontab file successfuly."
	else
	echo "Something went wrong, changes were lost."
	fi
	fi
	;;
	3)
	echo "Give me the name of the command you want to remove:"
	read command
	if grep " $command"$ $file >> /dev/null
	then
		sed -i "/$command/d" $file 
		echo "Command deleted successfuly"
			if crontab -i $file
			then
				echo "Installed new crontab file successfuly."
			else
				echo "Something went wrong, changes were lost."
			fi
	else
	echo "There is no such command in the crontab file"
	fi
	;;
	4)
	if crontab -r ; then
	echo "Crontab file deleted successfuly."
	crontab -l | grep -v '^#' | grep -v '^$' > $file
	else
	echo "Something went wrong, no changes were made"
	fi
	;;
	0)
	rm .tempCrontab
	echo "Exiting..."
	break
	;;
	*)
	echo "Wrong Selection"
	;;
	esac
done