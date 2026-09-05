import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/course_model.dart';
import '../../logic/course_controller.dart';
import '../widgets/course_stats_row.dart';
import '../widgets/discount_countdown_badge.dart';

/// MVC View: Course Details Screen
class CourseDetailsScreen extends GetView<CourseController> {
  const CourseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read courseId from Get.arguments
    final dynamic rawArg = Get.arguments;
    final int? courseId = (rawArg is int)
        ? rawArg
        : (rawArg is CourseModel ? rawArg.id : int.tryParse(rawArg.toString()));

    final course = (rawArg is CourseModel)
        ? rawArg
        : (courseId != null ? controller.getCourseById(courseId) : null);

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Course not found or ID is invalid.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final hasActiveDiscount = course.hasActiveDiscount;
    final payablePrice = course.currentPayablePrice;
    final regularPrice = course.regularPrice;
    final discountPercent = hasActiveDiscount
        ? PriceFormatter.calculateDiscountPercentage(
            originalPrice: regularPrice,
            discountedPrice: payablePrice,
          )
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. Sliver App Bar with Hero Image Banner
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                ),
                // MVC: Forward share intent to controller
                onPressed: () => controller.handleShareCourse(course),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'course_banner_${course.id}',
                    child: CachedNetworkImage(
                      imageUrl: course.banner,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Course Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Countdown timer if discount is active
                  if (hasActiveDiscount) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.countdownBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.discountRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: AppColors.discountRed, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DiscountCountdownBadge(
                              startDate: course.parsedDiscountStartDate,
                              endDate: course.parsedDiscountEndDate,
                              textStyle: const TextStyle(
                                color: AppColors.discountRed,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Course Title
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),

                  // Subtitle
                  if (course.subTitle != null && course.subTitle!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      course.subTitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Stats Breakdown Cards
                  Text(
                    'Course Overview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CourseStatsRow(course: course, wrap: true),

                  const SizedBox(height: 24),

                  // Features Grid
                  _buildCurriculumFeatures(),

                  const SizedBox(height: 24),

                  // Syllabus / Course Highlights
                  _buildCourseHighlights(course),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Bottom Sticky Action Bar
      bottomNavigationBar: _buildStickyBottomBar(
        hasActiveDiscount,
        payablePrice,
        regularPrice,
        discountPercent,
        course,
      ),
    );
  }

  Widget _buildCurriculumFeatures() {
    final features = [
      {'icon': Icons.live_tv_rounded, 'title': 'Live Interactive Classes', 'desc': 'Direct interaction with teachers'},
      {'icon': Icons.video_library_rounded, 'title': 'Recorded Archive', 'desc': 'Watch anytime with unlimited replay'},
      {'icon': Icons.quiz_rounded, 'title': 'Real-Time Model Tests', 'desc': 'Topic-wise and full-length exams'},
      {'icon': Icons.menu_book_rounded, 'title': 'PDF Lecture Sheets', 'desc': 'Comprehensive chapter notes'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is Included',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        for (var item in features) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['desc'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCourseHighlights(CourseModel course) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Biddabari Guarantee',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Comprehensive curriculum prepared by top cadre officers and specialist educators tailored for BCS, Primary, NTRCA, and Bank Job preparations.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(
    bool hasActiveDiscount,
    num payablePrice,
    num regularPrice,
    int discountPercent,
    CourseModel course,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Price Section
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasActiveDiscount) ...[
                Row(
                  children: [
                    Text(
                      PriceFormatter.format(payablePrice),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      PriceFormatter.format(regularPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textStrikeThrough,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                Text(
                  'You save ${PriceFormatter.format(regularPrice - payablePrice)} ($discountPercent%)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.discountRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                Text(
                  PriceFormatter.format(regularPrice),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Regular Price',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(width: 20),

          // Enroll Button (MVC: triggers controller.handleEnrollCourse)
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.handleEnrollCourse(course),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Enroll Now',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
