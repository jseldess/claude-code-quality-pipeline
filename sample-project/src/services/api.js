// ❌ No request/response interceptors
// ❌ Missing error handling
// ❌ No retry logic
// ❌ Hard-coded URLs

class ApiService {
  constructor() {
    this.baseURL = 'http://localhost:3001/api'; // ❌ Hard-coded, no HTTPS
  }

  // ❌ No input validation
  // ❌ No authentication handling
  // ❌ Memory leaks with AbortController not cleaned up
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    
    // ❌ No timeout handling
    // ❌ No request headers standardization
    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      },
      ...options
    });

    // ❌ No status code handling
    // ❌ Assumes response is always JSON
    return response.json();
  }

  // ❌ No error boundaries
  // ❌ No data validation
  async getUser(id) {
    return this.request(`/users/${id}`);
  }

  // ❌ No CSRF protection
  // ❌ No input sanitization
  async createUser(userData) {
    return this.request('/users', {
      method: 'POST',
      body: JSON.stringify(userData) // ❌ No validation of userData
    });
  }

  // ❌ No rate limiting consideration
  // ❌ Potential SQL injection if backend is vulnerable
  async searchUsers(query) {
    return this.request(`/users/search?q=${query}`); // ❌ No URL encoding
  }

  // ❌ No authentication token refresh logic
  async authenticateUser(credentials) {
    const response = await this.request('/auth/login', {
      method: 'POST',
      body: JSON.stringify(credentials)
    });

    // ❌ Token stored in memory, no persistence strategy
    if (response.token) {
      this.token = response.token;
    }

    return response;
  }

  // ❌ No proper logout cleanup
  async logout() {
    this.token = null; // ❌ Should clear from storage/cookies too
    return { success: true };
  }
}

export default new ApiService(); // ❌ Singleton pattern may cause issues in tests