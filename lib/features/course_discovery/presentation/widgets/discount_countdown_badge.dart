import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_helper.dart';

class DiscountCountdownBadge extends StatefulWidget {
  final DateTime? endDate;
  final DateTime? startDate;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final bool compact;

  const DiscountCountdownBadge({
    super.key,
    required this.endDate,
    this.startDate,
    this.textStyle,
    this.padding,
    this.compact = false,
  });

  @override
  State<DiscountCountdownBadge> createState() => _DiscountCountdownBadgeState();
}

class _DiscountCountdownBadgeState extends State<DiscountCountdownBadge> {
  Timer? _timer;
  late Duration _remaining;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant DiscountCountdownBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endDate != widget.endDate || oldWidget.startDate != widget.startDate) {
      _calculateRemaining();
      _startTimer();
    }
  }

  void _calculateRemaining() {
    _isActive = DateTimeHelper.isWithinDiscountWindow(
      startDate: widget.startDate,
      endDate: widget.endDate,
    );
    _remaining = DateTimeHelper.getRemainingDiscountDuration(endDate: widget.endDate);
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_isActive || _remaining == Duration.zero) return;

    // Tick every 1 second strictly isolated to this badge widget
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final newRemaining = DateTimeHelper.getRemainingDiscountDuration(endDate: widget.endDate);
      final newActive = DateTimeHelper.isWithinDiscountWindow(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      if (newRemaining == Duration.zero || !newActive) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
          _isActive = false;
        });
      } else {
        setState(() {
          _remaining = newRemaining;
          _isActive = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive || _remaining == Duration.zero) {
      return const SizedBox.shrink();
    }

    final formattedTime = DateTimeHelper.formatCountdown(_remaining);

    return Container(
      padding: widget.padding ??
          EdgeInsets.symmetric(
            horizontal: widget.compact ? 8 : 10,
            vertical: widget.compact ? 4 : 6,
          ),
      decoration: BoxDecoration(
        color: AppColors.discountBadgeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.discountRed.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 14,
            color: AppColors.discountRed,
          ),
          const SizedBox(width: 5),
          Text(
            widget.compact ? formattedTime : 'Offer ends in $formattedTime',
            style: widget.textStyle ??
                const TextStyle(
                  color: AppColors.discountRed,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }
}
