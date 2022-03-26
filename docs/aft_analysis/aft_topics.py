import nltk; nltk.download('stopwords')

import re
import numpy as np
import pandas as pd
from pprint import pprint

# Gensim
import gensim
import gensim.corpora as corpora
from gensim.utils import simple_preprocess
from gensim.models import CoherenceModel

# spacy for lemmatization
import spacy

# Plotting tools
import pyLDAvis
import pyLDAvis.gensim  # don't skip this
import matplotlib.pyplot as plt
# %matplotlib inline

# Enable logging for gensim - optional
import logging
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.ERROR)

import warnings
warnings.filterwarnings("ignore",category=DeprecationWarning)

# https://www.machinelearningplus.com/nlp/topic-modeling-gensim-python/

# Get df from R environment
df = r["aft"]

text = [[text for text in doc.split()] for doc in df.text]
text = [(i) for i in doc]

dictionary = corpora.Dictionary(text)

x = corpora.csv_corpus()
