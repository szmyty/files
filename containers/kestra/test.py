import os
import time

# Paths to directories
input_dir = 'input'
output_dir = 'output'
processed_dir = 'processed'

# Test file content
test_filename = 'test_file.txt'
test_content = 'This is a test file for Kestra processing.'

# Create test file in the input directory
with open(os.path.join(input_dir, test_filename), 'w') as f:
    f.write(test_content)

print(f"Test file '{test_filename}' created in '{input_dir}'.")

# Wait for the file to be processed
print("Waiting for the file to be processed...")
time_elapsed = 0
processing_timeout = 60  # seconds

while time_elapsed < processing_timeout:
    time.sleep(5)
    time_elapsed += 5

    # Check if the file exists in the output directory
    if os.path.exists(os.path.join(output_dir, test_filename)):
        print(f"Processed file '{test_filename}' found in '{output_dir}'.")
        # Verify the content
        with open(os.path.join(output_dir, test_filename), 'r') as f:
            content = f.read()
            if content == test_content:
                print("File content verified. Processing successful!")
            else:
                print("File content does not match. Processing failed.")
        break
else:
    print("Processing timeout. File was not processed within the expected time.")

# Optionally, check that the file has been moved to the processed directory
if os.path.exists(os.path.join(processed_dir, test_filename)):
    print(f"Original file '{test_filename}' moved to '{processed_dir}'.")
else:
    print(f"Original file '{test_filename}' not found in '{processed_dir}'.")
