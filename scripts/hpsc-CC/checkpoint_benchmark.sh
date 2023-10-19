#!/bin/sh

# Check if the user has provided a program name
if [ $# -lt 1 ]; then
    echo "Usage: $0 <program_name>"
    exit 1
fi

program_name="$1"

get_pid() {

    matching_pids=$(ps aux | grep "$search_term" | grep -v "grep" | awk '{print $1}')
    # Count the number of matching lines (PIDs)
    count=$(echo "$matching_pids" | wc -l)
    # If there's more than one matching process, notify the user and exit
    if [ $count -gt 1 ]; then
        echo "Multiple processes match the criteria: "$search_term". Please make sure only 1 relevant process is running, or modify the criteria."
        exit 1
    fi

    echo "$matching_pids"
}

case "$program_name" in
    "loop")
        search_term="./simple_loop_counter.sh"
        ;;
    "pthread")
        search_term="./parallel_threads"
        ;;
    "coremark")
        search_term="./coremark.exe"
        ;;
    "coremark8")
        search_term="./coremark_8_threads.exe"
        ;;
    "microbench")
        search_term="./run_benchmarks"
        ;;
    "stream")
        search_term="./stream_c.exe"
        ;;
    "hpcc")
        search_term="./run_hpcc"
        ;;
    "perlin")
        search_term="./run_perlin.sh"
        ;;
    "hpec_challenge")
        search_term="./run_benchmarks.sh"
        ;;
    "hacc")
        search_term="./HACCKernels"
        ;;
    "spacebench")
        search_term="./run_benchmarks.sh"
        ;;
    *)
        echo "Invalid choice. Your input ${program_name} is not supported yet."
        exit 1
        ;;
esac

# Get the PID of the program
pid=$(get_pid)

# Check if the PID was found, meaning the program is running
if [ -n "$pid" ]; then
    printf "${BCyan}Checkpointing process with PID: $pid...${Color_Off}\n"

    mkdir -p "$program_name"
    echo "checkpoints are saved at: ${program_name}"
    # Run the CRIU dump command
    ../../criu/criu dump -vvvv -o dump.log -t "$pid" --shell-job --images-dir "$program_name"

    # Check the exit status of the last command
    if [ $? -eq 0 ]; then
        echo "Checkpointing success!"
    else
        echo "Checkpointing failed."
    fi
else
    echo "Program $program_name is not running. Exiting..."
fi
