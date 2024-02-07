#!/bin/sh

# Prompt the user to select a program number
echo "Please select a program to checkpoint:"
echo "1 - loop"
echo "2 - pthread"
echo "3 - coremark"
echo "4 - coremark8"
echo "5 - microbench"
echo "6 - stream"
echo "7 - hpcc"
echo "8 - perlin"
echo "9 - hpec_challenge"
echo "10 - hacc"
echo "11 - spacebench"
read -p "Enter the number corresponding to the program: " program_number

case "$program_number" in
    1)
        program_name="loop"
        search_term="./simple_loop_counter.sh"
        ;;
    2)
        program_name="pthread"
        search_term="./parallel_threads"
        ;;
    3)
        program_name="coremark"
        search_term="./coremark"
        ;;
    4)
        program_name="coremark8"
        search_term="./coremark_8_threads"
        ;;
    5)
        program_name="microbench"
        search_term="./run_benchmarks"
        ;;
    6)
        program_name="stream"
        search_term="./stream_c"
        ;;
    7)
        program_name="hpcc"
        search_term="./run_hpc"
        ;;
    8)
        program_name="perlin"
        search_term="./run_perlin"
        ;;
    9)
        program_name="hpec_challenge"
        search_term="./run_hpec_challenge"
        ;;
    10)
        program_name="hacc"
        search_term="./HACCKernels"
        ;;
    11)
        program_name="spacebench"
        search_term="./run_spacebench"
        ;;
    *)
        echo "Invalid choice. Please select a valid program number."
        exit 1
        ;;
esac

# Prompt the user to make sure their benchmark app is running
echo "Please make sure your benchmark $search_term is running before continuing"
read -p "Press enter to continue..."

get_pid() {
    matching_pids=$(ps aux | grep "$search_term" | grep -v "grep" | awk '{print $2}')
    # Count the number of matching lines (PIDs)
    count=$(echo "$matching_pids" | wc -l)
    # If there's more than one matching process, notify the user and exit
    if [ $count -gt 1 ]; then
        echo "Multiple processes match the criteria: "$search_term". Please make sure only 1 relevant process is running, or modify the criteria."
        exit 1
    fi

    echo "$matching_pids"
}

# Get the PID of the program
pid=$(get_pid)

# Check if the PID was found, meaning the program is running
if [ -n "$pid" ]; then
    printf "${BCyan}Checkpointing process with PID: $pid...${Color_Off}\n"

    mkdir -p "$program_name"
    echo "checkpoints are saved at: ${program_name}"
    # Run the CRIU dump command
    ../../../criu/criu dump -vvvv -o dump.log -t "$pid" --shell-job --images-dir "$program_name"

    # Check the exit status of the last command
    if [ $? -eq 0 ]; then
        echo "Checkpointing success!"
    else
        echo "Checkpointing failed."
    fi
else
    echo "Program $program_name is not running. Exiting..."
fi
