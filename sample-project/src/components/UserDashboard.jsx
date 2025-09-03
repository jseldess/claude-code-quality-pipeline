import React, { useState, useEffect } from 'react';

// ❌ Performance issues with large datasets
// ❌ No virtualization for large lists
// ❌ Inefficient re-renders
// ❌ Memory leaks potential
const UserDashboard = ({ userId }) => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filter, setFilter] = useState('');

  // ❌ No dependency array optimization
  // ❌ Potential infinite loop
  // ❌ No cleanup for async operations
  useEffect(() => {
    const fetchUsers = async () => {
      setLoading(true);
      try {
        const response = await fetch('/api/users');
        const userData = await response.json();
        
        // ❌ No data validation
        // ❌ Processing large datasets on main thread
        setUsers(userData.map(user => ({
          ...user,
          // ❌ Expensive computation on every render
          displayName: user.firstName + ' ' + user.lastName + ' (' + user.email + ')',
          isActive: new Date() - new Date(user.lastLogin) < 30 * 24 * 60 * 60 * 1000
        })));
      } catch (error) {
        console.error('Failed to fetch users:', error);
      }
      setLoading(false);
    };

    fetchUsers();
  }); // ❌ Missing dependency array

  // ❌ Inefficient filtering - runs on every render
  const filteredUsers = users.filter(user => 
    user.displayName.toLowerCase().includes(filter.toLowerCase()) ||
    user.email.toLowerCase().includes(filter.toLowerCase())
  );

  // ❌ No memoization of expensive operations
  const userStats = {
    total: users.length,
    active: users.filter(u => u.isActive).length,
    inactive: users.filter(u => !u.isActive).length
  };

  return (
    <div>
      <h1>User Dashboard</h1>
      
      <div>
        <p>Total Users: {userStats.total}</p>
        <p>Active Users: {userStats.active}</p>
        <p>Inactive Users: {userStats.inactive}</p>
      </div>

      <input
        type="text"
        placeholder="Filter users..."
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
      />

      {loading && <p>Loading...</p>}
      
      <div>
        {/* ❌ No virtualization - will be slow with 1000+ users */}
        {filteredUsers.map(user => (
          <div key={user.id} style={{ border: '1px solid #ccc', padding: '10px', margin: '5px' }}>
            <h3>{user.displayName}</h3>
            <p>Email: {user.email}</p>
            <p>Status: {user.isActive ? 'Active' : 'Inactive'}</p>
            <p>Last Login: {user.lastLogin}</p>
            {/* ❌ Inline event handlers create new functions on every render */}
            <button onClick={() => console.log('Edit user:', user.id)}>
              Edit
            </button>
            <button onClick={() => console.log('Delete user:', user.id)}>
              Delete
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};

export default UserDashboard;