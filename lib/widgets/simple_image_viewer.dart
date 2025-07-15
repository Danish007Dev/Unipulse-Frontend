import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../utils/logger.dart';

class SimpleImageViewer extends StatefulWidget {
  final String imageUrl;
  final String title;

  const SimpleImageViewer({
    Key? key,
    required this.imageUrl,
    this.title = 'Image',
  }) : super(key: key);

  @override
  State<SimpleImageViewer> createState() => _SimpleImageViewerState();
}

class _SimpleImageViewerState extends State<SimpleImageViewer> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  File? _imageFile;
  
  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });
      
      // Log the image URL for debugging
      appLogger.i('🖼️ Loading image from URL: ${widget.imageUrl}');
      
      // Use cache manager for better image caching
      final fileInfo = await DefaultCacheManager().getSingleFile(widget.imageUrl);
      
      // If we get here, the file was downloaded successfully
      appLogger.i('✅ Image loaded successfully from: ${fileInfo.path}');
      
      setState(() {
        _imageFile = fileInfo;
        _isLoading = false;
      });
    } catch (e) {
      appLogger.e('❌ Error loading image', error: e);
      
      // Try direct download as fallback
      try {
        final tempDir = await getTemporaryDirectory();
        final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
        final filePath = '${tempDir.path}/$fileName';
        
        // Download using Dio with detailed logging
        final dio = Dio();
        appLogger.i('🔄 Fallback: Downloading image to: $filePath');
        
        await dio.download(
          widget.imageUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              appLogger.i('📊 Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
            }
          },
          options: Options(
            headers: {
              'Accept': '*/*',
            },
            responseType: ResponseType.bytes,
          ),
        );
        
        final file = File(filePath);
        if (await file.exists()) {
          appLogger.i('✅ Fallback download successful: ${file.path}');
          setState(() {
            _imageFile = file;
            _isLoading = false;
          });
        } else {
          throw Exception('File download completed but file not found');
        }
      } catch (fallbackError) {
        appLogger.e('❌ Fallback download failed', error: fallbackError);
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadImage,
            tooltip: 'Reload image',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Loading image...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }
    
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _loadImage,
              ),
            ],
          ),
        ),
      );
    }
    
    if (_imageFile != null) {
      return Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.file(
            _imageFile!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              appLogger.e('❌ Error displaying image', error: error);
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error displaying image: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
    
    return const Center(
      child: Text('No image available', style: TextStyle(color: Colors.white70)),
    );
  }
}