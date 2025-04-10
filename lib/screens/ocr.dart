import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:abstractify/screens/navdrawer.dart';
import 'package:abstractify/widgets/floatingactbutton.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:abstractify/widgets/ocr_dropzone_widget.dart';
import 'package:abstractify/models/ocr_data.dart';
import 'package:abstractify/widgets/ocr_mode_section.dart';
import 'package:abstractify/widgets/language_dropdown.dart';

class Ocr extends StatefulWidget {
  const Ocr({super.key});

  @override
  State<Ocr> createState() => _OcrState();
}

class _OcrState extends State<Ocr> {
  final _formKey = GlobalKey<FormState>();

  final _kWidthController = TextEditingController();
  final _kHeightController = TextEditingController();
  final _overlapUpperController = TextEditingController();
  final _overlapLowerController = TextEditingController();
  final _minHeightController = TextEditingController();
  final _minWhiteController = TextEditingController(text: "125");
  final _maxWhiteController = TextEditingController(text: "225");
  final _otpTextController = TextEditingController();

  bool kernelHeightValid = true;
  bool kernelWidthValid = true;
  bool overlapUpperValid = true;
  bool overlapLowerValid = true;
  bool minThresValid = true;
  bool minWhiteValid = true;
  bool maxWhiteValid = true;
  bool isLoading = false;

  String response = "";

  Set<String> selectedFiles = {}; // Store file paths
  List<String> selectedLanguages = [];

  int port = 5000;
  PageType selectedPageType = PageType.plain;
  OcrMode selectedOcrMode = OcrMode.handwritten;
  SegmentationMode selectedSegmentationMode = SegmentationMode.automatic;

  void updateFiles(List<String> newFiles) {
    setState(() {
      selectedFiles = newFiles.toSet();
    });
  }

  Future<void> sendPostReq() async {
    final String url = "http://127.0.0.1:$port/ocr/hand";

    var request = http.MultipartRequest('POST', Uri.parse(url));

    for (var filePath in selectedFiles) {
      request.files.add(
        await http.MultipartFile.fromPath('images', filePath),
      );
    }

    request.fields['pageType'] = selectedPageType.toString();
    request.fields['ocrMode'] = selectedOcrMode.toString();
    request.fields['segmentationMode'] = selectedSegmentationMode.toString();
    request.fields['kHeight'] = _kHeightController.text;
    request.fields['kWidth'] = _kWidthController.text;
    request.fields['overlapUp'] = _overlapUpperController.text;
    request.fields['overlapDn'] = _overlapLowerController.text;
    request.fields['minHeight'] = _minHeightController.text;
    request.fields['minWhite'] = _minWhiteController.text;
    request.fields['maxWhite'] = _maxWhiteController.text;

    try {
      setState(() {
        isLoading = true;
      });

      final res = await request.send().timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          throw TimeoutException("The request timed out.");
        },
      );

      final resBody = await res.stream.bytesToString();

      setState(() {
        isLoading = false;
      });

      if (res.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(resBody);
        response = body['text'];
      } else {
        response = "Failed to upload: ${res.statusCode}";
      }
    } on TimeoutException catch (_) {
      isLoading = false;
      response = "The request timed out.";
    } catch (e) {
      response = 'Error $e';
    } finally {
      _otpTextController.text = response;
    }

    setState(() {
      isLoading = false;
    });
  }

  void _submitForm() {
    if (selectedFiles.isNotEmpty) {
      if (_formKey.currentState!.validate()) {
        int min = int.parse(_minWhiteController.text);
        int max = int.parse(_maxWhiteController.text);
        if (min < max) {
          _otpTextController.clear();
          sendPostReq();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Minimum brightness cannot exceed maximum brightness"),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No images selected")),
      );
    }
  }

  @override
  void dispose() {
    _kWidthController.dispose();
    _kHeightController.dispose();
    _overlapUpperController.dispose();
    _overlapLowerController.dispose();
    _minHeightController.dispose();
    _minWhiteController.dispose();
    _maxWhiteController.dispose();
    _otpTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "OCR",
        ),
        actions: [
          BackButton(),
        ],
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropZoneWidget(onFilesChanged: updateFiles),
                    const SizedBox(
                      height: 15,
                    ),
                    OcrToggleSection(
                      selectedOcrMode: selectedOcrMode,
                      onOcrModeChanged: (val) =>
                          setState(() => selectedOcrMode = val),
                      selectedSegmentationMode: selectedSegmentationMode,
                      onSegmentationChanged: (val) =>
                          setState(() => selectedSegmentationMode = val),
                      selectedPageType: selectedPageType,
                      onPageTypeChanged: (val) =>
                          setState(() => selectedPageType = val),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    if (selectedSegmentationMode == SegmentationMode.manual ||
                        selectedOcrMode == OcrMode.typed)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            if (selectedOcrMode == OcrMode.typed)
                              MultiLanguageSelector(
                                selectedLanguages: selectedLanguages,
                                onSelectionChanged: (newList) {
                                  setState(() {
                                    selectedLanguages = newList;
                                  });
                                },
                              ),
                            if (selectedOcrMode == OcrMode.handwritten &&
                                selectedSegmentationMode ==
                                    SegmentationMode.manual &&
                                selectedPageType == PageType.plain)
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _kHeightController,
                                      enabled:
                                          selectedPageType == PageType.plain,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Kernel Height (px)",
                                        helperText: "usually small",
                                        errorText: (kernelHeightValid ||
                                                selectedPageType !=
                                                    PageType.plain)
                                            ? null
                                            : "Please enter valid integer",
                                      ),
                                      onChanged: (String value) {
                                        final val = int.tryParse(value);
                                        setState(() =>
                                            kernelHeightValid = val != null);
                                      },
                                      validator: (value) {
                                        if (selectedPageType ==
                                            PageType.ruled) {
                                          return null;
                                        }
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter kernel height";
                                        }
                                        if (int.tryParse(value) == null) {
                                          return "Please Enter Valid Number";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _kWidthController,
                                      enabled:
                                          selectedPageType == PageType.plain,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Kernel Width",
                                        helperText: "proportional to text size",
                                        errorText: (kernelWidthValid ||
                                                selectedPageType !=
                                                    PageType.plain)
                                            ? null
                                            : "Please enter valid integer",
                                      ),
                                      onChanged: (String value) {
                                        final val = int.tryParse(value);
                                        setState(() =>
                                            kernelWidthValid = val != null);
                                      },
                                      validator: (value) {
                                        if (selectedPageType ==
                                            PageType.ruled) {
                                          return null;
                                        }
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter kernel width";
                                        }
                                        if (int.tryParse(value) == null) {
                                          return "Please Enter Valid Number";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            if (selectedOcrMode == OcrMode.handwritten &&
                                selectedSegmentationMode ==
                                    SegmentationMode.manual &&
                                selectedPageType == PageType.ruled)
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _minWhiteController,
                                      enabled: true,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Minimum Whiteness",
                                        errorText: minWhiteValid
                                            ? null
                                            : "Please enter valid integer",
                                      ),
                                      onChanged: (String value) {
                                        final val = int.tryParse(value);
                                        setState(
                                            () => minWhiteValid = val != null);
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter minimum Whiteness";
                                        }
                                        final val = int.tryParse(value);
                                        if (val == null)
                                          return "Please enter valid number";
                                        if (val < 1)
                                          return "Values must be > 0";
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _maxWhiteController,
                                      enabled: true,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Maximum Whiteness",
                                        errorText: maxWhiteValid
                                            ? null
                                            : "Please enter valid integer",
                                      ),
                                      onChanged: (String value) {
                                        final val = int.tryParse(value);
                                        setState(
                                            () => maxWhiteValid = val != null);
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter maximum Whiteness";
                                        }
                                        final val = int.tryParse(value);
                                        if (val == null)
                                          return "Please enter valid number";
                                        if (val > 255)
                                          return "Values must be < 255";
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(
                              height: 15,
                            ),
                            if (selectedOcrMode == OcrMode.handwritten &&
                                selectedSegmentationMode ==
                                    SegmentationMode.manual)
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _overlapUpperController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Overlap Top (px)",
                                        helperText:
                                            "How much images can overlap from top",
                                        errorText: overlapUpperValid
                                            ? null
                                            : "Please enter valid integer",
                                      ),
                                      onChanged: (String value) {
                                        final val = int.tryParse(value);
                                        setState(() =>
                                            overlapUpperValid = val != null);
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return "Please enter overlap";
                                        if (int.tryParse(value) == null)
                                          return "Please enter valid number";
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _overlapLowerController,
                                      enabled:
                                          selectedPageType == PageType.ruled,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Overlap Bottom (px)",
                                        helperText:
                                            "How much images can overlap from bottom",
                                        errorText: (overlapLowerValid ||
                                                selectedPageType !=
                                                    PageType.ruled)
                                            ? null
                                            : "Please enter valid integer",
                                      ),
                                      onChanged: (String value) {
                                        final val = int.tryParse(value);
                                        setState(() =>
                                            overlapLowerValid = val != null);
                                      },
                                      validator: (value) {
                                        if (selectedPageType == PageType.plain)
                                          return null;
                                        if (value == null || value.isEmpty)
                                          return "Please enter overlap";
                                        if (int.tryParse(value) == null)
                                          return "Please enter valid number";
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(
                              height: 15,
                            ),
                            if (selectedOcrMode == OcrMode.handwritten &&
                                selectedSegmentationMode ==
                                    SegmentationMode.manual)
                              TextFormField(
                                controller: _minHeightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Minimum Height Threshold (px)",
                                  helperText:
                                      "It sets how much minimum height an image should have to be considered as text",
                                  errorText: minThresValid
                                      ? null
                                      : "Please enter valid integer",
                                ),
                                onChanged: (String value) {
                                  final val = int.tryParse(value);
                                  setState(() => minThresValid = val != null);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter height threshold";
                                  }
                                  if (int.tryParse(value) == null) {
                                    return "Please enter valid number";
                                  }
                                  return null;
                                },
                              ),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: 80,
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                height: 75,
                                child: Lottie.asset(
                                  "assets/animations/waiting.json",
                                  frameRate: FrameRate(60),
                                ),
                              )
                            : FloatingActButton(
                                text: "Process",
                                onPressed: _submitForm,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 0, 16),
                  child: TextField(
                    controller: _otpTextController,
                    expands: true,
                    readOnly: true,
                    minLines: null,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),

                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
