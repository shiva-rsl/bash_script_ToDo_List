#! /bin/bash


FILE=tasks.csv


function add {
    local priority="L"
    local title=""

    while [[ "$#" -gt 0 ]]; do
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

    if [[ -z "$title" ]]; then
        echo "Error: Task title is required."
        exit 1
    fi
    
    echo "0,$priority,\"$title\"" >> "$FILE"
}

function clear {
    echo "" > "$FILE"
}


function list {
    if [[ ! -f "$FILE" ]]; then
        echo "No tasks found."
        return
    fi
    awk -F"," '{
        status = ($1 == "1") ? "✅" : "❌"; 
        print NR " | " status " | " $2 " | " $3
  
    }' "$FILE"
}

function find_task {
    grep_term="$1"
    awk -F "," '{ print NR " | " $1 " | " $2 " | " $3 }' "$FILE" | grep -- "$grep_term"
}


function mark_down {
    sed -i -e "${1}s/^0/1/" "$FILE"

}

case "$1" in
    "add")
        shift
        add "$@";;
    "clear")
        clear;;
    "list")
        list;;
    "find_task")
        shift
        find_task "$@";;
    "done")
        shift
        mark_down "$@";;
    *)
        echo "Command Not Supported!";;  
esac


