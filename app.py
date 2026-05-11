import os
import re
import sys
import joblib
import pandas as pd
from flask import Flask, request, jsonify, render_template
from sklearn.base import BaseEstimator, TransformerMixin

# ================= NLP COMPONENTS =================

from models_lib import CombinedExtractor

# ================= CONFIG & LOADING =================

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")

MODEL_PATH = os.path.join(DATA_DIR, "model.pkl")
EXT_PATH = os.path.join(DATA_DIR, "extractor.pkl")
ENC_PATH = os.path.join(DATA_DIR, "label_encoder.pkl")

# Load ML artifacts
try:
    model = joblib.load(MODEL_PATH)
    extractor = joblib.load(EXT_PATH)
    encoder = joblib.load(ENC_PATH)
except Exception as e:
    print(f"⚠️ Warning: Could not load ML models from {DATA_DIR}. Error: {e}")
    model, extractor, encoder = None, None, None

# ================= HELPERS =================

NEG_KW = ['overwhelmed','exhausted','worthless','hopeless','empty','numb','dark','cry','anxious','scared','fear','trapped','alone','lonely','burden','guilt','shame','failure','useless','broken','pain']
POS_KW = ['happy','joy','grateful','peaceful','content','hope','love','connected','supported','calm','strong','proud','better','good']
CRISIS_WORDS = ["kill myself", "want to die", "end my life", "hurt my baby", "harm my baby", "suicide"]

def clean_text(text):
    text = text.lower()
    text = re.sub(r"[^a-z\s']", " ", text)
    return re.sub(r"\s+", " ", text).strip()

def hand_features(text):
    words = text.split()
    wc = max(len(words), 1)
    neg = sum(1 for w in words if any(k in w for k in NEG_KW))
    pos = sum(1 for w in words if any(k in w for k in POS_KW))
    return {"neg_kw": neg, "pos_kw": pos, "help_kw": 0, "negations": 0, "intensifiers": 0, "first_person": 0, "word_count": wc, "sent_ratio": (pos - neg) / wc, "neg_pos_diff": neg - pos}

def detect_crisis(text):
    t = text.lower()
    return any(word in t for word in CRISIS_WORDS)

def predict(text):
    if detect_crisis(text):
        return {"severity": "Severe", "epds_score": 30, "alert": "CRISIS DETECTED"}
    
    if not model: return {"severity": "Analysis Unavailable", "epds_score": 0}

    c_text = clean_text(text)
    feats = hand_features(c_text)
    epds_score = max(0, min(30, int(feats["neg_kw"] * 2.5 - feats["pos_kw"] * 2)))
    
    row = pd.DataFrame([{"clean": c_text, "epds_score": epds_score, **feats}])
    X = extractor.transform(row)
    pred = model.predict(X)[0]
    label = encoder.inverse_transform([pred])[0]
    
    return {"severity": label, "epds_score": epds_score}

# ================= STORE =================

_entries = {}

# ================= WEB APP =================

app = Flask(__name__, template_folder="templates")

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/api/entries/", methods=["GET"])
def list_entries():
    return jsonify(list(_entries.values()))

@app.route("/api/entries/", methods=["POST"])
def create_entry():
    data = request.json
    date, text = data.get("date"), data.get("text")
    if not date or not text:
        return jsonify({"error": "Missing date or text"}), 400
    
    analysis = predict(text)
    entry = {"date": date, "text": text, "analysis": analysis}
    _entries[date] = entry
    return jsonify(entry)

if __name__ == "__main__":
    print("🌸 PPD Diary Backend is starting...")
    app.run(host="0.0.0.0", port=8000, debug=True)
