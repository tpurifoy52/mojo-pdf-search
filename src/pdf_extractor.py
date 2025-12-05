import sys
import json
import PyPDF2

def extract_text_from_pdf(pdf_path):
    """
    Extract text from PDF file and return as JSON with page numbers.
    Returns: List of dicts with 'page' and 'text' keys
    """
    try:
        with open(pdf_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            passages_data = []
            
            for page_num in range(len(pdf_reader.pages)):
                page = pdf_reader.pages[page_num]
                text = page.extract_text()
                
                # Split into passages (by paragraph/sentence groups)
                passages = split_into_passages(text)
                
                for passage in passages:
                    if passage.strip():
                        passages_data.append({
                            'page': page_num + 1,
                            'text': passage.strip()
                        })
            
            return passages_data
    except Exception as e:
        print(f"Error extracting PDF: {e}", file=sys.stderr)
        return []

def split_into_passages(text, min_words=3, max_words=100):
    """Split text into meaningful passages."""
    # Replace newlines with spaces and split by periods
    sentences = text.replace('\n', ' ').split('. ')
    passages = []
    current_passage = []
    current_word_count = 0
    
    for sentence in sentences:
        words = sentence.split()
        word_count = len(words)
        
        if current_word_count + word_count > max_words and current_passage:
            passages.append('. '.join(current_passage) + '.')
            current_passage = [sentence]
            current_word_count = word_count
        else:
            current_passage.append(sentence)
            current_word_count += word_count
            
            if current_word_count >= min_words:
                passages.append('. '.join(current_passage) + '.')
                current_passage = []
                current_word_count = 0
    
    if current_passage:
        passages.append('. '.join(current_passage) + '.')
    
    return passages

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python pdf_extractor.py <pdf_file>")
        sys.exit(1)
    
    pdf_path = sys.argv[1]
    passages_data = extract_text_from_pdf(pdf_path)
    print(json.dumps(passages_data))
