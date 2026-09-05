import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/date_time_helper.dart';

class CourseModel {
  final int id;
  final String title;
  final String? subTitle;
  final num price;
  final String banner;
  final int? discountType;
  final num? discountAmount;
  final String? discountStartDate;
  final String? discountEndDate;
  final String? altText;
  final String? bannerTitle;
  final String? durationInMonth;
  final String? totalClass;
  final String? totalExam;
  final String? totalLive;
  final String? orderStatus;

  CourseModel({
    required this.id,
    required this.title,
    this.subTitle,
    required this.price,
    required this.banner,
    this.discountType,
    this.discountAmount,
    this.discountStartDate,
    this.discountEndDate,
    this.altText,
    this.bannerTitle,
    this.durationInMonth,
    this.totalClass,
    this.totalExam,
    this.totalLive,
    this.orderStatus,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: _parseInt(json['id']) ?? 0,
      title: json['title']?.toString().trim() ?? 'Untitled Course',
      subTitle: json['sub_title']?.toString().trim(),
      price: _parseNum(json['price']) ?? 0,
      banner: ApiEndpoints.toBannerUrl(json['banner']?.toString().trim()),
      discountType: _parseInt(json['discount_type']),
      discountAmount: _parseNum(json['discount_amount']),
      discountStartDate: json['discount_start_date']?.toString(),
      discountEndDate: json['discount_end_date']?.toString(),
      altText: json['alt_text']?.toString(),
      bannerTitle: json['banner_title']?.toString(),
      durationInMonth: json['duration_in_month']?.toString(),
      totalClass: json['total_class']?.toString(),
      totalExam: json['total_exam']?.toString(),
      totalLive: json['total_live']?.toString(),
      orderStatus: json['order_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }

  // --- Computed Business Logic & Helpers ---

  DateTime? get parsedDiscountStartDate =>
      DateTimeHelper.parseApiDate(discountStartDate);

  DateTime? get parsedDiscountEndDate =>
      DateTimeHelper.parseApiDate(discountEndDate);

  /// True if course has a valid discount configured and current time is inside the discount window
  bool get hasActiveDiscount {
    if (discountAmount == null || discountAmount! <= 0) return false;
    if (parsedDiscountEndDate == null) return false;

    return DateTimeHelper.isWithinDiscountWindow(
      startDate: parsedDiscountStartDate,
      endDate: parsedDiscountEndDate,
    );
  }

  /// The price the user pays right now
  num get currentPayablePrice {
    if (hasActiveDiscount && discountAmount != null && discountAmount! < price) {
      return discountAmount!;
    }
    return price;
  }

  /// Original standard price
  num get regularPrice => price;

  /// Remaining duration before discount expires
  Duration get remainingDiscountDuration =>
      DateTimeHelper.getRemainingDiscountDuration(endDate: parsedDiscountEndDate);

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }
}
