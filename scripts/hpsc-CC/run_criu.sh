#!/bin/sh

printf "${BCyan}Welcome to CRIU! :)${Color_Off}\n"

# Ask the user for their choice
read -p "Do you want to checkpoint (c) or restore (r)? " choice

# Checkpoint functionality
if [ "$choice" == "c" ]; then

    # Prompt for PID
    read -p "Enter the PID: " pid

    # Prompt for directory
    read -p "Enter the directory to save the checkpoints: " dir
    mkdir -p "$dir"

    # Ask if the program should be left running or killed
    read -p "Do you want to leave the program running after checkpointing? (y/n): " leave_running

    if [ "$leave_running" == "y" ]; then
        leave_running_cmd="--leave-running"
    else
        leave_running_cmd=""
    fi

    # Run the CRIU dump command
    ../../criu/criu dump -vvvv -o dump.log -t "$pid" --shell-job --images-dir "$dir" $leave_running_cmd

    # Check the exit status of the last command
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "Checkpointing failed."
    fi

# Restore functionality
elif [ "$choice" == "r" ]; then
    
    # Prompt for directory
    read -p "Enter the directory of the checkpoint to restore: " dir

    # Run the CRIU restore command
    ../../criu/criu restore -vvvv -o restore.log --shell-job --images-dir "$dir"

    # Check the exit status of the last command
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "Restoring failed."
    fi

else
    echo "Invalid choice. Please choose 'c' or 'r'."
fi
