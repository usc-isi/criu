#!/bin/sh

# Prompt the user to select a program number
echo "Please select a program to restore:"
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
        ;;
    2)
        program_name="pthread"
        ;;
    3)
        program_name="coremark"
        ;;
    4)
        program_name="coremark8"
        ;;
    5)
        program_name="microbench"
        ;;
    6)
        program_name="stream"
        ;;
    7)
        program_name="hpcc"
        ;;
    8)
        program_name="perlin"
        ;;
    9)
        program_name="hpec_challenge"
        ;;
    10)
        program_name="hacc"
        ;;
    11)
        program_name="spacebench"
        ;;
    *)
        echo "Invalid choice. Please select a valid program number."
        exit 1
        ;;
esac

# Prompt for directory
dir="$program_name"

# Run the CRIU restore command
../../../criu/criu restore -vvvv -o restore.log --shell-job --images-dir "$dir"

# Check the exit status of the last command
if [ $? -eq 0 ]; then
    echo "OK"
else
    echo "Restoring failed."
fi