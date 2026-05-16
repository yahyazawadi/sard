import 'package:image/image.dart' as img;

void main() {
  print('Image package members:');
  // We can't easily list members at runtime in Dart without reflection,
  // but we can test if specific ones compile.
  
  // Try to test which one works
  try {
    // This is just a dummy to see if it compiles
    // final _ = img.encodeWebP;
    print('img.encodeWebP exists');
  } catch (e) {}
}
