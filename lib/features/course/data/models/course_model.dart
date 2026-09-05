class CourseModel {
  final int id;
  final String title;
  final String subTitle;
  final int price;
  final String banner;
  final int discountType;
  final int discountAmount;
  final String discountStartDate;
  final String discountEndDate;
  final String altText;
  final String bannerTitle;
  final String durationInMonth;
  final String totalClass;
  final int totalExam;
  final int totalLive;
  final String orderStatus;

  CourseModel({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.price,
    required this.banner,
    required this.discountType,
    required this.discountAmount,
    required this.discountStartDate,
    required this.discountEndDate,
    required this.altText,
    required this.bannerTitle,
    required this.durationInMonth,
    required this.totalClass,
    required this.totalExam,
    required this.totalLive,
    required this.orderStatus,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      subTitle: json['sub_title'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      banner: json['banner'] as String? ?? '',
      discountType: json['discount_type'] as int? ?? 0,
      discountAmount: json['discount_amount'] as int? ?? 0,
      discountStartDate: json['discount_start_date'] as String? ?? '',
      discountEndDate: json['discount_end_date'] as String? ?? '',
      altText: json['alt_text'] as String? ?? '',
      bannerTitle: json['banner_title'] as String? ?? '',
      durationInMonth: json['duration_in_month'] as String? ?? '0',
      totalClass: json['total_class'] as String? ?? '0',
      totalExam: json['total_exam'] as int? ?? 0,
      totalLive: json['total_live'] as int? ?? 0,
      orderStatus: json['order_status'] as String? ?? 'false',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'sub_title': subTitle,
        'price': price,
        'banner': banner,
        'discount_type': discountType,
        'discount_amount': discountAmount,
        'discount_start_date': discountStartDate,
        'discount_end_date': discountEndDate,
        'alt_text': altText,
        'banner_title': bannerTitle,
        'duration_in_month': durationInMonth,
        'total_class': totalClass,
        'total_exam': totalExam,
        'total_live': totalLive,
        'order_status': orderStatus,
      };

  /// Returns discounted price if discount is currently active, otherwise null.
  int? get effectiveDiscountedPrice {
    if (discountAmount <= 0) return null;
    try {
      final now = DateTime.now();
      final start = _parseDate(discountStartDate);
      final end = _parseDate(discountEndDate);
      if (start != null && end != null && now.isAfter(start) && now.isBefore(end)) {
        return price - discountAmount;
      }
    } catch (_) {}
    return null;
  }

  DateTime? get discountEndDateTime => _parseDate(discountEndDate);

  static DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    try {
      // "2026-09-06 23:59"
      return DateTime.parse(raw.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }
}
