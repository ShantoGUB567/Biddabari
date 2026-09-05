import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../logic/course_controller.dart';
import '../widgets/course_card.dart';

class CourseScreen extends GetView<CourseController> {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Offline banner ───────────────────────────────────────────
          Obx(() => controller.isOffline.value
              ? Container(
                  width: double.infinity,
                  color: const Color(0xFFE53935),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'আপনি অফলাইনে আছেন। পূর্বের ডেটা দেখানো হচ্ছে।',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              switch (controller.status.value) {
                case CourseStatus.loading:
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00897B),
                    ),
                  );

                case CourseStatus.error:
                  return _ErrorView(
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchCourses,
                  );

                case CourseStatus.empty:
                  return const _EmptyView();

                case CourseStatus.success:
                  return RefreshIndicator(
                    color: const Color(0xFF00897B),
                    onRefresh: controller.fetchCourses,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: controller.courses.length,
                      itemBuilder: (_, i) =>
                          CourseCard(course: controller.courses[i]),
                    ),
                  );
              }
            }),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF00897B),
      elevation: 0,
      title: const Text(
        'Biddabari',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: false,
      actions: [
        Obx(() => controller.isOffline.value
            ? const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.wifi_off, color: Colors.white, size: 20),
              )
            : const SizedBox.shrink()),
      ],
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 64, color: Color(0xFFBDBDBD)),
            const SizedBox(height: 16),
            const Text(
              'কোর্স লোড করতে সমস্যা হচ্ছে',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty view ────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Color(0xFFBDBDBD)),
          SizedBox(height: 16),
          Text(
            'কোনো কোর্স পাওয়া যায়নি',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }
}
