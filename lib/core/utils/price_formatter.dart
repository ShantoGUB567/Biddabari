import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class PriceFormatter {
  PriceFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat('#,##,###');

  /// Formats a num or string price with Taka symbol e.g. "৳5,000"
  static String format(dynamic price) {
    if (price == null) return '${AppConstants.currencySymbol}0';

    num? value;
    if (price is num) {
      value = price;
    } else {
      value = num.tryParse(price.toString().replaceAll(',', ''));
    }

    if (value == null) return '${AppConstants.currencySymbol}0';

    // Format with commas
    final formattedNum = _currencyFormat.format(value.round());
    return '${AppConstants.currencySymbol}$formattedNum';
  }

  /// Calculates percentage discount: ((original - discounted) / original) * 100
  static int calculateDiscountPercentage({
    required num originalPrice,
    required num discountedPrice,
  }) {
    if (originalPrice <= 0) return 0;
    final diff = originalPrice - discountedPrice;
    if (diff <= 0) return 0;
    return ((diff / originalPrice) * 100).round();
  }
}
