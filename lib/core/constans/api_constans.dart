class ApiConstants {
  static const String baseUrl = 'http://10.117.99.130:8081/v1';

  // Auth endpoints
  static const String verifyToken = '/auth/verify-token';

  // Product endpoints
  static const String products = '/products';

  // Cart endpoints
  static const String cart = '/cart';

  // Order endpoints
  static const String orders = '/orders';
  static const String checkout = '/orders/checkout';

  // Timeout
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
