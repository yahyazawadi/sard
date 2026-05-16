import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudflare_product_api.dart';

class AdminImageUploadScreen extends StatefulWidget {
  const AdminImageUploadScreen({super.key});

  @override
  State<AdminImageUploadScreen> createState() => _AdminImageUploadScreenState();
}

class _AdminImageUploadScreenState extends State<AdminImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final CloudflareProductApi _api = CloudflareProductApi();

  bool _isUploading = false;
  String? _lastUploadedUrl;
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _lastUploadedUrl = null;
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _lastUploadedUrl = null;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final url = await _api.uploadImageBytes(
        bytes: bytes,
        filename: _selectedImage!.name,
      );

      setState(() {
        _lastUploadedUrl = url;
        _isUploading = false;
      });

      _copyToClipboard(url);
    } catch (e) {
      setState(() => _isUploading = false);
      _showError('Upload failed: $e');
    }
  }

  void _copyToClipboard(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EF),
      appBar: AppBar(
        title: const Text('Image Uploader'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image Preview Area
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.brown.withValues(alpha: 0.2),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 64,
                              color: Colors.brown.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Click to select an image',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.brown,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                              if (_isUploading)
                                Container(
                                  color: Colors.black45,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              if (_selectedImage != null &&
                  !_isUploading &&
                  _lastUploadedUrl == null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _uploadImage,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text(
                      'Upload & Get URL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

              if (_lastUploadedUrl != null)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _lastUploadedUrl!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.green,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.copy_rounded,
                              color: Colors.green,
                            ),
                            onPressed: () =>
                                _copyToClipboard(_lastUploadedUrl!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _lastUploadedUrl = null;
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Upload Another'),
                    ),
                  ],
                ),

              const SizedBox(height: 12),
              if (_selectedImage != null && !_isUploading)
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Change Image'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
