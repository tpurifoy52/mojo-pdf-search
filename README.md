# Mojo PDF Search Engine

A command-line tool that searches PDF documents for passages relevant to user queries using TF-IDF ranking implemented in pure Mojo.

## Features
- Pure Mojo implementation of TF-IDF search algorithm
- PDF text extraction using Python (PyPDF2)
- Returns top N most relevant passages with page numbers and relevance scores

## Requirements
- Mojo 0.25.6+
- Python 3.9+
- PyPDF2

## Installation

1. Clone the repository:
```bash
git clone https://github.com/tpurifoy5/mojo-pdf-search.git
cd mojo-pdf-search
```

2. Install dependencies:
```bash
pip3 install -r requirements.txt
```

3. Set Python library path (macOS):
```bash
export MOJO_PYTHON_LIBRARY="/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9/lib/libpython3.9.dylib"
```

## Usage
```bash
mojo run src/pdfsearch.mojo <pdf_file> <query> <num_results>
```

### Example
```bash
mojo run src/pdfsearch.mojo document.pdf "machine learning" 3
```

### Output
```
Results for: "machine learning"

[1] Score: 2.34 (page 5)
    "Machine learning algorithms improve automatically through experience..."

[2] Score: 1.87 (page 12)
    "Deep learning is a subset of machine learning based on neural networks..."

[3] Score: 1.45 (page 8)
    "Supervised machine learning uses labeled data to train models..."
```

## Implementation Details

### TF-IDF Scoring
- **Term Frequency (TF)**: Sublinear scaling using `1 + log(count)`
- **Inverse Document Frequency (IDF)**: `log((N + 1) / (df + 1)) + 1`
- **Length Normalization**: Scores divided by `sqrt(doc_length)`

This ensures:
1. Diminishing returns for repeated terms
2. Rare terms contribute more to relevance
3. Longer passages don't have unfair advantage

### Architecture
- **PDF Extraction**: Python (PyPDF2) extracts text and splits into passages
- **Search Engine**: Pure Mojo implementation of tokenization and TF-IDF
- **No External Libraries**: Core search uses only Mojo standard library

## Project Structure
```
mojo-pdf-search/
├── src/
│   ├── pdfsearch.mojo      # Main search engine (Mojo)
│   └── pdf_extractor.py    # PDF text extraction (Python)
├── requirements.txt
└── README.md
```

## Constraints Met
✅ No external search or information retrieval libraries  
✅ No machine learning or embedding models  
✅ Python libraries only for PDF text extraction  
✅ Pure Mojo implementation of search algorithm  

## License

MIT License
