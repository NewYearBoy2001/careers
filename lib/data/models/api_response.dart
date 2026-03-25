class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String message;
  final T? data;
  final int currentPage;
  final int lastPage;
  final int totalColleges;

  ApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.currentPage = 1,
    this.lastPage = 1,
    this.totalColleges = 0,

  });
}
