class FormValidators {
  // Email regex (RFC-ish)
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  // Phone: 10–15 digits, supports country code
  static final RegExp _phoneRegex = RegExp(r"^\+?[0-9]{10,15}$");

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (required(value, field: 'Email') != null) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (required(value, field: 'Phone number') != null) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value!.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? password(String? value) {
    if (required(value, field: 'Password') != null) {
      return 'Password is required';
    }
    if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (required(value, field: 'Confirm password') != null) {
      return 'Please confirm your password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? minLength(String? value, int length, String field) {
    if (required(value, field: field) != null) {
      return '$field is required';
    }
    if (value!.length < length) {
      return '$field must be at least $length characters';
    }
    return null;
  }
}
