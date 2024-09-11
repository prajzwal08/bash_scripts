#!/bin/bash

# Check if a Python file argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <full_path_to_python_file>"
    exit 1
fi

# Define the full path of the Python file from the first argument
python_file=$1

# Extract the base name of the Python file (without extension) for log file naming
base_name=$(basename "$python_file" .py)

# Define the email address
email_address="p.khanal@utwente.nl"

# Define the location of the log file based on the Python file name
log_file="/home/khanalp/logs/${base_name}.log"

# Change working directory to the directory of the Python file
cd "$(dirname "$python_file")"

# Add timestamp indicating job start to log file
echo "Job started at $(date)" >> "$log_file"

# Send an email notification indicating that the job has started
echo "Job started at $(date)" | mail -s "Job started: ${base_name}" $email_address

# Execute the main script using nohup and redirect stdout and stderr to log file
nohup python3 "$python_file" >> "$log_file" 2>&1 &
pid=$!  # Get the process ID of the background job

# Wait for the job to finish and get its exit status
wait $pid
exit_status=$?

# Add timestamp indicating job end to log file
echo "Job ended at $(date)" >> "$log_file"

# Check the exit status and send email notification accordingly
if [ $exit_status -eq 0 ]; then
    mail -s "Job completed successfully: ${base_name}" $email_address < "$log_file"
else
    mail -s "Job failed or was interrupted: ${base_name}" $email_address < "$log_file"
fi
