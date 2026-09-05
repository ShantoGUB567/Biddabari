import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/course_model.dart';
import '../../../../routes/app_route.dart';

class CourseCard extends StatefulWidget {
  final CourseModel course;

  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _discountActive = false;

  @override
  void initState() {
    super.initState();
    _initCountdown();
  }

  void _initCountdown() {
    final endDate = widget.course.discountEndDateTime;
    final discountedPrice = widget.course.effectiveDiscountedPrice;
    if (endDate != null && discountedPrice != null) {
      _discountActive = true;
      _remaining = endDate.difference(DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final r = endDate.difference(DateTime.now());
        if (r.isNegative) {
          _timer?.cancel();
          if (mounted) setState(() => _discountActive = false);
        } else {
          if (mounted) setState(() => _remaining = r);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatCountdown(Duration d) {
    if (d.isNegative) return '';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (days > 0) {
      return 'Offer ends in ${days}d ${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return 'Offer ends in ${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final discountedPrice = _discountActive ? course.effectiveDiscountedPrice : null;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoute.courseDetail,
        arguments: course,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner ────────────────────────────────────────────────
              _BannerImage(course: course),

              // ── Countdown (if active) ─────────────────────────────────
              if (_discountActive && _remaining > Duration.zero)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _formatCountdown(_remaining),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Card body ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Sub-title
                    Text(
                      course.subTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Stats row ─────────────────────────────────────
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _StatChip(
                          icon: Icons.calendar_month_outlined,
                          label: '${course.durationInMonth} মাস',
                        ),
                        _StatChip(
                          icon: Icons.play_circle_outline,
                          label: '${course.totalClass} ক্লাস',
                        ),
                        _StatChip(
                          icon: Icons.quiz_outlined,
                          label: '${course.totalExam} পরীক্ষা',
                        ),
                        _StatChip(
                          icon: Icons.live_tv_outlined,
                          label: '${course.totalLive} লাইভ',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Price ────────────────────────────────────────
                    Row(
                      children: [
                        if (discountedPrice != null) ...[
                          Text(
                            '৳${discountedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00897B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '৳${course.price}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9E9E9E),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${((course.discountAmount / course.price) * 100).toStringAsFixed(0)}% ছাড়',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ] else
                          Text(
                            '৳${course.price}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Banner image with Hero animation ─────────────────────────────────────────
class _BannerImage extends StatelessWidget {
  final CourseModel course;
  const _BannerImage({required this.course});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'course_banner_${course.id}',
      child: CachedNetworkImage(
        imageUrl: course.banner,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 180,
          color: const Color(0xFFEEEEEE),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF00897B),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 180,
          color: const Color(0xFFEEEEEE),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined,
                  color: Color(0xFFBDBDBD), size: 40),
              SizedBox(height: 6),
              Text('Image not available',
                  style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF00897B)),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF616161),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
