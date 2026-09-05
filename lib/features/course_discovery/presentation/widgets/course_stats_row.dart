import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/course_model.dart';

class CourseStatsRow extends StatelessWidget {
  final CourseModel course;
  final bool wrap;

  const CourseStatsRow({
    super.key,
    required this.course,
    this.wrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final stats = <Widget>[];

    if (course.durationInMonth != null && course.durationInMonth!.isNotEmpty) {
      stats.add(_buildStatItem(
        icon: Icons.calendar_today_outlined,
        label: '${course.durationInMonth} Months',
        color: AppColors.statDuration,
      ));
    }

    if (course.totalClass != null && course.totalClass!.isNotEmpty) {
      stats.add(_buildStatItem(
        icon: Icons.menu_book_outlined,
        label: '${course.totalClass} Classes',
        color: AppColors.statClass,
      ));
    }

    if (course.totalExam != null && course.totalExam!.isNotEmpty) {
      stats.add(_buildStatItem(
        icon: Icons.assignment_outlined,
        label: '${course.totalExam} Exams',
        color: AppColors.statExam,
      ));
    }

    if (course.totalLive != null && course.totalLive!.isNotEmpty) {
      stats.add(_buildStatItem(
        icon: Icons.videocam_outlined,
        label: '${course.totalLive} Live',
        color: AppColors.statLive,
      ));
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    if (wrap) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: stats,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            stats[i],
            if (i < stats.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
