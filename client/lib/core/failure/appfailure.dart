class Appfailure {
  final String message;
  Appfailure([this.message = "An unexpected error occurred"]);

  @override
  String toString() => 'Appfailure(message: $message)';  
}
