import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;
  debugPaintBaselinesEnabled = false;
  debugPaintLayerBordersEnabled = false;
  debugRepaintRainbowEnabled = false;
  debugPaintPointersEnabled = false;

  runApp(const MaterialApp(home: PhotoTestScreen()));
}

class PhotoTestScreen extends StatefulWidget {
  const PhotoTestScreen({super.key});

  @override
  PhotoTestScreenState createState() => PhotoTestScreenState();
}

class PhotoTestScreenState extends State<PhotoTestScreen> {
  List<String> savedPhotos = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPhotos();
  }

  Future<void> _loadSavedPhotos() async {
    print('Loading saved photos...');
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(dir.path, 'photos'));
      if (await photosDir.exists()) {
        final files = await photosDir.list().toList();
        final photoPaths = files.whereType<File>().map((f) => f.path).toList();
        setState(() {
          savedPhotos = photoPaths;
        });
        print('Loaded ${photoPaths.length} photos');
      } else {
        print('Photos directory does not exist yet');
      }
    } catch (e) {
      print('Error loading photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Picker Test')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              padding: const EdgeInsets.all(16),
              itemCount: savedPhotos.length,
              itemBuilder: (context, index) {
                final path = savedPhotos[index];
                print('Displaying photo at index $index: $path');
                return Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error displaying image at $path: $error');
                    return const Icon(Icons.error);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _addPhoto(ImageSource.camera),
                  child: const Text('Add from Camera'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _addPhoto(ImageSource.gallery),
                  child: const Text('Add from Gallery'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPhoto(ImageSource source) async {
    print('Starting add photo from $source');

    // Request permissions
    Permission permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    print('Requesting permission: $permission');
    var status = await permission.request();
    print('Permission status: $status');

    if (status.isDenied) {
      print('Permission denied - showing snackbar');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${source.name} permission denied')),
        );
      }
      return;
    }

    print('Creating ImagePicker instance');
    final picker = ImagePicker();

    print('Calling pickImage');
    final XFile? file = await picker.pickImage(source: source);
    print('Pick result: ${file?.path ?? 'null'}');

    if (file == null) {
      print('User cancelled pick');
      return;
    }

    print('Getting documents directory');
    final dir = await getApplicationDocumentsDirectory();
    print('Documents dir: ${dir.path}');

    print('Creating photos directory');
    final photosDir = Directory(p.join(dir.path, 'photos'));
    await photosDir.create(recursive: true);
    print('Photos dir: ${photosDir.path}');

    print('Generating unique name');
    final uuid = Uuid().v4();
    final uniqueName = '${DateTime.now().toIso8601String()}_$uuid.jpg';
    final newPath = p.join(photosDir.path, uniqueName);
    print('New path: $newPath');

    print('Copying file');
    await File(file.path).copy(newPath);
    print('File copied successfully');

    if (!context.mounted) {
      print('Context not mounted - skipping dialog');
      return;
    }

    print('Showing dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(newPath), height: 200),
            const SizedBox(height: 8),
            Text('Path: $newPath', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('Dialog closed - reloading photos');
              _loadSavedPhotos();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
