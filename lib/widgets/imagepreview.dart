import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class ImagePreviewModal extends StatelessWidget {
  final List<String> imagePaths;

  const ImagePreviewModal({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: screenSize.width * 0.8,
        height: screenSize.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Selected Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount =
                      (constraints.maxWidth ~/ 200).clamp(1, 4);

                  return GridView.builder(
                    itemCount: imagePaths.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final path = imagePaths[index];
                      final fileName = p.basename(path);
                      final image = File(path);

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                                child: Image.file(
                                  image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: Text(
                                fileName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 6, left: 6, right: 6),
                              child: FutureBuilder<Size>(
                                future: _getImageSize(image),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    final size = snapshot.data!;
                                    return Text(
                                      '${size.width.toInt()} x ${size.height.toInt()}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    );
                                  } else {
                                    return const Text('Loading...',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Size> _getImageSize(File imageFile) async {
    final decoded = await decodeImageFromList(imageFile.readAsBytesSync());
    return Size(decoded.width.toDouble(), decoded.height.toDouble());
  }
}
