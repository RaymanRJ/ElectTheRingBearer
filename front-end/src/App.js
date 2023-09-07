import React, { useState, useEffect } from 'react';
import './App.css';


const App = () => {
  const [welcome, setWelcome] = useState(false); // Default to false
  const [candidates, setCandidates] = useState([]);
  const [inputValue, setInputValue] = useState("");
  const [bearer, setBearer] = useState("");

  // Check last visit time
  useEffect(() => {
    const lastVisit = localStorage.getItem('lastVisit');
    const now = new Date().getTime();
    
    if (!lastVisit || (now - lastVisit > 600000)) { // 10 minutes = 600,000 ms
      setWelcome(true);
      const timer = setTimeout(() => setWelcome(false), 3000);
      return () => clearTimeout(timer);
    }
    
    localStorage.setItem('lastVisit', now.toString());
  }, []);

  // Load and save candidate names
  useEffect(() => {
    const storedNames = localStorage.getItem('candidates');
    if (storedNames) {
      setCandidates(JSON.parse(storedNames));
    }
  }, []);

  useEffect(() => {
    localStorage.setItem('candidates', JSON.stringify(candidates));
  }, [candidates]);

  const addCandidate = () => {
    setCandidates([...candidates, inputValue]);
    setInputValue("");
  };

  const electBearer = () => {
    const randomIndex = Math.floor(Math.random() * candidates.length);
    setBearer(candidates[randomIndex]);
  };

  return (
    <div>
      {welcome && (
        <div onClick={() => setWelcome(false)}>
          Let The Ring Bearer Decide
        </div>
      )}
      {!welcome && (
        <>
          <input
            type="text"
            value={inputValue}
            onChange={e => setInputValue(e.target.value)}
          />
          <button onClick={addCandidate}>Add Candidate</button>
          <button onClick={electBearer}>Elect Bearer</button>
          <ul>
            {candidates.map((name, index) => <li key={index}>{name}</li>)}
          </ul>
          {bearer && <p>The Ring Bearer is: {bearer}</p>}
        </>
      )}
    </div>
  );
};

export default App;
