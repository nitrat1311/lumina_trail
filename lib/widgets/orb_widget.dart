import 'package:flutter/material.dart';
import 'dart:ui' as ui; // For ImageFilter
import '../constants/app_theme.dart';

class OrbWidget extends StatefulWidget {
  final int id;
  final bool isActive; // Is it currently being shown in the sequence?
  final bool isClickable;
  final bool showFeedback;
  final bool? isCorrect; // Was the click correct? null if no feedback
  final VoidCallback onTap;

  const OrbWidget({
    super.key,
    required this.id,
    required this.isActive,
    required this.isClickable,
    required this.showFeedback,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  State<OrbWidget> createState() => _OrbWidgetState();
}

class _OrbWidgetState extends State<OrbWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _feedbackController;
  late Animation<double> _feedbackScale;
  late Animation<double> _feedbackOpacity;

  // Cycle through orb colors based on ID
  static const List<Color> _orbColors = [
    AppColors.orbCyan,
    AppColors.orbMagenta,
    AppColors.orbGold,
    // Add more colors if grid size increases
  ];

  Color get _orbColor => _orbColors[widget.id % _orbColors.length];

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 150), // Half of feedback delay
      vsync: this,
    );

    _feedbackScale = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _feedbackController, curve: Curves.easeOut));
    _feedbackOpacity = Tween<double>(begin: 0.0, end: 0.8).animate(
        CurvedAnimation(parent: _feedbackController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant OrbWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFeedback && !oldWidget.showFeedback) {
      _feedbackController.forward(from: 0.0);
    } else if (!widget.showFeedback && oldWidget.showFeedback) {
      // Optionally reset or reverse, but feedback is short-lived
      // _feedbackController.reset();
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to get constraints for sizing
    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            constraints.maxWidth * 0.8; // Make orb slightly smaller than cell

        return GestureDetector(
          onTap: widget.isClickable ? widget.onTap : null,
          child: Container(
            // Container for alignment and background (placeholder)
            alignment: Alignment.center,
            color: Colors.transparent, // Make background transparent
            child: Stack(
              alignment: Alignment.center,
              children: [
                // --- Placeholder ---
                Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    color: AppColors.placeholder,
                    shape: BoxShape.circle,
                  ),
                ),

                // --- Animated Orb ---
                AnimatedOpacity(
                  opacity: widget.isActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200), // Faster fade
                  curve: Curves.easeInOut,
                  child: AnimatedScale(
                    scale: widget.isActive ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: _orbColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _orbColor.withOpacity(0.7),
                            blurRadius: 15.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      // Optional: Add blur effect if needed, can impact performance
                      // child: ClipOval(
                      //   child: BackdropFilter(
                      //     filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                      //     child: Container(color: Colors.transparent),
                      //   ),
                      // ),
                    ),
                  ),
                ),

                // --- Feedback Indicator ---
                if (widget.showFeedback && widget.isCorrect != null)
                  FadeTransition(
                    opacity: _feedbackOpacity,
                    child: ScaleTransition(
                      scale: _feedbackScale,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isCorrect!
                                ? AppColors.feedbackCorrect
                                : AppColors.feedbackIncorrect,
                            width: 4.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
