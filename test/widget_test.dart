import 'package:biddabari/features/course_discovery/data/models/course_model.dart';
import 'package:biddabari/features/course_discovery/presentation/widgets/course_stats_row.dart';
import 'package:biddabari/features/course_discovery/presentation/widgets/discount_countdown_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DiscountCountdownBadge renders countdown text correctly', (WidgetTester tester) async {
    final now = DateTime.now();
    final futureEnd = now.add(const Duration(days: 2, hours: 3));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscountCountdownBadge(
            startDate: now.subtract(const Duration(hours: 1)),
            endDate: futureEnd,
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify timer icon and countdown text exists
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    expect(find.textContaining('Offer ends in'), findsOneWidget);
  });

  testWidgets('CourseStatsRow renders all stats indicators', (WidgetTester tester) async {
    final course = CourseModel(
      id: 1,
      title: 'BCS Advance Course',
      price: 5000,
      banner: 'https://example.com/banner.jpg',
      durationInMonth: '6',
      totalClass: '85',
      totalExam: '93',
      totalLive: '85',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CourseStatsRow(course: course),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('6 Months'), findsOneWidget);
    expect(find.text('85 Classes'), findsOneWidget);
    expect(find.text('93 Exams'), findsOneWidget);
    expect(find.text('85 Live'), findsOneWidget);
  });
}
