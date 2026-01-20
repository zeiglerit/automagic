
#!/usr/bin/env python3

## python3 assist_rag.py "Summarize AI security threats" https://example.com/article.html 

import os, sys, requests
from transformers import pipeline, AutoTokenizer, AutoModelForSeq2SeqLM
from azure.core.credentials import AzureKeyCredential
from azure.search.documents import SearchClient
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.indexes.models import SearchIndex, SimpleField, SearchableField

# -------------------------------
# 1. Hugging Face model
# -------------------------------
model_name = "facebook/bart-large"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
generator = pipeline("text2text-generation", model=model, tokenizer=tokenizer)

# -------------------------------
# 2. Azure Cognitive Search setup
# -------------------------------
search_endpoint = os.environ["AZURE_SEARCH_ENDPOINT"]
search_key = os.environ["AZURE_SEARCH_KEY"]
index_name = "rag-index"

index_client = SearchIndexClient(search_endpoint, AzureKeyCredential(search_key))
search_client = SearchClient(search_endpoint, index_name, AzureKeyCredential(search_key))

# Create index if not exists
fields = [
    SearchableField(name="content", type="Edm.String", searchable=True),
    SimpleField(name="id", type="Edm.String", key=True)
]
try:
    index = SearchIndex(name=index_name, fields=fields)
    index_client.create_index(index)
except Exception:
    pass

# -------------------------------
# 3. Helper functions
# -------------------------------
def fetch_web(url):
    resp = requests.get(url, timeout=10)
    return resp.text[:5000]

def ingest_doc(doc_id, text):
    search_client.upload_documents([{"id": doc_id, "content": text}])

def retrieve_context(query):
    results = search_client.search(query, top=3)
    return "\n".join([doc["content"] for doc in results])

def run_prompt(prompt, context=""):
    input_text = f"{context}\n\nQuestion: {prompt}"
    output = generator(input_text, max_length=512, num_return_sequences=1)
    print(output[0]["generated_text"])

# -------------------------------
# 4. CLI entry
# -------------------------------
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python rag.py 'your question' [url_or_file]")
        sys.exit(1)

    prompt = sys.argv[1]
    context = ""

    if len(sys.argv) > 2:
        source = sys.argv[2]
        if source.startswith("http"):
            text = fetch_web(source)
            ingest_doc("webdoc", text)
            context = retrieve_context(prompt)
        else:
            with open(source, "r") as f:
                text = f.read()
            ingest_doc("filedoc", text)
            context = retrieve_context(prompt)

    run_prompt(prompt, context)
