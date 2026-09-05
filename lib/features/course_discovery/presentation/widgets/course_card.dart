import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/course_model.dart';
import '../../logic/course_controller.dart';
import 'course_stats_row.dart';
import 'discount_countdown_badge.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseController>();
    final hasActiveDiscount = course.hasActiveDiscount;
    final payablePrice = course.currentPayablePrice;
    final regularPrice = course.regularPrice;
    final discountPercent = hasActiveDiscount
        ? PriceFormatter.calculateDiscountPercentage(
            originalPrice: regularPrice,
            discountedPrice: payablePrice,
          )
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // MVC: Forward UI event to Controller
          onTap: onTap ?? () => controller.handleCourseTap(course),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Course Banner Image with Hero Animation & Badges
              _buildBannerSection(context, hasActiveDiscount, discountPercent),

              // 2. Course Info Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Countdown Badge (ticks every 1s without rebuilding the card)
                    if (hasActiveDiscount) ...[
                      DiscountCountdownBadge(
                        startDate: course.parsedDiscountStartDate,
                        endDate: course.parsedDiscountEndDate,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Course Title
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Subtitle
                    if (course.subTitle != null && course.subTitle!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        course.subTitle!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Stats indicators (Duration, Classes, Exams, Live)
                    CourseStatsRow(course: course),

                    const SizedBox(height: 14),
                    const Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 12),

                    // Pricing & Action Row
                    _buildPricingRow(hasActiveDiscount, payablePrice, regularPrice),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSection(
    BuildContext context,
    bool hasActiveDiscount,
    int discountPercent,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: Stack(
        children: [
          // Hero animated Cached Network Image
          Hero(
            tag: 'course_banner_${course.id}',
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: course.banner,
                fit: BoxFit.cover,
                placeholder: (context, url) => Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),

          // Top Right: Discount Savings Badge
          if (hasActiveDiscount && discountPercent > 0)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.discountRed,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_offer_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$discountPercent% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(
    bool hasActiveDiscount,
    num payablePrice,
    num regularPrice,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Price display
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasActiveDiscount) ...[
              Row(
                children: [
                  Text(
                    PriceFormatter.format(payablePrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
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
            ] else ...[
              Text(
                PriceFormatter.format(regularPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),

        // Action CTA
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View Details',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
