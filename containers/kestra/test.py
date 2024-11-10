"""test_kestra.py

Unit tests for the Kestra functionality.

This module contains a suite of unit tests to verify the behavior of the Kestra
application. It ensures that all critical functions perform as expected and helps
in maintaining code quality and reliability.

Attributes:
    None

Example:
    To run the tests, execute the script directly:

    ```bash
    python test_kestra.py
    ```
"""

import os
import time

# Paths to directories
INPUT_DIR = "input"
OUTPUT_DIR = "output"
PROCESSED_DIR = "processed"

# Test file content
TEST_FILENAME = "test_file.txt"
TEST_CONTENT = "This is a test file for Kestra processing."

# Create test file in the input directory
with open(os.path.join(INPUT_DIR, TEST_FILENAME), "w", encoding="utf-8") as f:
    f.write(TEST_CONTENT)

print(f"Test file '{TEST_FILENAME}' created in '{INPUT_DIR}'.")

# Wait for the file to be processed
print("Waiting for the file to be processed...")
TIME_ELAPSED = 0
PROCESSING_TIMEOUT = 60  # seconds

while TIME_ELAPSED < PROCESSING_TIMEOUT:
    time.sleep(5)
    TIME_ELAPSED += 5

    # Check if the file exists in the output directory
    if os.path.exists(os.path.join(OUTPUT_DIR, TEST_FILENAME)):
        print(f"Processed file '{TEST_FILENAME}' found in '{OUTPUT_DIR}'.")
        # Verify the content
        with open(os.path.join(OUTPUT_DIR, TEST_FILENAME), encoding="utf-8") as f:
            content = f.read()
            if content == TEST_CONTENT:
                print("File content verified. Processing successful!")
            else:
                print("File content does not match. Processing failed.")
        break
else:
    print("Processing timeout. File was not processed within the expected time.")

# Optionally, check that the file has been moved to the processed directory
if os.path.exists(os.path.join(PROCESSED_DIR, TEST_FILENAME)):
    print(f"Original file '{TEST_FILENAME}' moved to '{PROCESSED_DIR}'.")
else:
    print(f"Original file '{TEST_FILENAME}' not found in '{PROCESSED_DIR}'.")
