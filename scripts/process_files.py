import logging
import atexit
from abc import ABC, abstractmethod


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
        """Registers a parser class for a specific file type."""
        ParserFactory._registry[file_type.lower()] = parser_class

    @staticmethod
    def determine_parser(file_path: str, file_metadata: dict) -> str:
        """Determines the file type based on file path and metadata."""
        if file_path.endswith(".pdf") or file_metadata.get("content_type") == "application/pdf":
            return "pdf"
        elif file_path.endswith(".docx") or file_metadata.get("content_type") == "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
            return "word"
        elif file_path.endswith(".txt") or file_metadata.get("content_type") == "text/plain":
            return "text"
        else:
            raise ValueError(f"Unable to determine file type for file: {file_path}")

    @staticmethod
    def get_parser(file_path: str, file_metadata: dict):
        """Retrieves the appropriate parser for the given file."""
        file_type = ParserFactory.determine_parser(file_path, file_metadata)
        parser_class = ParserFactory._registry.get(file_type)
        if not parser_class:
            raise ValueError(f"No parser found for file type: {file_type}")
        return parser_class()


def setup():
    """Sets up logging, cleanup hooks, and registers parsers."""
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[
            logging.StreamHandler(),  # Logs to console
        ],
    )

    # Register atexit cleanup
    def on_exit():
        logging.info("Application is shutting down. Performing clean-up tasks.")

    atexit.register(on_exit)

    # Register parsers
    ParserFactory.register_parser("pdf", PDFParser)
    ParserFactory.register_parser("word", WordParser)
    ParserFactory.register_parser("text", TextParser)


def process_document(file_path, file_metadata):
    """Processes a single document by determining its parser and extracting content."""
    try:
        parser = ParserFactory.get_parser(file_path, file_metadata)
        result = parser.parse(file_path)
        logging.info(f"Processing complete: {result}")
        return result
    except ValueError as e:
        logging.error(f"Error processing document: {e}")
        return None


def main():
    """Main entry point for the script."""
    # Example documents
    documents = [
        {"file_path": "example.pdf", "file_metadata": {"content_type": "application/pdf"}},
        {"file_path": "example.docx", "file_metadata": {"content_type": "application/vnd.openxmlformats-officedocument.wordprocessingml.document"}},
        {"file_path": "example.txt", "file_metadata": {"content_type": "text/plain"}},
        {"file_path": "unknown.xyz", "file_metadata": {"content_type": "unknown"}},
    ]

    results = []
    for doc in documents:
        result = process_document(doc["file_path"], doc["file_metadata"])
        if result:
            results.append(result)

    logging.info(f"All document processing results: {results}")


if __name__ == "__main__":
    try:
        setup()  # Initialize the system
        main()   # Execute business logic
    except Exception as e:
        logging.critical(f"Unhandled exception occurred: {e}", exc_info=True)
