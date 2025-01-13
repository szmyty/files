from langchain.document_loaders import UnstructuredPDFLoader
import fitz  # PyMuPDF for metadata fallback

def get_pdf_title(pdf_path):
    """
    Attempts to extract the title of a PDF using multiple methods:
    1. PDF metadata
    2. Heading from the first page
    3. Fallback to filename

    Args:
        pdf_path (str): Path to the PDF file.
    
    Returns:
        str: The extracted or fallback title.
    """
    try:
        # Method 1: Check metadata using PyMuPDF
        doc = fitz.open(pdf_path)
        metadata_title = doc.metadata.get("title")
        if metadata_title and metadata_title.strip():
            return metadata_title.strip()
        
        # Method 2: Extract first page heading using UnstructuredPDFLoader
        loader = UnstructuredPDFLoader(pdf_path)
        documents = loader.load()
        if documents and documents[0].page_content.strip():
            # Assume the first non-empty line is the title
            first_page_content = documents[0].page_content
            first_line = first_page_content.split("\n")[0].strip()
            if first_line:
                return first_line
        
        # Method 3: Fallback to the filename
        return pdf_path.split("/")[-1].replace(".pdf", "").replace("_", " ").strip()
    
    except Exception as e:
        print(f"Error extracting title: {e}")
        return "Untitled"