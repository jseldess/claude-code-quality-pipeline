// ❌ Utility functions with various issues
// ❌ No error handling
// ❌ Performance problems

// ❌ No input validation
export const formatCurrency = (amount) => {
  return '$' + amount.toFixed(2); // ❌ No null/undefined check
};

// ❌ Inefficient date formatting
export const formatDate = (date) => {
  // ❌ Creates new Date object every time, no caching
  const d = new Date(date);
  return d.getMonth() + 1 + '/' + d.getDate() + '/' + d.getFullYear();
};

// ❌ Deep object cloning without proper handling
export const deepClone = (obj) => {
  return JSON.parse(JSON.stringify(obj)); // ❌ Loses functions, dates become strings
};

// ❌ Inefficient array operations
export const findUserById = (users, id) => {
  // ❌ Linear search every time, no optimization
  for (let i = 0; i < users.length; i++) {
    if (users[i].id == id) { // ❌ Using == instead of ===
      return users[i];
    }
  }
  return null;
};

// ❌ Memory leak potential
export const debounce = (func, delay) => {
  let timeoutId;
  return function (...args) {
    clearTimeout(timeoutId); // ❌ No cleanup on component unmount
    timeoutId = setTimeout(() => func.apply(this, args), delay);
  };
};

// ❌ No proper sorting algorithm
export const sortByName = (items) => {
  // ❌ Mutates original array
  return items.sort((a, b) => {
    if (a.name > b.name) return 1; // ❌ Case sensitive
    if (a.name < b.name) return -1;
    return 0;
  });
};

// ❌ Unsafe localStorage usage
export const saveToStorage = (key, value) => {
  localStorage.setItem(key, JSON.stringify(value)); // ❌ No error handling for quota exceeded
};

export const loadFromStorage = (key) => {
  const item = localStorage.getItem(key);
  return JSON.parse(item); // ❌ Will throw error if item is null
};

// ❌ No input sanitization
export const generateId = () => {
  return Math.random().toString(36).substr(2, 9); // ❌ Not cryptographically secure
};

// ❌ XSS vulnerability
export const renderHTML = (htmlString) => {
  return { __html: htmlString }; // ❌ Direct HTML injection
};

// ❌ No validation of array input
export const calculateAverage = (numbers) => {
  const sum = numbers.reduce((acc, num) => acc + num, 0); // ❌ No check if numbers is array
  return sum / numbers.length; // ❌ Division by zero possible
};