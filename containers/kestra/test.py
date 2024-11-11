"""Unit tests for the Kestra functionality.

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

import time
from logging import getLogger
from pathlib import Path

logger = getLogger(__name__)

# Paths to directories
INPUT_DIR = "input"
OUTPUT_DIR = "output"
PROCESSED_DIR = "processed"

# Test file content
TEST_FILENAME = "test_file.txt"
TEST_CONTENT = "This is a test file for Kestra processing."

# Create test file in the input directory
test_file = Path(INPUT_DIR) / TEST_FILENAME
with test_file.open("w", encoding="utf-8") as f:
    f.write(TEST_CONTENT)

logger.info("Test file '%s' created in '%s'.", TEST_FILENAME, INPUT_DIR)

# Wait for the file to be processed
logger.info("Waiting for the file to be processed...")
TIME_ELAPSED = 0
PROCESSING_TIMEOUT = 60  # seconds

while TIME_ELAPSED < PROCESSING_TIMEOUT:
    time.sleep(5)
    TIME_ELAPSED += 5

    # Check if the file exists in the output directory
    output_file = Path(OUTPUT_DIR) / TEST_FILENAME
    if output_file.exists():
        logger.info("Processed file '%s' found in '%s'.", TEST_FILENAME, OUTPUT_DIR)
        # Verify the content
        with output_file.open("r", encoding="utf-8") as f:
            content = f.read()
            if content == TEST_CONTENT:
                logger.info("File content verified. Processing successful!")
            else:
                logger.info("File content does not match. Processing failed.")
        break
else:
    logger.info("Processing timeout. File was not processed within the expected time.")

# Optionally, check that the file has been moved to the processed directory
processed_file = Path(PROCESSED_DIR) / TEST_FILENAME
if processed_file.exists():
    logger.info("Original file '%s' moved to '%s'.", TEST_FILENAME, PROCESSED_DIR)
else:
    logger.info("Original file '%s' not found in '%s'.", TEST_FILENAME, PROCESSED_DIR)
