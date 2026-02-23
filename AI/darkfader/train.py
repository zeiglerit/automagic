from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from sentence_transformers import SentenceTransformer
import faiss
import json

# Load LLM and embedding model
llm = AutoModelForCausalLM.from_pretrained("mistralai/Mistral-7B-Instruct-v0.1")
tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.1")
embedder = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

# Load OSINT corpus (e.g., JSONL of dark web reports)
with open("osint_corpus.jsonl") as f:
    corpus = [json.loads(line)["text"] for line in f]

# Embed and index corpus
corpus_embeddings = embedder.encode(corpus, convert_to_tensor=False)
index = faiss.IndexFlatL2(len(corpus_embeddings[0]))
index.add(corpus_embeddings)

# RAG-style retrieval
def retrieve_context(query, top_k=3):
    query_embedding = embedder.encode([query])
    _, indices = index.search(query_embedding, top_k)
    return [corpus[i] for i in indices[0]]

# Prompt the LLM
def generate_response(query):
    context = retrieve_context(query)
    prompt = f"""You are an OSINT expert analyzing dark web activity for law enforcement.
Context:
{chr(10).join(context)}

Question:
{query}

Answer:"""
    inputs = tokenizer(prompt, return_tensors="pt")
    outputs = llm.generate(**inputs, max_new_tokens=300)
    return tokenizer.decode(outputs[0], skip_special_tokens=True)

# Example usage
query = "What darknet forums are discussing ransomware targeting hospitals?"
response = generate_response(query)
print(response)
