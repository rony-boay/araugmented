import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  // Register the camera view before running app
  var _ = ui.platformViewRegistry.registerViewFactory('camera-view', (
    int viewId,
  ) {
    final video = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.objectFit = 'cover'
      ..width = 640
      ..height = 480;
    html.window.navigator.mediaDevices
        ?.getUserMedia({'video': true})
        .then((stream) {
          video.srcObject = stream;
        })
        .catchError((e) {
          debugPrint('Camera access error: $e');
        });
    return video;
  });

  runApp(const ARApp());
}

class ARApp extends StatelessWidget {
  const ARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TryOnScreen(),
    );
  }
}

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({super.key});

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  Uint8List? _imageBytes;
  bool _usingCamera = false;

  /// Pick image from gallery
  void _pickImage() async {
    setState(() => _usingCamera = false);

    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();
    uploadInput.onChange.listen((event) async {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoadEnd.first;
        setState(() {
          _imageBytes = reader.result as Uint8List;
        });
      }
    });
  }

  /// Switch to live camera
  void _startCamera() {
    setState(() {
      _usingCamera = true;
      _imageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('AR Earring Try-On 💎'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text("Upload Photo"),
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text("Try Live"),
                onPressed: _startCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: _usingCamera
                  ? EarringOverlay(liveMode: true)
                  : (_imageBytes != null
                        ? EarringOverlay(imageBytes: _imageBytes!)
                        : const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              "Upload a photo or use live camera to try earrings 👂💍",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          )),
            ),
          ),
        ],
      ),
    );
  }
}

class EarringOverlay extends StatefulWidget {
  final Uint8List? imageBytes;
  final bool liveMode;
  const EarringOverlay({super.key, this.imageBytes, this.liveMode = false});

  @override
  State<EarringOverlay> createState() => _EarringOverlayState();
}

class _EarringOverlayState extends State<EarringOverlay> {
  Offset leftEarringPos = const Offset(150, 200);
  Offset rightEarringPos = const Offset(280, 200);
  double earringSize = 70;
  int selectedEarring = 0;

  final earrings = ['assets/earrings/ear1.png', 'assets/earrings/ear2.png'];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.liveMode)
          const Positioned.fill(child: HtmlElementView(viewType: 'camera-view'))
        else if (widget.imageBytes != null)
          Positioned.fill(
            child: Image.memory(widget.imageBytes!, fit: BoxFit.contain),
          ),

        // Left earring
        Positioned(
          left: leftEarringPos.dx,
          top: leftEarringPos.dy,
          child: GestureDetector(
            onPanUpdate: (details) =>
                setState(() => leftEarringPos += details.delta),
            child: Image.asset(
              earrings[selectedEarring],
              width: earringSize,
              height: earringSize,
            ),
          ),
        ),

        // Right earring
        Positioned(
          left: rightEarringPos.dx,
          top: rightEarringPos.dy,
          child: GestureDetector(
            onPanUpdate: (details) =>
                setState(() => rightEarringPos += details.delta),
            child: Image.asset(
              earrings[selectedEarring],
              width: earringSize,
              height: earringSize,
            ),
          ),
        ),

        // Bottom selector
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(earrings.length, (i) {
                return GestureDetector(
                  onTap: () => setState(() => selectedEarring = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedEarring == i
                            ? Colors.purpleAccent
                            : Colors.transparent,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset(earrings[i], width: 50, height: 50),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
