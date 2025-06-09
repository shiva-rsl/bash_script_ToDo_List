#! /bin/bash


FILE=tasks.csv
title=""
priority=L


case "$1" in
    "add")
        shift
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -t | --title)
	           shift
	           if [[ -z "$1" ]]; then
	               echo  "Option -t|--title Needs a Parameter"
	               exit 1
	           fi
	           title="$1"
	           ;;
	       -p | --priority)
	           shift
	           if [[ "$1" != "L" && "$1" != "M" && "$1" != "H" ]]; then
	               echo "Option -p|--priority Only Accept L|M|H"
	               exit 1
	           fi
	           priority="$1"
	           ;;    
            esac
            shift
        done
        echo "$count,$priority,\"$title\"" >> $FILE
        ;;
    "clear")
        echo "" > $FILE
        ;;
    "list")
        awk -F"," '{ print NR" | "$1" | "$2" | "$3 }' $FILE
        ;;
    "find")
        awk -F "," '{ print NR" | "$1" | "$2" | "$3 }' $FILE | grep "$2"
        ;;
    "done")
        sed -i -e "$2""s/0/1/" $FILE
        shift
        ;;
    *)
        echo "Command Not Supported!"
        ;;  
esac


