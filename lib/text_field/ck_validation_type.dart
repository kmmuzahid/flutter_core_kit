enum CkValidationType {
  validateRequired,
  validateEmail,
  validatePhone,
  validatePassword,
  validateDate,
  validateConfirmPassword,
  validateURL,
  validateNumber,
  validateCreditCard,
  validatePostalCode,
  validateMinLength,
  validateMaxLength,
  validateCustomPattern,
  validateDateRange,
  validateAlphaNumeric,
  validateUsername,
  validateTime,
  validateOTP,
  validateCurrency,
  validateIP,
  validateFullName,
  validateNID,
  notRequired,
  validateYear,
}

/// @deprecated Use [CkValidationType] instead.
@Deprecated('Use CkValidationType instead')
typedef ValidationType = CkValidationType;
