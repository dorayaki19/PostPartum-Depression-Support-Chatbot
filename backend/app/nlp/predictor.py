import os
import re
import joblib
import pandas as pd

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")

MODEL_PATH = os.path.join(DATA_DIR, "model.pkl")
EXT_PATH = os.path.join(DATA_DIR, "extractor.pkl")
ENC_PATH = os.path.join(DATA_DIR, "label_encoder.pkl")

model = joblib.load(MODEL_PATH)
extractor = joblib.load(EXT_PATH)
encoder = joblib.load(ENC_PATH)


# ================= CLEAN =================

def clean_text(text):
    text = text.lower()
    text = re.sub(r"[^a-z\s']", " ", text)
    return re.sub(r"\s+", " ", text).strip()


# ================= HAND FEATURES =================

NEG_KW = ['overwhelmed','exhausted','worthless','hopeless','empty','numb',
          'dark','cry','anxious','scared','fear','trapped','alone','lonely',
          'burden','guilt','shame','failure','useless','broken','pain']

POS_KW = ['happy','joy','grateful','peaceful','content','hope','love',
          'connected','supported','calm','strong','proud','better','good']


def hand_features(text):

    words = text.split()
    wc = max(len(words), 1)

    neg = sum(1 for w in words if any(k in w for k in NEG_KW))
    pos = sum(1 for w in words if any(k in w for k in POS_KW))

    return {
        "neg_kw": neg,
        "pos_kw": pos,
        "help_kw": 0,
        "negations": 0,
        "intensifiers": 0,
        "first_person": 0,
        "word_count": wc,
        "sent_ratio": (pos - neg) / wc,
        "neg_pos_diff": neg - pos
    }


# ================= CRISIS DETECTION =================

CRISIS_WORDS = [
    "kill myself",
    "want to die",
    "end my life",
    "hurt my baby",
    "harm my baby",
    "suicide"
]


def detect_crisis(text):

    t = text.lower()

    for word in CRISIS_WORDS:
        if word in t:
            return True

    return False


# ================= PREDICT =================

def predict(text):

    # Crisis detection first
    if detect_crisis(text):
        return {
            "severity": "Severe",
            "epds_score": 30,
            "alert": "CRISIS DETECTED"
        }

    c_text = clean_text(text)

    feats = hand_features(c_text)

    # EPDS estimate
    epds_score = max(
    0,
    min(
        30,
        int(feats["neg_kw"] * 2.5 - feats["pos_kw"] * 2)
    )
    )

    row = pd.DataFrame([
        {
            "clean": c_text,
            "epds_score": epds_score,
            **feats
        }
    ])

    X = extractor.transform(row)

    pred = model.predict(X)[0]
    label = encoder.inverse_transform([pred])[0]

    return {
        "severity": label,
        "epds_score": epds_score
    }