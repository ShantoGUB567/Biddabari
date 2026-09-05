import 'package:biddabari/core/utils/date_time_helper.dart';
import 'package:biddabari/core/utils/price_formatter.dart';
import 'package:biddabari/features/course_discovery/data/models/course_model.dart';
import 'package:biddabari/features/course_discovery/data/models/courses_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeHelper Unit Tests', () {
    test('parses API date formats accurately', () {
      final parsed = DateTimeHelper.parseApiDate('2026-09-04 16:32');
      expect(parsed, isNotNull);
      expect(parsed!.year, 2026);
      expect(parsed.month, 9);
      expect(parsed.day, 4);
      expect(parsed.hour, 16);
      expect(parsed.minute, 32);
    });

    test('validates discount window correctly', () {
      final start = DateTime(2026, 9, 1);
      final end = DateTime(2026, 9, 10);

      // Within window
      final within = DateTimeHelper.isWithinDiscountWindow(
        startDate: start,
        endDate: end,
        now: DateTime(2026, 9, 5),
      );
      expect(within, isTrue);

      // Expired
      final expired = DateTimeHelper.isWithinDiscountWindow(
        startDate: start,
        endDate: end,
        now: DateTime(2026, 9, 11),
      );
      expect(expired, isFalse);

      // Before start
      final before = DateTimeHelper.isWithinDiscountWindow(
        startDate: start,
        endDate: end,
        now: DateTime(2026, 8, 30),
      );
      expect(before, isFalse);
    });

    test('formats countdown durations correctly', () {
      const duration1 = Duration(days: 2, hours: 4, minutes: 23, seconds: 15);
      expect(DateTimeHelper.formatCountdown(duration1), '2d 04h 23m 15s');

      const duration2 = Duration(hours: 4, minutes: 23, seconds: 15);
      expect(DateTimeHelper.formatCountdown(duration2), '04h 23m 15s');

      expect(DateTimeHelper.formatCountdown(Duration.zero), 'Expired');
    });
  });

  group('PriceFormatter Unit Tests', () {
    test('formats price with Bangladeshi Taka symbol and commas', () {
      expect(PriceFormatter.format(5000), '৳5,000');
      expect(PriceFormatter.format(10200), '৳10,200');
      expect(PriceFormatter.format('3748'), '৳3,748');
    });

    test('calculates discount percentage accurately', () {
      expect(
        PriceFormatter.calculateDiscountPercentage(
          originalPrice: 5000,
          discountedPrice: 3000,
        ),
        40,
      );
      expect(
        PriceFormatter.calculateDiscountPercentage(
          originalPrice: 10000,
          discountedPrice: 6000,
        ),
        40,
      );
    });
  });

  group('CourseModel JSON Serialization & Logic', () {
    final sampleJson = {
      "id": 2057,
      "title": "19th NTRCA Preli. Target Live Batch-2",
      "sub_title": "👉 ভর্তি চলছে…",
      "price": 5000,
      "banner": "https://api.biddabari.com/backend/assets/uploaded-files/course/course-banners/test.webp",
      "discount_type": 1,
      "discount_amount": 3001,
      "discount_start_date": "2026-09-01 00:00",
      "discount_end_date": "2026-12-31 23:59",
      "alt_text": "19th NTRCA Preli",
      "banner_title": "19th NTRCA Preli",
      "duration_in_month": "6",
      "total_class": "85",
      "total_exam": 93,
      "total_live": 85,
      "order_status": "false"
    };

    test('fromJson parses all fields correctly with type safety', () {
      final course = CourseModel.fromJson(sampleJson);

      expect(course.id, 2057);
      expect(course.title, "19th NTRCA Preli. Target Live Batch-2");
      expect(course.subTitle, "👉 ভর্তি চলছে…");
      expect(course.price, 5000);
      expect(course.discountType, 1);
      expect(course.discountAmount, 3001);
      expect(course.durationInMonth, "6");
      expect(course.totalClass, "85");
      expect(course.totalExam, "93");
      expect(course.totalLive, "85");

      // Computed properties
      expect(course.hasActiveDiscount, isTrue);
      expect(course.currentPayablePrice, 3001);
      expect(course.regularPrice, 5000);
    });

    test('CoursesResponseModel handles raw JSON maps and lists', () {
      final rootJson = {
        "courses": [sampleJson]
      };
      final responseModel = CoursesResponseModel.fromJson(rootJson);
      expect(responseModel.courses.length, 1);
      expect(responseModel.courses.first.id, 2057);
    });
  });
}
