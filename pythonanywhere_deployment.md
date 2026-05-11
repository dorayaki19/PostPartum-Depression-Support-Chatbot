# 🚀 Deploying PPD Diary to PythonAnywhere

This project has been optimized for a smooth deployment on PythonAnywhere. Follow these steps to get your compassionate diary online.

## 1. Upload your code
- Create a new project folder on PythonAnywhere (e.g., `/home/yourusername/ppd-diary`).
- Upload the contents of this repository to that folder.
- **Project Root should look like this:**
  - `app.py`
  - `models_lib.py`
  - `requirements.txt`
  - `data/` (folder)
  - `templates/` (folder)

## 2. Set up a Virtual Environment
Open a **Bash Console** on PythonAnywhere and run:
```bash
mkvirtualenv ppd-env --python=/usr/bin/python3.10
pip install -r requirements.txt
```

## 3. Configure the Web App
1. Go to the **Web** tab in your PythonAnywhere dashboard.
2. Click **Add a new web app**.
3. Select **Manual Configuration** (since we are using a virtualenv).
4. Choose **Python 3.10** (or whichever version you used for the virtualenv).
5. **Virtualenv Section**: Enter the path to your env: `/home/yourusername/.virtualenvs/ppd-env`.
6. **Code Section**:
   - **Source code**: `/home/yourusername/ppd-diary`
   - **Working directory**: `/home/yourusername/ppd-diary`

## 4. Update the WSGI Configuration
In the **Web** tab, click the link to your **WSGI configuration file**. Replace its entire content with this:

```python
import sys
import os

# Add your project directory to the sys.path
path = '/home/yourusername/ppd-diary'
if path not in sys.path:
    sys.path.append(path)

os.chdir(path)

from app import app as application
```
*(Replace `yourusername` with your actual PythonAnywhere username!)*

## 5. Reload & Launch
- Go back to the **Web** tab and click **Reload yourusername.pythonanywhere.com**.
- Your diary is now live! 🌸

---

### 💡 Pro-Tip: Data Persistence
Currently, entries are stored in-memory (`_entries = {}`). On PythonAnywhere, the server restarts occasionally, which will clear the diary. To keep entries permanently, we recommend switching the `store.py` logic to use a SQLite database or a JSON file in the future.
