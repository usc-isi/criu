#!/bin/sh

# Check if the user has provided a program name and max checkpoints
if [ $# -lt 2 ]; then
    echo "Usage: $0 <program_name> <max_checkpoints>"
    exit 1
fi

program_name="$1"
max_checkpoints="$2"
counter=1

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

# Continuously check if the program is running and checkpoint if it is
while true; do
    # Get the PID of the program
    pid=$(get_pid)

    # Check if the PID was found, meaning the program is still running
    if [ -n "$pid" ]; then
        printf "${BCyan}Checkpointing process with PID: $pid...${Color_Off}\n"

        timestamp=$(date +%Y%m%d%H%M%S) # Current time in YYYYMMDDHHMMSS format
        checkpoint_dir="$program_name/checkpoint_$timestamp"
        mkdir -p "$checkpoint_dir"
        echo "checkpoints are saved at: ${checkpoint_dir}"
        # Run the CRIU dump command
        ../../criu/criu dump -vvvv -o dump.log -t "$pid" --shell-job --images-dir "$checkpoint_dir" --leave-running

        # Check the exit status of the last command
        if [ $? -eq 0 ]; then
            echo "Checkpointing success!"
        else
            echo "Checkpointing failed."
        fi

        counter=$((counter+1))
        if [ $counter -gt $max_checkpoints ]; then
            echo "Maximum number of checkpoints reached. Exiting..."
            break
        fi
        sleep 1 # Sleep for 1 second before attempting again
    else
        echo "Program $program_name is not running. Exiting..."
        break
    fi
done
