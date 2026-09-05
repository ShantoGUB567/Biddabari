import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../logic/course_discovery_controller.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();
    final controller = Get.find<CourseDiscoveryController>();

    return Obx(() {
      final isOnline = connectivityService.isOnline.value;
      final isShowingCache = controller.isShowingCachedData.value;
      final isSilentRefreshing = controller.isSilentRefreshing.value;

      if (isOnline && !isShowingCache && !isSilentRefreshing) {
        return const SizedBox.shrink();
      }

      Color bgColor;
      Color textColor;
      IconData icon;
      String message;

      if (!isOnline) {
        bgColor = const Color(0xFF1E293B);
        textColor = const Color(0xFFF8FAFC);
        icon = Icons.wifi_off_rounded;
        message = isShowingCache
            ? 'Offline mode • Showing saved courses'
            : 'No internet connection';
      } else if (isSilentRefreshing) {
        bgColor = AppColors.primarySubtle;
        textColor = AppColors.primary;
        icon = Icons.sync_rounded;
        message = 'Updating courses in background...';
      } else {
        // Online but showing cached data
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        icon = Icons.cached_rounded;
        message = 'Showing cached courses';
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: bgColor,
        child: Row(
          children: [
            if (isSilentRefreshing)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            else
              Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isOnline)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Auto-retry on reconnect',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isShowingCache && !isSilentRefreshing)
              GestureDetector(
                onTap: () => controller.fetchCourses(isSilent: false),
                child: Text(
                  'Refresh',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
