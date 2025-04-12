import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // For cropping functionality
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:byhands/pages/pop_up/image_preview_screen.dart';

// ignore: use_key_in_widget_constructors
class Camera extends StatefulWidget {
  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text("Camera", style: Theme.of(context).textTheme.titleLarge),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(
                          255,
                          135,
                          128,
                          139,
                        ) // Dark mode color
                        : const Color.fromARGB(
                          255,
                          203,
                          194,
                          205,
                        ), // Light mode color
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Home');
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      drawer: CommonDrawer(),
      body: _buildUI(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 247, 246, 251),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(
            50.0,
          ), // Adjust for the desired shape
        ),
        child: IconButton(
          icon: const Icon(
            Icons.photo,
            color: Color.fromARGB(255, 54, 43, 75),
          ), // Adjust icon color if necessary
          onPressed: _pickImageFromGallery,
        ),
      ),
    );
  }

  Widget _buildUI() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
            Container(
              height: MediaQuery.sizeOf(context).height * 0.65,
              width: MediaQuery.sizeOf(context).width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 54, 43, 75), // Border color
                  width: 3.0, // Border width
                ),
                borderRadius: BorderRadius.circular(15.0), // Border radius
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  10.0,
                ), // Same as border radius
                child: CameraPreview(cameraController!),
              ),
            ),
            IconButton(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              onPressed: () async {
                XFile picture = await cameraController!.takePicture();
                File file = File(picture.path);
                File croppedFile = await cropImage(file); // Added cropping
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ImagePreviewScreen(imageFile: croppedFile),
                  ),
                );
              },
              iconSize: 60,
              icon: const Icon(
                Icons.camera,
                color: Color.fromARGB(255, 54, 43, 75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imageFile: _selectedImage!),
        ),
      );
    }
  }

  Future<void> _setupCameraController() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      setState(() {
        cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
        );
        cameraController?.initialize().then((_) {
          setState(() {});
        });
      });
    }
  }

  // Function to crop the image
  Future<File> cropImage(File originalImage) async {
    final bytes = await originalImage.readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);

    if (decodedImage != null) {
      // Crop to square
      int cropSize =
          decodedImage.width > decodedImage.height
              ? decodedImage.height
              : decodedImage.width;

      img.Image croppedImage = img.copyCrop(
        decodedImage,
        x: (decodedImage.width - cropSize) ~/ 2, // Center crop X
        y: (decodedImage.height - cropSize) ~/ 2, // Center crop Y
        width: cropSize,
        height: cropSize,
      );

      // Save cropped image
      final outputFilePath = originalImage.path.replaceFirst(
        '.jpg',
        '_cropped.jpg',
      );
      final croppedFile = File(outputFilePath);
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage));
      return croppedFile;
    }
    throw Exception("Unable to decode image");
  }
}
