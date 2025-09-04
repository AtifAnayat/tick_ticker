import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

class CustomToast {
  // Show a custom toast with the specified type, title, and description
  static void show({
    required BuildContext context,
    required String title,
    required String description,
    required ToastificationType type,
    Duration autoCloseDuration = const Duration(seconds: 5),
    Alignment alignment = Alignment.bottomCenter,
  }) {
    toastification.showCustom(
      context: context,
      autoCloseDuration: autoCloseDuration,
      alignment: alignment,
      dismissDirection: DismissDirection.horizontal,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      builder: (BuildContext context, ToastificationItem holder) {
        return _buildCustomToast(context, holder, title, description, type);
      },
    );
  }

  // Build the custom toast widget
  static Widget _buildCustomToast(
    BuildContext context,
    ToastificationItem holder,
    String title,
    String description,
    ToastificationType type,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, primaryColor) = _getToastAttributes(type);

    return GestureDetector(
      onTapDown: (_) => holder.pause(),
      onTapUp: (_) => holder.start(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        width: 300,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            // Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Close Button
            IconButton(
              onPressed: () => toastification.dismissById(holder.id),
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get icon and color based on toast type
  static (IconData, Color) _getToastAttributes(ToastificationType type) {
    switch (type) {
      case ToastificationType.success:
        return (Icons.check_circle_outline, Colors.green);
      case ToastificationType.error:
        return (Icons.error_outline, Colors.red);
      case ToastificationType.warning:
        return (Icons.warning_amber_rounded, Colors.yellow[800]!);
      case ToastificationType.info:
        return (Icons.info_outline, Colors.blue);
      default:
        // Default case to handle any unexpected ToastificationType
        return (Icons.info_outline, Colors.grey);
    }
  }
}