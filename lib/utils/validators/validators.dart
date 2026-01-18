class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return "Email required";
    if (!value.contains("@")) return "Invalid email";
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return "Password required";
    return null;
  }
}
