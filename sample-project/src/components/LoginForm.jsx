import React, { useState } from 'react';

// ❌ Missing input validation and error handling
// ❌ Inline styles should be in CSS modules
// ❌ No accessibility attributes
// ❌ Potential XSS vulnerability
const LoginForm = ({ onLogin }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  // ❌ No input sanitization
  // ❌ Password visible in logs
  // ❌ No rate limiting consideration
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    console.log('Login attempt:', { username, password }); // ❌ Security issue
    
    try {
      // ❌ No validation before API call
      const response = await fetch('/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password })
      });
      
      // ❌ No response validation
      const data = await response.json();
      onLogin(data);
    } catch (err) {
      // ❌ Exposing internal error details to user
      setError(err.message);
    }
  };

  return (
    <div style={{ padding: '20px' }}> {/* ❌ Inline styles */}
      <h2>Login</h2>
      <form onSubmit={handleSubmit}>
        <div>
          <label>Username:</label> {/* ❌ Missing htmlFor */}
          <input 
            type="text"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            // ❌ Missing accessibility attributes
          />
        </div>
        <div>
          <label>Password:</label>
          <input 
            type="password"
            value={password} 
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <button type="submit">Login</button>
        {error && <div style={{ color: 'red' }}>{error}</div>} {/* ❌ XSS risk */}
      </form>
    </div>
  );
};

export default LoginForm;