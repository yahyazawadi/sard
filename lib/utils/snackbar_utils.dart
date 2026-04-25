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
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      duration: const Duration(seconds: 4),
      action: action,
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF49D4D0),
      elevation: 6,
      // Lower margin to 20 so it's not too high up, but still above the bottom nav
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
