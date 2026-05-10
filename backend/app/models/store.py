_entries = {}

def save_entry(date, text, analysis):
    _entries[date] = {
        "date": date,
        "text": text,
        "analysis": analysis
    }
    return _entries[date]

def get_all():
    return list(_entries.values())
