#! /bin/bash


FILE=tasks.csv


RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"


function print_header {
    echo -e "${WHITE}==============================="
    echo -e "        📋 TO-DO LIST              "
    echo -e "===============================${RESET}"
}


function add {
    local priority="L"
    local title=""

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -t | --title)
                shift
                if [[ -z "$1" ]]; then
                    echo -e "${WHITE}----------------------------------------------${RESET}"
                    echo -e "${RED}❌ Error: Option -t|--title Needs a Parameter${RESET}"
                    echo -e "${WHITE}----------------------------------------------${RESET}"
                    exit 1
                fi
                title="$1"
            ;;
            -p | --priority)
                shift
                if [[ "$1" != "L" && "$1" != "M" && "$1" != "H" ]]; then
                    echo -e "${WHITE}-----------------------------------------------------${RESET}"
                    echo -e "${RED}❌Error: Option -p|--priority Only Accept L|M|H${RESET}"
                    echo -e "${WHITE}-----------------------------------------------------${RESET}"
                    exit 1
                fi
                priority="$1"
            ;;    
        esac
        shift
    done

    if [[ -z "$title" ]]; then
        echo -e "${WHITE}----------------------------------------------${RESET}"
        echo -e "${RED}❌Error: Task title is required.${RESET}"
        echo -e "${WHITE}----------------------------------------------${RESET}"
        exit 1
    fi
    
    echo "0,$priority,\"$title\"" >> "$FILE"
    echo -e "${GREEN}✅ Task added successfully!${RESET}"

}


function clear {
    : > "$FILE"
    echo -e "${WHITE}----------------------------------------${RESET}"
    echo -e "${YELLOW}⚠️ All tasks cleared.${RESET}"
    echo -e "${WHITE}----------------------------------------${RESET}"
}


function list {

    if [[ ! -f "$FILE" || ! -s "$FILE" ]]; then
        echo -e "${WHITE}-----------------------------------${RESET}"
        echo -e "${YELLOW}No tasks found.${RESET}"
        echo -e "${WHITE}-----------------------------------${RESET}"
        return
    fi

    print_header
    echo -e "${BOLD}ID | Status | Priority | Title${RESET}"
    echo "------------------------------------------------"

    awk -F"," ' NF >= 3 {
        status = ($1 == "1") ? "✅" : "❌"
        priorities = ($2 == "H") ? "🔴 H" : ($2 == "M") ? "🟡 M": "🟢 L" 
        printf "%2d | %s     | %s    | %s\n", NR, status, priorities, $3
        total++
        if ($1 == "1") done++
    } END {
        printf "\nTotal: %d     Done: %d    Todo: %d\n", total, done, total - done
    }' "$FILE"
}

function find_task {
    grep_term="$1"

    if [[ -z "$grep_term" ]]; then 
        echo -e "${WHITE}----------------------------------------${RESET}"
        echo -e "${RED}❌ Please provide a search term.${RESET}"
        echo -e "${WHITE}----------------------------------------${RESET}"
        return
    fi

    echo -e "${WHITE}------------------------------------------------------------------------------${RESET}"

    awk -F "," -v term="$grep_term" '
        NF >= 3 {
            status = ($1 == "1") ? "✅" : "❌"
            priority = ($2 == "H") ? "🔴 H" : ($2 == "M") ? "🟡 M" : "🟢 L"
            id = NR
            title = $3

            if (term == id || tolower(title) ~ tolower(term)) {
                printf "%2d | %s    | %s    | %s\n", id, status, priority, title
            }
        }
    ' "$FILE"

    echo -e "${WHITE}------------------------------------------------------------------------------${RESET}"
}



function mark_down {
    if [[ -z "$1" || ! "$1" =~ ^[0-9]+$ ]]; then
        echo -e "${WHITE}----------------------------------------------------${RESET}"
        echo -e "${RED}❌ Please provide a valid numeric task ID.${RESET}"
        echo -e "${WHITE}----------------------------------------------------${RESET}"
        return
    fi

    local task_id="$1"
    local total_tasks
    total_tasks=$(wc -l < "$FILE")

    if [[ "$task_id" -lt 1 || "$task_id" -gt "$total_tasks" ]]; then
        echo -e "${WHITE}----------------------------------------------------${RESET}"
        echo -e "${RED}❌ Task with ID $task_id not found.${RESET}"
        echo -e "${WHITE}----------------------------------------------------${RESET}"
        return        
    fi


    current_status=$(awk -F',' "NR==$task_id { print \$1 }" "$FILE")
    if [[ "$current_status" == "1" ]]; then
        echo -e "${WHITE}----------------------------------------------------${RESET}"
        echo -e "${YELLOW}⚠️ Task $task_id is already marked as done.${RESET}"
        echo -e "${WHITE}----------------------------------------------------${RESET}"
        return
    fi

    sed -i -e "${1}s/^0/1/" "$FILE"
    echo -e "${WHITE}----------------------------------------${RESET}"
    echo -e "${GREEN}✅ Task $1 marked as done.${RESET}"
    echo -e "${WHITE}----------------------------------------${RESET}"

}



function help {
    echo -e "${WHITE}--------------------------------------------------------------------------------------------${RESET}"
    echo -e "${BOLD}${BLUE}📘 TO-DO LIST HELP${RESET}"
    echo -e "${BOLD}Usage:${RESET} ./todo.sh <command> [options]"
    echo
    echo -e "${BOLD}${YELLOW}🛠️  Task Commands${RESET}"
    echo -e "  ${GREEN}add${RESET}         ➤ Add a new task"
    echo -e "  ${GREEN}list${RESET}        ➤ Show all tasks"
    echo -e "  ${GREEN}done <ID>${RESET}   ➤ Mark a task as done by its ID"
    echo -e "  ${GREEN}clear${RESET}       ➤ Remove all tasks"
    echo -e "  ${GREEN}find <text>${RESET} ➤ Search tasks by keyword"
    echo

    echo -e "${BOLD}${YELLOW}⚙️  Options (used with 'add')${RESET}"
    echo -e "  ${BLUE}-t, --title${RESET}      ➤ Set task title (required)"
    echo -e "  ${BLUE}-p, --priority${RESET}   ➤ Set priority: L (Low), M (Medium), H (High) [default: L]"
    echo

    echo -e "${BOLD}${YELLOW}💡 Examples:${RESET}"
    echo -e "  ${CYAN}./todo.sh add -t \"Buy milk\" -p H${RESET}"
    echo -e "  ${CYAN}./todo.sh done 2${RESET}"
    echo -e "  ${CYAN}./todo.sh list${RESET}"
    echo

    echo -e "${BOLD}${YELLOW}ℹ️  Tip:${RESET} Use ${CYAN}./todo.sh help${RESET} to view this guide anytime."
    echo -e "${WHITE}--------------------------------------------------------------------------------------------${RESET}"
}


case "$1" in
    "add") shift; add "$@";;
    "clear") clear;;
    "list") list;;
    "find") shift; find_task "$@";;
    "done") shift; mark_down "$@";;
    "help") help;;
    *)
        echo -e "${WHITE}------------------------------------------------------------${RESET}"
        echo -e "${YELLOW}Command Not Supported! Try './todo.sh help'${RESET}"
        echo -e "${WHITE}------------------------------------------------------------${RESET}";;
esac


