import { useState, useEffect } from "react";
import axios from "axios";
import "./App.css";

function App() {

  const [date, setDate] = useState("");
  const [text, setText] = useState("");
  const [result, setResult] = useState(null);
  const [entries, setEntries] = useState([]);

  const API = "http://localhost:8000/api/entries/";

  const analyse = async () => {
    try {
      const res = await axios.post(API, {
        date: date || "2026-01-01",
        text: text
      });

      setResult(res.data.analysis);
      loadEntries();

    } catch (err) {
      console.error(err);
      alert("Error connecting to backend");
    }
  };

  const loadEntries = async () => {
    try {
      const res = await axios.get(API);
      setEntries(res.data);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    loadEntries();
  }, []);

  return (
    <div className="container">

      <h1>🌸 Postpartum Diary</h1>
      <p className="subtitle">
        Write how you feel today. Your notes are saved safely.
      </p>

      <div className="layout">

        {/* LEFT SIDE — Writing */}
        <div className="card">

          <h2>✍️ Write Entry</h2>

          <label>Date</label>
          <input
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
          />

          <label>Your Thoughts</label>
          <textarea
            rows={6}
            placeholder="Write your feelings here..."
            value={text}
            onChange={(e) => setText(e.target.value)}
          />

          <button onClick={analyse}>Save & Analyse</button>

          {result && (
            <div className="result">
              <h3>Severity: {result.severity}</h3>
              <p>EPDS Score: {result.epds_score}</p>
            </div>
          )}

        </div>


        {/* RIGHT SIDE — History */}
        <div className="historyPanel">

          <h2>📖 Your Diary</h2>

          {entries.length === 0 && (
            <p>No entries yet.</p>
          )}

          {entries.map((e, index) => (
            <div key={index} className="entry">
              <h4>{e.date}</h4>
              <p>{e.text}</p>
              <small>Severity: {e.analysis.severity}</small>
            </div>
          ))}

        </div>

      </div>

    </div>
  );
}

export default App;
