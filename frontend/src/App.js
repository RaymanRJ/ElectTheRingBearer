import React, { useState, useEffect } from 'react';
import './App.css';

  // Components
  const QuoteSection = () => (
    <div className="quote-section">
      <h1>"Let the Ring Bearer decide..."</h1>
      <p>- Gandalf</p>
      <small>- Philip</small>
    </div>
  );

  const BlurbSection = () => (
    <div className="blurb-section">
      <p>In the heart of Middle-Earth, when the path ahead is uncertain and the weight of choice heavy, even the mightiest heroes sometimes seek guidance. Here, in this hallowed enclave, the choice is given to the Ring Bearer. Enter the names of those brave enough to bear the weight of decision, and let the Ring choose its bearer. For in this moment, as in all great tales, fate is but a click away.</p>
    </div>
  );

  const Instructions = () => (
    <div className="instruction-section">
      <h2>How to Use:</h2>
      <ol>
        <li>Enter the names of potential ring-bearers.</li>
        <li>Once all names are entered, press "Elect Bearer" to make the choice.</li>
      </ol>
    </div>
  );
  
const App = () => {
  const timeoutDelay = 1000;
  const [welcome, setWelcome] = useState(false);
  const [candidates, setCandidates] = useState([]);
  const [inputValue, setInputValue] = useState("");
  const [bearer, setBearer] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [rotating, setRotating] = useState(false); 
  const [showPopup, setShowPopup] = useState(false);
  const [showBearerName, setShowBearerName] = useState(true);


  useEffect(() => {
    const lastVisit = localStorage.getItem('lastVisit');
    const now = new Date().getTime();
    
    if (!lastVisit || (now - lastVisit > 600000)) {
      setWelcome(true);
      const timer = setTimeout(() => setWelcome(false), timeoutDelay * 3);
      const hideWelcome = () => setWelcome(false);
      document.addEventListener('click', hideWelcome);
      return () => {
        clearTimeout(timer);
        document.removeEventListener('click', hideWelcome);
      };
    }
    
    localStorage.setItem('lastVisit', now.toString());
  }, []);

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
    if (inputValue.length >= 3) {
      setCandidates([...candidates, inputValue]);
      setInputValue("");
      setErrorMessage("");
    } else {
      setErrorMessage("Candidate name must be at least 3 characters long!");  // 2. Set error message
    }
  };

  const deleteCandidate = (indexToDelete) => {
    setCandidates(prevCandidates => 
      prevCandidates.filter((_, index) => index !== indexToDelete)
    );
  };

  const electBearer = () => {
    setRotating(true);
    setTimeout(() => {
      setRotating(false);  // Stop the animation
      setShowPopup(false);  // Hide the popup after a delay
      displayBearer();  // Display the popup after a delay
    }, timeoutDelay);
  };

  const displayBearer = () => {
    const randomIndex = Math.floor(Math.random() * candidates.length);
    setBearer(candidates[randomIndex]);
    setShowBearerName(true);
    setShowPopup(true)
    setTimeout(() => {
      setShowPopup(false);
    }, timeoutDelay);
  };

  return (
    <div>
      <QuoteSection />
      {!welcome && (
        <>
          <BlurbSection />
          <input
            type="text"
            value={inputValue}
            onChange={e => setInputValue(e.target.value)}
          />
          <button onClick={addCandidate}>Add Potential Ring Bearer</button>
          <button onClick={electBearer} disabled={candidates.length === 0}>Elect Bearer</button>
          {errorMessage && <p style={{ color: 'red' }}>{errorMessage}</p>}
          {candidates.length < 1 && (<Instructions/>)}
          <ul>
            {candidates.map((name, index) => (
              <li key={index} className={rotating ? "rotating" : ""}>
                {name} 
                <button onClick={() => deleteCandidate(index)} style={{ marginLeft: '10px' }}>x</button>
              </li>
            ))}
          </ul>
          {bearer && showBearerName && (
            <div 
              className="bearer-name" 
              onClick={() => setShowBearerName(false)}
            >
              {bearer} is the Ring Bearer!
            </div>
          )}
          {showPopup && (
            <div className="popup">
              <img src="IChooseYou.webp" alt="Ring Bearer" />
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default App;
