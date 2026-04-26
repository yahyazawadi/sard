import 'package:flutter/material.dart';

class SardSnackBar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show(BuildContext context, String message, {SnackBarAction? action}) {
    final state = messengerKey.currentState;
    
    if (state == null) return;

    // Force clear any previous snackbars immediately
    state.hideCurrentSnackBar();
    state.clearSnackBars();
    
    final snackBar = SnackBar(
      content: GestureDetector(
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
      duration: const Duration(seconds: 4),
      // We don't use the default action anymore to make the whole area clickable
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF49D4D0),
      elevation: 6,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
