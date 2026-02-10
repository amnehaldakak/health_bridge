class Valid {
  String messegeInputEmpty = 'Input is empty';
  String messegeInputMin = 'Input is too short';
  String messegeInputMax = 'Input is too long';

  vaidInput(String val, int min, int max) {
    if (val.length > max) {
      return messegeInputMax;
    }
    if (val.isEmpty) {
      return messegeInputEmpty;
    }
    if (val.length < min) {
      return messegeInputMin;
    }
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    return null;
  }
}
