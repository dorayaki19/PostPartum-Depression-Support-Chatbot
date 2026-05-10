import os
import re
import numpy as np
import pandas as pd
import joblib

from app.nlp.extractor import CombinedExtractor   # ONLY HERE

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier, StackingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, f1_score


# ================= PATHS =================

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")

CSV_PATH = os.path.join(DATA_DIR, "postpartum_diary_dataset.csv")

MODEL_PATH = os.path.join(DATA_DIR, "model.pkl")
EXT_PATH = os.path.join(DATA_DIR, "extractor.pkl")
ENC_PATH = os.path.join(DATA_DIR, "label_encoder.pkl")


SEVERITY_ORDER = ["Minimal","Mild","Moderate","High","Severe"]


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


# ================= FEATURE EXTRACTOR =================




# ================= TRAIN =================

def train():

    df = pd.read_csv(CSV_PATH)

    df["clean"] = df["text"].astype(str).apply(clean_text)

    feat_df = pd.DataFrame(df["clean"].apply(hand_features).tolist())

    df = pd.concat([df.reset_index(drop=True), feat_df], axis=1)

    le = LabelEncoder()
    le.fit(SEVERITY_ORDER)

    y = le.transform(df["severity"])


    # EPDS estimate from keywords
    df["epds_score"] = (
        df["neg_kw"] * 2 - df["pos_kw"]
    ).clip(0,30)


    # Split
    X_train, X_test, y_train, y_test = train_test_split(
        df, y, test_size=0.2, random_state=42
    )


    # Extractor
    ext = CombinedExtractor()
    ext.fit(X_train)

    Xtr = ext.transform(X_train)
    Xte = ext.transform(X_test)


    # Models
    base_models = [
        ("lr", LogisticRegression(max_iter=1000)),
        ("svm", SVC(kernel="linear", probability=True)),
        ("rf", RandomForestClassifier(n_estimators=200)),
        ("gb", GradientBoostingClassifier())
    ]

    stack = StackingClassifier(
        estimators=base_models,
        final_estimator=LogisticRegression(),
        cv=5
    )

    stack.fit(Xtr, y_train)

    yp = stack.predict(Xte)

    acc = accuracy_score(y_test, yp)
    f1 = f1_score(y_test, yp, average="weighted")

    print(f"Accuracy: {acc:.3f}")
    print(f"F1 Score: {f1:.3f}")


    # Save files
    os.makedirs(DATA_DIR, exist_ok=True)

    joblib.dump(stack, MODEL_PATH)
    joblib.dump(ext, EXT_PATH)
    joblib.dump(le, ENC_PATH)

    print("\nSaved:")
    print("model.pkl")
    print("extractor.pkl")
    print("label_encoder.pkl")


# ================= RUN =================

if __name__ == "__main__":
    train()