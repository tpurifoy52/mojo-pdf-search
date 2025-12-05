from sys import argv
from python import Python
from collections import List
from math import sqrt, log

@fieldwise_init
struct Passage(Copyable, Movable):
    var text: String
    var page: Int
    var score: Float64
    
    fn __init__(out self, text: String, page: Int):
        self.text = text
        self.page = page
        self.score = 0.0

fn tokenize(text: String) -> List[String]:
    var tokens = List[String]()
    var current_token = String("")
    
    for i in range(len(text)):
        var char = text[i]
        if char == ' ' or char == '\n' or char == '\t' or char == '.' or char == ',' or char == '!' or char == '?':
            if len(current_token) > 0:
                tokens.append(current_token.lower())
                current_token = String("")
        else:
            current_token += char
    
    if len(current_token) > 0:
        tokens.append(current_token.lower())
    
    return tokens^

fn calculate_tf(term: String, tokens: List[String]) -> Float64:
    var count: Float64 = 0.0
    
    for i in range(len(tokens)):
        if tokens[i] == term:
            count += 1.0
    
    if count == 0.0:
        return 0.0
    
    return 1.0 + log(count)

fn calculate_idf(term: String, all_passages: List[Passage]) -> Float64:
    var doc_count: Float64 = 0.0
    
    for i in range(len(all_passages)):
        var passage_tokens = tokenize(all_passages[i].text)
        var found = False
        
        for j in range(len(passage_tokens)):
            if passage_tokens[j] == term:
                found = True
                break
        
        if found:
            doc_count += 1.0
    
    if doc_count == 0.0:
        return 0.0
    
    return log((Float64(len(all_passages)) + 1.0) / (doc_count + 1.0)) + 1.0

fn search(mut passages: List[Passage], query: String, top_n: Int) -> List[Passage]:
    var query_terms = tokenize(query)
    
    for i in range(len(passages)):
        var score: Float64 = 0.0
        var passage_tokens = tokenize(passages[i].text)
        
        for j in range(len(query_terms)):
            var term = query_terms[j]
            var tf = calculate_tf(term, passage_tokens)
            var idf = calculate_idf(term, passages)
            score += tf * idf
        
        var doc_length = Float64(len(passage_tokens))
        if doc_length > 0.0:
            score = score / sqrt(doc_length)
        
        passages[i].score = score
    
    for i in range(len(passages)):
        for j in range(len(passages) - i - 1):
            if passages[j].score < passages[j + 1].score:
                var temp = passages[j].copy()
                passages[j] = passages[j + 1].copy()
                passages[j + 1] = temp^
    
    var results = List[Passage]()
    var limit = top_n if top_n < len(passages) else len(passages)
    
    for i in range(limit):
        if passages[i].score > 0.0:
            results.append(passages[i].copy())
    
    return results^

fn main() raises:
    if len(argv()) != 4:
        print("Usage: pdfsearch <pdf_file> <query> <num_results>")
        return
    
    var pdf_file = argv()[1]
    var query = argv()[2]
    var num_results: Int
    
    try:
        num_results = atol(argv()[3])
    except:
        print("Error: num_results must be an integer")
        return
    
    var py = Python.import_module("builtins")
    var json_module = Python.import_module("json")
    var subprocess = Python.import_module("subprocess")
    
    var result = subprocess.run(
        ["python3", "src/pdf_extractor.py", pdf_file],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        print("Error extracting PDF text")
        print(String(result.stderr))
        return
    
    var passages_data = json_module.loads(String(result.stdout))
    
    var passages = List[Passage]()
    
    for i in range(len(passages_data)):
        var passage_dict = passages_data[i]
        var text = String(passage_dict["text"])
        var page_num = Int(passage_dict["page"])
        passages.append(Passage(text, page_num))
    
    var results = search(passages, query, num_results)
    
    print('Results for: "' + query + '"\n')
    
    if len(results) == 0:
        print("No results found.")
        return
    
    for i in range(len(results)):
        var passage = results[i].copy()
        var rank = i + 1
        
        print("[" + String(rank) + "] Score: " + String(passage.score)[:4] + 
              " (page " + String(passage.page) + ")")
        
        var display_text = passage.text
        if len(display_text) > 200:
            display_text = display_text[:200] + "..."
        
        print('    "' + display_text + '"\n')
