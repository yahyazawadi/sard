import 'package:flutter/material.dart';
import '../custom/app_theme.dart';

class SardSnackBar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show(BuildContext context, String message, {SnackBarAction? action}) {
    final state = messengerKey.currentState;
    
    if (state == null) return;

    // Force clear any previous snackbars immediately
    state.hideCurrentSnackBar();
    state.clearSnackBars();
    
    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.gradientStart, AppTheme.primaryTeal],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC66900),
            width: 1.0,
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: action != null ? () {
            action.onPressed();
            messengerKey.currentState?.hideCurrentSnackBar();
          } : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 8),
                Text(
                  action.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: EdgeInsets.zero,
    );

    state.showSnackBar(snackBar);

    // Fallback: Manually hide after 4.2 seconds if the system duration fails for any reason
    Future.delayed(const Duration(milliseconds: 4200), () {
      try {
        messengerKey.currentState?.hideCurrentSnackBar();
      } catch (_) {}
    });
  }
}
