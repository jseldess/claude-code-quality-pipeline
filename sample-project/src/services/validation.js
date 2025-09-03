// ❌ Incomplete validation functions
// ❌ No input sanitization
// ❌ Weak validation rules

// ❌ Very weak email validation
export const isValidEmail = (email) => {
  return email.includes('@'); // ❌ Too simple, allows invalid emails
};

// ❌ Extremely weak password validation
export const isValidPassword = (password) => {
  return password.length > 3; // ❌ No complexity requirements
};

// ❌ No phone number format validation
export const isValidPhoneNumber = (phone) => {
  return phone.length > 0; // ❌ Accepts any non-empty string
};

// ❌ No actual input sanitization
export const sanitizeInput = (input) => {
  return input.trim(); // ❌ Only trims whitespace, no XSS protection
};

// ❌ No date validation
export const isValidDate = (date) => {
  return new Date(date) != 'Invalid Date'; // ❌ Weak validation
};

// ❌ No credit card validation
export const isValidCreditCard = (cardNumber) => {
  return cardNumber.length === 16; // ❌ No Luhn algorithm check
};

// ❌ No URL validation
export const isValidURL = (url) => {
  return url.startsWith('http'); // ❌ Very basic, unsafe
};

// ❌ No ZIP code validation
export const isValidZipCode = (zip) => {
  return zip.length === 5; // ❌ Only US format, no actual validation
};

// ❌ SQL injection vulnerable
export const buildSearchQuery = (table, field, value) => {
  return `SELECT * FROM ${table} WHERE ${field} = '${value}'`; // ❌ Direct string concatenation
};

// ❌ No input length limits
export const validateUserInput = (userData) => {
  return {
    isValid: true, // ❌ Always returns valid
    errors: []     // ❌ Never reports errors
  };
};