import 'dart:math';

String generateAdminId() {
  final random = Random();
  return '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999999)}';
}