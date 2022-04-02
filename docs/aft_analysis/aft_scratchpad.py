# pip install -U spacy
# python -m spacy download en_core_web_sm
import spacy
import pytextrank
import pandas as pd
nlp = spacy.load("en_core_web_sm")
nlp.add_pipe('textrank')

# Get df from R environment
df = r["aft"]

doc = nlp(df.text[0])
docs = list(nlp.pipe(df.text))

list(doc._.phrases)

[(i, i.label_, i.vector_norm) for i in doc.sents]

# Concatenate multiple texts

# s = ""
# for item in df.text[0:22]:
#     s += item
# 
# doc2 = nlp(s)

# List of token attributes: https://spacy.io/api/token#attributes

def extract_tokens(doc:spacy.tokens.doc.Doc):
    """Extract tokens and metadata from individual spaCy doc."""
    return [
        (i.text, i.i, i.lemma_, i.ent_type_, i.ent_iob_, i.tag_, 
         i.dep_, i.pos_, i.is_stop, i.is_alpha, 
         i.is_digit, i.is_punct, i.is_sent_end) for i in doc
    ]

# x = extract_tokens(doc)

def tidy_tokens(docs):
    """Extract tokens and metadata from list of spaCy docs."""
    
    # Any token attributes added above need to be named here
    cols = [
        "doc_id", "token", "token_order", "lemma", 
        "ent_type", "ent_iob", "tag", "dep", "pos", "is_stop", 
        "is_alpha", "is_digit", "is_punct", "is_sent_end"
    ]
    
    meta_df = []
    for ix, doc in enumerate(docs):
        meta = extract_tokens(doc)
        meta = pd.DataFrame(meta)
        meta.columns = cols[1:]
        meta = meta.assign(doc_id = ix).loc[:, cols]
        meta_df.append(meta)
        
    return pd.concat(meta_df)   

# x = tidy_tokens(docs)

def extract_phrases(doc):
    """Extract pytextrank phrases from individual spaCy doc."""
    return [(p.rank, p.count, p.text) for p in doc._.phrases]


def tidy_phrases(docs):
    """Extract tokens and metadata from list of spaCy docs."""
    
    # Any token attributes added above need to be named here
    cols = [
        "doc_id", "rank", "count", "phrase"
    ]
    
    meta_df = []
    for ix, doc in enumerate(docs):
        meta = extract_phrases(doc)
        meta = pd.DataFrame(meta)
        meta.columns = cols[1:]
        meta = meta.assign(doc_id = ix).loc[:, cols]
        meta_df.append(meta)
        
    return pd.concat(meta_df)  


tr = doc._.textrank

for sent in tr.summary(limit_phrases=15, limit_sentences=5):
    print(sent)

