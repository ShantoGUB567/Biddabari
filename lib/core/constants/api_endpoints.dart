class ApiEndpoints {
  ApiEndpoints._();

  // REST API base
  static const String baseUrl = 'https://api.biddabari.com';
  static const String appHomeCourses = '$baseUrl/api/v1/app-home-courses';

  // CDN / Object-storage base for uploaded media files
  static const String cdnBaseUrl = 'https://storage.biddabari.online/biddabari-bucket';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Rewrites an API image URL to point to the CDN bucket.
  /// e.g. "https://api.biddabari.com/backend/assets/..." →
  ///      "https://storage.biddabari.online/biddabari-bucket/backend/assets/..."
  ///
  /// If [url] is null / empty or does not contain the expected host, it is
  /// returned unchanged so the caller's errorWidget / placeholder still fires.
  static String toBannerUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    return url.replaceFirst('https://api.biddabari.com', cdnBaseUrl);
  }
}
