# 🌸 PPD Diary: Postpartum Support & Analysis

[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![React](https://img.shields.io/badge/Frontend-React-61DAFB?style=flat-square&logo=react&logoColor=black)](https://reactjs.org/)
[![Scikit-Learn](https://img.shields.io/badge/ML-Scikit--Learn-F7931E?style=flat-square&logo=scikit-learn&logoColor=white)](https://scikit-learn.org/)

**PPD Diary** is a compassionate digital companion designed to support mothers during the postpartum period. By combining simple journaling with advanced Machine Learning analysis, it helps track mental well-being and identifies early signs of postpartum depression (PPD).

---

## ✨ Key Features

- **✍️ Mindful Journaling**: A safe space to record thoughts, feelings, and daily experiences.
- **🧠 AI-Powered Analysis**: Uses a custom Stacking Classifier (RandomForest, SVM, Logistic Regression) to assess the emotional weight of entries.
- **📊 Severity Tracking**: Classifies entries into five levels: *Minimal, Mild, Moderate, High, and Severe*.
- **📈 EPDS Estimation**: Provides an estimated score based on the *Edinburgh Postnatal Depression Scale* through NLP keyword analysis.
- **history 📖 Timeline**: View your emotional journey over time with a persisted history of entries and their analysis.

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: React.js
- **State Management**: React Hooks (`useState`, `useEffect`)
- **API Client**: Axios
- **Styling**: Modern CSS with a focus on accessibility and calming aesthetics.

### Backend
- **Framework**: FastAPI (Python)
- **ML Engine**: Scikit-learn
- **Data Processing**: Pandas & NumPy
- **NLP**: Custom feature extraction pipeline (Keyword density, sentiment ratios, and statistical linguistic features).
- **Persistence**: File-based storage (extendable to SQLite/PostgreSQL).

---

## 🚀 Getting Started

### ⚡ Quick Start (Windows)
If you are on Windows and have already installed the dependencies, you can start both the backend and frontend with a single click:
1. Double-click the `run.bat` file in the root directory.
2. This will open two terminal windows and launch the full application.

---

### Prerequisites
- Python 3.9+
- Node.js & npm

### Backend Setup
1. Navigate to the backend folder:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Train the model (if first time):
   ```bash
   python train_model.py
   ```
4. Start the API server:
   ```bash
   uvicorn app.main:app --reload
   ```

### Frontend Setup
1. Navigate to the frontend folder:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the development server:
   ```bash
   npm start
   ```

---

## 📂 Project Structure

```text
PPD/
├── backend/
│   ├── app/                # FastAPI Application logic
│   │   ├── api/            # API Endpoints (Entries, Analysis)
│   │   ├── nlp/            # NLP Feature Extraction & Predictors
│   │   └── models/         # Data persistence & storage logic
│   ├── data/               # Datasets and trained model artifacts (.pkl)
│   └── train_model.py      # ML Training Pipeline
├── frontend/
│   ├── src/                # React components and styling
│   └── public/             # Static assets
└── run.bat                 # Windows startup script
```

---

## 🛡️ Disclaimer
*This tool is intended for informational and supportive purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.*

---
<p align="center">Made with ❤️ for mothers everywhere.</p>