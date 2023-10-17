#!/bin/sh

# Function that runs in an infinite loop printing "Task 1" with a counter
task1() {
    local counter=1
    while true; do
        echo "Task 1 - Count: $counter"
        counter=$((counter + 1))
        sleep 1
    done
}

# Function that runs in an infinite loop printing "Task 2" with a counter
task2() {
    local counter=1
    while true; do
        echo "Task 2 - Count: $counter"
        counter=$((counter + 1))
        sleep 1
    done
}

# Start the two tasks in parallel
task1 &
task2 &

# Wait indefinitely to keep the script running
wait
