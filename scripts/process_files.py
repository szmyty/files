import logging
import atexit
from abc import ABC, abstractmethod

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler(),  # Logs to console
    ],
)

# Global clean-up function
def on_exit():
    """Logs a message when the application is shutting down."""
    logging.info("Application is shutting down. Performing clean-up tasks.")

# Register the atexit hook
atexit.register(on_exit)

# Strategy Pattern: Abstract Parser
class DocumentParser(ABC):
    """Abstract base class for document parsers."""

    @abstractmethod
    def parse(self, document):
        """Parse the document and return extracted information."""
        pass

# Concrete Strategies: Specific Parsers
class PDFParser(DocumentParser):
    """Parser for PDF documents."""

    def parse(self, document):
        return {"type": "PDF", "content": f"Extracted content from PDF: {document}"}

class WordParser(DocumentParser):
    """Parser for Word documents."""

    def parse(self, document):
        return {"type": "Word", "content": f"Extracted content from Word document: {document}"}

class TextParser(DocumentParser):
    """Parser for Text files."""

    def parse(self, document):
        return {"type": "Text", "content": f"Extracted content from Text file: {document}"}

# Factory Method: Determines the parser type
class ParserFactory:
    """Factory for creating document parsers."""

    _registry = {}

    @staticmethod
    def register_parser(file_type: str, parser_class):
        """Registers a parser class for a specific file type.

        Args:
            file_type (str): The type of the file (e.g., 'pdf', 'word').
            parser_class: The class implementing the parser for this file type.
        """
        ParserFactory._registry[file_type.lower()] = parser_class

    @staticmethod
    def get_parser(file_type: str):
        """Retrieves the appropriate parser for the given file type.

        Args:
            file_type (str): The type of the file.

        Returns:
            DocumentParser: An instance of the appropriate parser class.

        Raises:
            ValueError: If no parser is found for the given file type.
        """
        parser_class = ParserFactory._registry.get(file_type.lower())
        if not parser_class:
            raise ValueError(f"No parser found for file type: {file_type}")
        return parser_class()

# Register Parsers
ParserFactory.register_parser("pdf", PDFParser)
ParserFactory.register_parser("word", WordParser)
ParserFactory.register_parser("text", TextParser)

# Core function to process documents
def process_document(doc):
    """Processes a single document by determining its parser and extracting content.

    Args:
        doc (dict): A dictionary containing 'type' and 'content' keys.

    Returns:
        dict: The result of parsing the document, or None if an error occurs.
    """
    try:
        parser = ParserFactory.get_parser(doc["type"])
        result = parser.parse(doc["content"])
        logging.info(f"Processing complete: {result}")
        return result
    except ValueError as e:
        logging.error(f"Error processing document: {e}")
        return None

# Main function
def main():
    """Main function to process a list of documents and log results."""
    documents = [
        {"type": "pdf", "content": "PDF document content"},
        {"type": "word", "content": "Word document content"},
        {"type": "text", "content": "Text file content"},
        {"type": "unknown", "content": "Unsupported document content"},
    ]

    results = []
    for doc in documents:
        result = process_document(doc)
        if result:
            results.append(result)

    logging.info(f"All document processing results: {results}")

# Wrapper to handle top-level exceptions
def main_wrapper():
    """Wrapper for the main function to handle unexpected exceptions."""
    try:
        main()
    except Exception as e:
        logging.critical(f"Unhandled exception occurred: {e}", exc_info=True)

if __name__ == "__main__":
    main_wrapper()
