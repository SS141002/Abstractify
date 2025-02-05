import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:abstractify/screens/navdrawer.dart';
import 'package:flutter/services.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    super.key,
    required this.image1,
    required this.image2,
  });

  final String image1;
  final String image2;

  @override
  Widget build(BuildContext context) {
    bool canDecode = false;
    late Uint8List image1Bytes;
    late Uint8List image2Bytes;
    late MemoryImage img1;
    late MemoryImage img2;

    try {
      image1Bytes = base64Decode(image1);
      img1 = MemoryImage(image1Bytes);
      image2Bytes = base64Decode(image1);
      img2 = MemoryImage(image2Bytes);
      canDecode = true;
    } catch (e) {
      canDecode = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Image Preview",
        ),
        actions: [
          BackButton(),
        ],
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: canDecode
                    ? Image(
                        image: img1,
                      )
                    : Center(
                        child: Text(
                          " Unable to Decode Image.",
                        ),
                      ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: canDecode
                    ? Image(
                        image: img2,
                      )
                    : Center(
                        child: Text(
                          " Unable to Decode Image.",
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
