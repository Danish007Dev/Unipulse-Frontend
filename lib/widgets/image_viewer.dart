import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
// import 'dart:io';
import '../utils/logger.dart';

class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String title;

  const ImageViewerScreen({
    Key? key,
    required this.imageUrl,
    this.title = 'Image Viewer',
  }) : super(key: key);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareImage,
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _downloadImage,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error loading image: $error'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _isLoading
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : null,
    );
  }

  Future<void> _shareImage() async {
    try {
      setState(() => _isLoading = true);
      
      // Download the image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.imageUrl.split('/').last;
      final filePath = '${tempDir.path}/$fileName';
      
      await Dio().download(widget.imageUrl, filePath);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Shared from UniPulse',
      );
      
      setState(() => _isLoading = false);
    } catch (e) {
      appLogger.e('Error sharing image', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share image: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadImage() async {
    try {
      setState(() => _isLoading = true);
      
      // Get download directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access storage directory');
      }
      
      final fileName = widget.imageUrl.split('/').last;
      final filePath = '${directory.path}/$fileName';
      
      // Download the file
      await Dio().download(widget.imageUrl, filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to: $filePath')),
        );
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      appLogger.e('Error downloading image', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download image: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}