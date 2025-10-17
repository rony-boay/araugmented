import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  void _pickImage() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('AR Earring Try-On 💎'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text("Upload Your Photo"),
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            if (_imageBytes != null)
              Expanded(
                child: EarringOverlay(imageBytes: _imageBytes!),
              ),
            if (_imageBytes == null)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Upload your photo to try earrings virtually — just like Lenskart! 👂💍",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EarringOverlay extends StatefulWidget {
  final Uint8List imageBytes;
  const EarringOverlay({super.key, required this.imageBytes});

  @override
  State<EarringOverlay> createState() => _EarringOverlayState();
}

class _EarringOverlayState extends State<EarringOverlay> {
  Offset leftEarringPos = const Offset(150, 200);
  Offset rightEarringPos = const Offset(280, 200);
  double earringSize = 70;
  int selectedEarring = 0;

  final earrings = [
    'assets/earrings/ear1.png',
    'assets/earrings/ear2.png',
  //  'assets/earrings/diamond3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // User photo
        Positioned.fill(
          child: Image.memory(widget.imageBytes, fit: BoxFit.contain),
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

        // Bottom earring selector
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
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
                          width: 2),
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
