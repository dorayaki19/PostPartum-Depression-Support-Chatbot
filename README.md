# 🌸 PPD Diary: Postpartum Support & Analysis

<p align="center">
  <img src="index.PNG" alt="PPD Diary Interface" width="800">
</p>

[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![React](https://img.shields.io/badge/Frontend-React-61DAFB?style=flat-square&logo=react&logoColor=black)](https://reactjs.org/)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Scikit-Learn](https://img.shields.io/badge/ML-Scikit--Learn-F7931E?style=flat-square&logo=scikit-learn&logoColor=white)](https://scikit-learn.org/)

**PPD Diary** is a compassionate digital companion designed to support mothers during the postpartum period. By combining simple journaling with advanced Machine Learning analysis, it helps track mental well-being and identifies early signs of postpartum depression (PPD).

---

## ⚡ Quick Start

### Mobile App (Flutter)
1. Ensure you have [Flutter](https://docs.flutter.dev/get-started/install) installed.
2. Run `flutter pub get` in the root directory.
3. Run `flutter run` to launch on your device or emulator.

### Web Ecosystem (FastAPI & React)
If you are on Windows, you can launch the entire ecosystem with a single command:
1. **Install Dependencies**: Run `pip install -r backend/requirements.txt` and `npm install` in `frontend`.
2. **Run the App**: Double-click [**run.bat**](file:///run.bat) in the root directory.

---

## 🧠 Deep Dive: ML Backend
The core of PPD Diary is its robust machine learning pipeline, designed to provide accurate emotional assessments.

### 1. Hybrid Feature Extraction
Instead of relying solely on text, our **`CombinedExtractor`** builds a high-dimensional feature space from:
- **TF-IDF Vectorization**: Analyzes word patterns using 1-3 ngrams (up to 5000 features).
- **Hand-Crafted NLP Features**: Tracks keyword density for positive/negative sentiments, word counts, and first-person perspective ratios.
- **EPDS Integration**: Factors in an estimated score based on the *Edinburgh Postnatal Depression Scale* logic.

### 2. The Stacking Classifier
To ensure maximum reliability, we use a **Stacking Classifier** that aggregates predictions from four diverse base models:
- **Random Forest & Gradient Boosting**: For capturing complex, non-linear emotional patterns.
- **SVM (Linear Kernel)**: For high-dimensional text separation.
- **Logistic Regression**: Used as the final meta-estimator to blend the base model outputs into a final severity classification.

### 3. Safety First: Crisis Detection
Beyond standard analysis, the backend implements a **Crisis Detection Layer**. It scans for high-risk phrases (self-harm, harm to infant, etc.) and immediately flags entries as **"Severe"** with a crisis alert, bypassing standard inference for immediate safety priority.

---

## ✨ Key Features
- **✍️ Mindful Journaling**: A safe space to record thoughts, feelings, and daily experiences.
- **📱 Mobile Companion**: Flutter-based diary app for on-the-go tracking.
- **📊 Severity Classification**: Five-level detection: *Minimal, Mild, Moderate, High, and Severe*.
- **📈 EPDS Estimation**: Real-time scoring based on statistical linguistic analysis.
- **📖 Emotional Timeline**: Track your progress over time with persisted entry history.

---

## 📂 Project Structure
```text
PPD/
├── lib/                    # Flutter App Source Code
├── backend/                # FastAPI Application logic
├── frontend/               # React UI Components
├── Assets/                 # Shared Assets
└── run.bat                 # One-click Windows startup
```

---

## 🛡️ Disclaimer
*This tool is intended for informational and supportive purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.*

---
<p align="center">Made with ❤️ for mothers everywhere.</p>
