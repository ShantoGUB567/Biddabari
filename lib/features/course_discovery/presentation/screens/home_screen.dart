import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../logic/course_controller.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/course_card.dart';
import '../widgets/course_card_shimmer.dart';
import '../widgets/error_state_widget.dart';

/// MVC View: Home Course Discovery Screen
class HomeScreen extends GetView<CourseController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 1. Non-blocking Connectivity & Cache Status Banner
          const ConnectivityBanner(),

          // 2. Search Bar (Forwards input to controller.handleSearch)
          _buildSearchBar(context),

          // 3. Main Content: Reactive MVC View driven by controller.status & controller.filteredCourses
          Expanded(
            child: Obx(() {
              final status = controller.status.value;

              if (status.isLoading) {
                return _buildLoadingState();
              } else if (status.isError) {
                return ErrorStateWidget(
                  message: controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : 'Unable to load courses. Please check your internet connection.',
                  onRetry: controller.handleRetry,
                );
              } else if (status.isEmpty || controller.filteredCourses.isEmpty) {
                return EmptyStateWidget(
                  message: controller.searchQuery.value.isNotEmpty
                      ? 'No courses match "${controller.searchQuery.value}"'
                      : 'No courses available at this time.',
                  onRefresh: controller.handleClearSearch,
                );
              }

              // Success State: Render course list
              return _buildCourseList(controller.filteredCourses);
            }),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      elevation: 0,
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Biddabari',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Course Discovery',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Obx(() {
          final count = controller.courses.length;
          return Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count Live Courses',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          onChanged: controller.handleSearch,
          decoration: InputDecoration(
            hintText: 'Search courses by name or batch...',
            hintStyle: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade500,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: Obx(() {
              if (controller.searchQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.textSecondary,
                onPressed: () {
                  controller.handleClearSearch();
                  FocusScope.of(context).unfocus();
                },
              );
            }),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList(List courses) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.white,
      onRefresh: controller.handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return CourseCard(
            key: ValueKey('course_${course.id}'),
            course: course,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) => const CourseCardShimmer(),
    );
  }
}
